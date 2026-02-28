import 'bank_info.dart';
import 'cropz_profile.dart';
import 'profile_address.dart';

class CropzCardDetails {
  const CropzCardDetails({
    required this.profile,
    this.bankInfos = const [],
    this.addresses = const [],
  });

  final CropzProfile profile;
  final List<BankInfo> bankInfos;
  final List<ProfileAddress> addresses;
}
