import '../entities/bank_info.dart';
import '../entities/cropz_card_details.dart';
import '../entities/cropz_profile.dart';
import '../entities/profile_address.dart';

abstract class CropzCardRepository {
  Future<List<CropzProfile>> getAllProfiles();
  Future<List<BankInfo>> getBankInfosByProfileId(int profileId);
  Future<List<ProfileAddress>> getAddressesByProfileId(int profileId);
  Future<CropzCardDetails> getCardDetailsByProfileId(int profileId);
  Future<int> saveCardDetails(CropzCardDetails details);
}
