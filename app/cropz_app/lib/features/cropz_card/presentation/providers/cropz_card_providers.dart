import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../shared/data/local/database/app_database.dart';
import '../../data/datasources/local/cropz_card_local_datasource.dart';
import '../../data/datasources/local/cropz_card_sync_local_datasource.dart';
import '../../data/datasources/remote/pocketbase_card_remote_datasource.dart';
import '../../data/repositories/cropz_card_repository_impl.dart';
import '../../data/services/cropz_card_local_json_export_service.dart';
import '../../data/services/cropz_card_payload_codec.dart';
import '../../data/services/cropz_card_sync_service.dart';
import '../../domain/entities/cropz_card_details.dart';
import '../../domain/entities/cropz_profile.dart';
import '../../domain/entities/profile_address.dart';
import '../../domain/repositories/cropz_card_repository.dart';

class SearchableProfile {
  const SearchableProfile({
    required this.profile,
    required this.addresses,
    required this.citySet,
    required this.searchCorpus,
  });

  final CropzProfile profile;
  final List<String> addresses;
  final Set<String> citySet;
  final String searchCorpus;
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final cropzCardLocalDatasourceProvider = Provider<CropzCardLocalDatasource>((
  ref,
) {
  return CropzCardLocalDatasource(ref.watch(appDatabaseProvider));
});

final cropzCardRepositoryProvider = Provider<CropzCardRepository>((ref) {
  return CropzCardRepositoryImpl(
    localDatasource: ref.watch(cropzCardLocalDatasourceProvider),
  );
});

final cropzCardPayloadCodecProvider = Provider<CropzCardPayloadCodec>((ref) {
  return const CropzCardPayloadCodec();
});

final cropzCardLocalJsonExportServiceProvider =
    Provider<CropzCardLocalJsonExportService>((ref) {
      return const CropzCardLocalJsonExportService();
    });

final cropzCardSyncLocalDatasourceProvider =
    Provider<CropzCardSyncLocalDatasource>((ref) {
      return CropzCardSyncLocalDatasource(ref.watch(appDatabaseProvider));
    });

final pocketbaseCardRemoteDatasourceProvider =
    Provider<PocketbaseCardRemoteDatasource>((ref) {
      return const PocketbaseCardRemoteDatasource();
    });

final cropzCardSyncServiceProvider = Provider<CropzCardSyncService>((ref) {
  return CropzCardSyncService(
    localDatasource: ref.watch(cropzCardSyncLocalDatasourceProvider),
    remoteDatasource: ref.watch(pocketbaseCardRemoteDatasourceProvider),
    payloadCodec: ref.watch(cropzCardPayloadCodecProvider),
  );
});

final cropzProfilesProvider = FutureProvider<List<CropzProfile>>((ref) {
  return ref.watch(cropzCardRepositoryProvider).getAllProfiles();
});

final searchableProfilesProvider = FutureProvider<List<SearchableProfile>>((
  ref,
) async {
  final repository = ref.watch(cropzCardRepositoryProvider);
  final profiles = await repository.getAllProfiles();

  return Future.wait(
    profiles.map((profile) async {
      final addresses = profile.id == null
          ? const <ProfileAddress>[]
          : await repository.getAddressesByProfileId(profile.id!);

      final addressTexts = addresses
          .map(
            (address) =>
                [
                      address.address1,
                      address.address2,
                      address.address3,
                      address.city,
                      address.taluk,
                      address.block,
                      address.district,
                      address.state,
                      address.pincode,
                    ]
                    .whereType<String>()
                    .map((value) => value.trim())
                    .where((value) => value.isNotEmpty)
                    .join(', '),
          )
          .where((value) => value.isNotEmpty)
          .toList(growable: false);

      final citySet = addresses
          .map((address) => (address.city ?? '').trim().toLowerCase())
          .where((city) => city.isNotEmpty)
          .toSet();

      final searchCorpus = [
        profile.firmName,
        profile.ownerName,
        profile.mobile,
        ...citySet,
        ...addressTexts,
      ].whereType<String>().map((value) => value.toLowerCase()).join(' ');

      return SearchableProfile(
        profile: profile,
        addresses: addressTexts,
        citySet: citySet,
        searchCorpus: searchCorpus,
      );
    }),
  );
});

final cropzCardDetailsProvider = FutureProvider.family<CropzCardDetails, int>((
  ref,
  profileId,
) {
  return ref
      .watch(cropzCardRepositoryProvider)
      .getCardDetailsByProfileId(profileId);
});

class CropzCardFormState {
  const CropzCardFormState({this.isSaving = false, this.errorMessage});

  final bool isSaving;
  final String? errorMessage;

  CropzCardFormState copyWith({bool? isSaving, String? errorMessage}) {
    return CropzCardFormState(
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
    );
  }
}

class CropzCardFormController extends Notifier<CropzCardFormState> {
  @override
  CropzCardFormState build() {
    return const CropzCardFormState();
  }

  Future<bool> saveCardDetails(CropzCardDetails details) async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      final duplicate = await _findDuplicateCredentialCard(details);
      if (duplicate != null) {
        state = state.copyWith(
          isSaving: false,
          errorMessage:
              'A card with the same credentials already exists (Profile ID: ${duplicate.id}).',
        );
        return false;
      }

      final savedId = await ref
          .watch(cropzCardRepositoryProvider)
          .saveCardDetails(details);

      final profile = details.profile;
      final normalizedDetails = CropzCardDetails(
        profile: CropzProfile(
          id: profile.id ?? savedId,
          cropzId: profile.cropzId,
          firmName: profile.firmName,
          ownerName: profile.ownerName,
          mobile: profile.mobile,
          whatsapp: profile.whatsapp,
          email: profile.email,
          gstNo: profile.gstNo,
          slNo: profile.slNo,
          slExpiryDate: profile.slExpiryDate,
          plNo: profile.plNo,
          retailFlNo: profile.retailFlNo,
          retailFlExpiryDate: profile.retailFlExpiryDate,
          wsFlNo: profile.wsFlNo,
          wsFlExpiryDate: profile.wsFlExpiryDate,
          fmsRetailId: profile.fmsRetailId,
          fmsWsId: profile.fmsWsId,
          gstDocument: profile.gstDocument,
          slDocument: profile.slDocument,
          plDocument: profile.plDocument,
          flDocument: profile.flDocument,
          profilePicture: profile.profilePicture,
          companies: profile.companies,
          upiId: profile.upiId,
          qrCode: profile.qrCode,
          transport: profile.transport,
        ),
        bankInfos: details.bankInfos,
        addresses: details.addresses,
      );

      final cardKey = 'profile_${normalizedDetails.profile.id ?? savedId}';
      final auth = ref.read(authControllerProvider);
      final ownerKey = auth.phoneNumber.isNotEmpty
          ? auth.phoneNumber
          : (normalizedDetails.profile.mobile.isNotEmpty
                ? normalizedDetails.profile.mobile
                : 'guest');

      final sync = ref.read(cropzCardSyncServiceProvider);
      final payloadCodec = ref.read(cropzCardPayloadCodecProvider);
      final payloadJson = payloadCodec.encode(normalizedDetails);

      try {
        final fileStem = 'profile_${normalizedDetails.profile.id ?? savedId}';
        final exportedPaths = await ref
            .read(cropzCardLocalJsonExportServiceProvider)
            .export(fileStem: fileStem, payloadJson: payloadJson);
        if (exportedPaths.isEmpty) {
          throw Exception('No local JSON file path was returned.');
        }
      } catch (error) {
        state = state.copyWith(
          isSaving: false,
          errorMessage:
              'Card saved in app, but local JSON export failed: $error',
        );
        return false;
      }

      await sync.enqueueUpsert(
        localProfileId: normalizedDetails.profile.id ?? savedId,
        ownerKey: ownerKey,
        cardKey: cardKey,
        details: normalizedDetails,
      );
      try {
        final authState = ref.read(authControllerProvider);
        final token = authState.jwtToken.trim();
        await sync.flush(authToken: token.isEmpty ? null : token);
      } catch (error) {
        state = state.copyWith(
          isSaving: false,
          errorMessage: 'Card saved in app, but PocketBase sync failed: $error',
        );
        return false;
      }

      ref.invalidate(cropzProfilesProvider);
      ref.invalidate(searchableProfilesProvider);
      state = state.copyWith(isSaving: false, errorMessage: null);
      return true;
    } catch (error) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Unable to save profile: $error',
      );
      return false;
    }
  }

  Future<CropzProfile?> _findDuplicateCredentialCard(
    CropzCardDetails incomingDetails,
  ) async {
    final repository = ref.read(cropzCardRepositoryProvider);
    final profiles = await repository.getAllProfiles();
    final incomingSignature = _buildDuplicateSignature(incomingDetails);

    for (final profile in profiles) {
      final profileId = profile.id;
      if (profileId == null) {
        continue;
      }
      if (incomingDetails.profile.id != null &&
          incomingDetails.profile.id == profileId) {
        continue;
      }

      final existing = await repository.getCardDetailsByProfileId(profileId);
      final existingSignature = _buildDuplicateSignature(existing);
      if (incomingSignature == existingSignature) {
        return existing.profile;
      }
    }
    return null;
  }

  String _buildDuplicateSignature(CropzCardDetails details) {
    final p = details.profile;
    final parts = <String>[
      _token('cropz_id', p.cropzId),
      _token('mobile', p.mobile),
      _token('whatsapp', p.whatsapp),
      _token('email', p.email),
      _token('gst_no', p.gstNo),
      _token('sl_no', p.slNo),
      _token('sl_expiry_date', p.slExpiryDate),
      _token('pl_no', p.plNo),
      _token('retail_fl_no', p.retailFlNo),
      _token('retail_fl_expiry_date', p.retailFlExpiryDate),
      _token('ws_fl_no', p.wsFlNo),
      _token('ws_fl_expiry_date', p.wsFlExpiryDate),
      _token('fms_retail_id', p.fmsRetailId),
      _token('fms_ws_id', p.fmsWsId),
      _token('upi_id', p.upiId),
      _token('qr_code', p.qrCode),
      _token('transport', p.transport),
      _token('gst_document', p.gstDocument),
      _token('sl_document', p.slDocument),
      _token('pl_document', p.plDocument),
      _token('fl_document', p.flDocument),
      _token('profile_picture', p.profilePicture),
    ];

    for (final bank in details.bankInfos) {
      parts.add(_token('bank_account_no', bank.accountNo));
      parts.add(_token('bank_account_type', bank.accountType));
      parts.add(_token('bank_ifsc_code', bank.ifscCode));
    }

    for (final address in details.addresses) {
      parts.add(_token('address_type', address.addressType));
      parts.add(_token('address1', address.address1));
      parts.add(_token('address2', address.address2));
      parts.add(_token('address3', address.address3));
      parts.add(_token('city', address.city));
      parts.add(_token('taluk', address.taluk));
      parts.add(_token('block', address.block));
      parts.add(_token('district', address.district));
      parts.add(_token('state', address.state));
      parts.add(_token('pincode', address.pincode));
      parts.add(_token('in_gst', address.inGst == true ? '1' : '0'));
      parts.add(_token('parent_cropz_id', address.parentCropzId));
    }

    final normalized = parts.where((value) => value.isNotEmpty).toList()
      ..sort();
    return normalized.join('|');
  }

  String _norm(String? value) => (value ?? '').trim().toLowerCase();

  String _token(String key, String? value) {
    final normalized = _norm(value);
    if (normalized.isEmpty) {
      return '';
    }
    return '$key=$normalized';
  }
}

final cropzCardFormControllerProvider =
    NotifierProvider<CropzCardFormController, CropzCardFormState>(
      CropzCardFormController.new,
    );
