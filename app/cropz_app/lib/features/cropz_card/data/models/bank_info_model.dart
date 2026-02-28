import '../../domain/entities/bank_info.dart';

class BankInfoModel extends BankInfo {
  const BankInfoModel({
    super.id,
    super.profileId,
    super.accountHolderName,
    super.accountNo,
    super.accountType,
    super.ifscCode,
    super.bankName,
    super.branch,
  });

  factory BankInfoModel.fromMap(Map<String, Object?> map) {
    String? readString(List<String> keys) {
      for (final key in keys) {
        final value = map[key];
        if (value is String) {
          return value;
        }
      }
      return null;
    }

    return BankInfoModel(
      id: map['id'] as int?,
      profileId: map['profile_id'] as int?,
      accountHolderName: readString(const ['name', 'account_holder_name']),
      accountNo: readString(const ['accountno', 'account_no']),
      accountType: readString(const ['accounttype', 'account_type']),
      ifscCode: readString(const ['ifsccode', 'ifsc_code']),
      bankName: readString(const ['bankname', 'bank_name']),
      branch: readString(const ['branch']),
    );
  }

  Map<String, Object?> toMap({int? overrideProfileId}) {
    return <String, Object?>{
      'id': id,
      'profile_id': overrideProfileId ?? profileId,
      'name': accountHolderName,
      'accountno': accountNo,
      'accounttype': accountType,
      'ifsccode': ifscCode,
      'bankname': bankName,
      'branch': branch,
    };
  }
}
