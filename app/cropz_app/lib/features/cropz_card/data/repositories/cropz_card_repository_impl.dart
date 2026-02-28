import '../../domain/entities/bank_info.dart';
import '../../domain/entities/cropz_card_details.dart';
import '../../domain/entities/cropz_profile.dart';
import '../../domain/entities/profile_address.dart';
import '../../domain/repositories/cropz_card_repository.dart';
import '../datasources/local/cropz_card_local_datasource.dart';
import '../models/bank_info_model.dart';
import '../models/cropz_profile_model.dart';
import '../models/profile_address_model.dart';

class CropzCardRepositoryImpl implements CropzCardRepository {
  const CropzCardRepositoryImpl({required this.localDatasource});

  final CropzCardLocalDatasource localDatasource;

  @override
  Future<List<CropzProfile>> getAllProfiles() async {
    return localDatasource.getProfiles();
  }

  @override
  Future<List<BankInfo>> getBankInfosByProfileId(int profileId) {
    return localDatasource.getBankInfosByProfileId(profileId);
  }

  @override
  Future<List<ProfileAddress>> getAddressesByProfileId(int profileId) {
    return localDatasource.getAddressesByProfileId(profileId);
  }

  @override
  Future<CropzCardDetails> getCardDetailsByProfileId(int profileId) async {
    final profiles = await localDatasource.getProfiles();
    final profile = profiles.firstWhere((element) => element.id == profileId);
    final bankInfos = await localDatasource.getBankInfosByProfileId(profileId);
    final addresses = await localDatasource.getAddressesByProfileId(profileId);
    return CropzCardDetails(
      profile: profile,
      bankInfos: bankInfos,
      addresses: addresses,
    );
  }

  @override
  Future<int> saveCardDetails(CropzCardDetails details) {
    final profileModel = CropzProfileModel.fromEntity(details.profile);

    final bankModels = details.bankInfos
        .map(
          (bank) => BankInfoModel(
            id: bank.id,
            profileId: bank.profileId,
            accountHolderName: bank.accountHolderName,
            accountNo: bank.accountNo,
            accountType: bank.accountType,
            ifscCode: bank.ifscCode,
            bankName: bank.bankName,
            branch: bank.branch,
          ),
        )
        .toList();

    final addressModels = details.addresses
        .map(
          (address) => ProfileAddressModel(
            id: address.id,
            profileId: address.profileId,
            cropzId: address.cropzId,
            addressType: address.addressType,
            address1: address.address1,
            address2: address.address2,
            address3: address.address3,
            city: address.city,
            taluk: address.taluk,
            block: address.block,
            district: address.district,
            state: address.state,
            pincode: address.pincode,
            inGst: address.inGst,
            parentCropzId: address.parentCropzId,
          ),
        )
        .toList();

    return localDatasource.saveProfileWithRelations(
      profile: profileModel,
      bankInfos: bankModels,
      addresses: addressModels,
    );
  }
}
