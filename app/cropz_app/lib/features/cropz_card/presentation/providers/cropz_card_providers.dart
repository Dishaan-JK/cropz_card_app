import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../shared/data/local/database/app_database.dart';
import '../../data/datasources/local/cropz_card_local_datasource.dart';
import '../../data/datasources/local/cropz_card_sync_local_datasource.dart';
import '../../data/datasources/remote/pocketbase_card_remote_datasource.dart';
import '../../data/repositories/cropz_card_repository_impl.dart';
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
      await sync.enqueueUpsert(
        ownerKey: ownerKey,
        cardKey: cardKey,
        details: normalizedDetails,
      );
      await sync.flush();

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
    final incomingFingerprint = _buildCredentialFingerprint(incomingDetails);

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
      final existingFingerprint = _buildCredentialFingerprint(existing);
      if (existingFingerprint == incomingFingerprint) {
        return existing.profile;
      }
    }
    return null;
  }

  String _buildCredentialFingerprint(CropzCardDetails details) {
    final p = details.profile;
    final profileTokens = <String>[
      _norm(p.cropzId),
      _norm(p.email),
      _norm(p.gstNo),
      _norm(p.slNo),
      _norm(p.slExpiryDate),
      _norm(p.plNo),
      _norm(p.retailFlNo),
      _norm(p.retailFlExpiryDate),
      _norm(p.wsFlNo),
      _norm(p.wsFlExpiryDate),
      _norm(p.fmsRetailId),
      _norm(p.fmsWsId),
      _norm(p.gstDocument),
      _norm(p.slDocument),
      _norm(p.plDocument),
      _norm(p.flDocument),
      _norm(p.profilePicture),
      _norm(p.upiId),
      _norm(p.qrCode),
      _norm(p.transport),
    ];

    final addressTokens = details.addresses
        .map(
          (a) => [
            _norm(a.cropzId),
            _norm(a.addressType),
            _norm(a.address1),
            _norm(a.address2),
            _norm(a.address3),
            _norm(a.city),
            _norm(a.taluk),
            _norm(a.block),
            _norm(a.district),
            _norm(a.state),
            _norm(a.pincode),
            a.inGst == true ? '1' : '0',
            _norm(a.parentCropzId),
          ].join('|'),
        )
        .toList()
      ..sort();

    final bankTokens = details.bankInfos
        .map(
          (b) => [
            _norm(b.accountHolderName),
            _norm(b.accountNo),
            _norm(b.accountType),
            _norm(b.ifscCode),
          ].join('|'),
        )
        .toList()
      ..sort();

    return [
      profileTokens.join('|'),
      addressTokens.join('||'),
      bankTokens.join('||'),
    ].join('###');
  }

  String _norm(String? value) => (value ?? '').trim().toLowerCase();
}

final cropzCardFormControllerProvider =
    NotifierProvider<CropzCardFormController, CropzCardFormState>(
      CropzCardFormController.new,
    );
