import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/data/local/database/app_database.dart';
import '../../data/datasources/local/cropz_card_local_datasource.dart';
import '../../data/repositories/cropz_card_repository_impl.dart';
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
      await ref.watch(cropzCardRepositoryProvider).saveCardDetails(details);
      ref.invalidate(cropzProfilesProvider);
      ref.invalidate(searchableProfilesProvider);
      state = state.copyWith(isSaving: false, errorMessage: null);
      return true;
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Unable to save profile',
      );
      return false;
    }
  }
}

final cropzCardFormControllerProvider =
    NotifierProvider<CropzCardFormController, CropzCardFormState>(
      CropzCardFormController.new,
    );
