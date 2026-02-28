class BankInfo {
  const BankInfo({
    this.id,
    this.profileId,
    this.accountHolderName,
    this.accountNo,
    this.accountType,
    this.ifscCode,
    this.bankName,
    this.branch,
  });

  final int? id;
  final int? profileId;
  final String? accountHolderName;
  final String? accountNo;
  final String? accountType;
  final String? ifscCode;
  final String? bankName;
  final String? branch;
}
