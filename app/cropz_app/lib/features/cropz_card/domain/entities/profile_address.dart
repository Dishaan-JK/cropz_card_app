class ProfileAddress {
  const ProfileAddress({
    this.id,
    this.profileId,
    this.cropzId,
    this.addressType,
    this.address1,
    this.address2,
    this.address3,
    this.city,
    this.taluk,
    this.block,
    this.district,
    this.state,
    this.pincode,
    this.inGst,
    this.parentCropzId,
  });

  final int? id;
  final int? profileId;
  final String? cropzId;
  final String? addressType;
  final String? address1;
  final String? address2;
  final String? address3;
  final String? city;
  final String? taluk;
  final String? block;
  final String? district;
  final String? state;
  final String? pincode;
  final bool? inGst;
  final String? parentCropzId;
}
