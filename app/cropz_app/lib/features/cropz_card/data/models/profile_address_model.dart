import '../../domain/entities/profile_address.dart';

class ProfileAddressModel extends ProfileAddress {
  const ProfileAddressModel({
    super.id,
    super.profileId,
    super.cropzId,
    super.addressType,
    super.address1,
    super.address2,
    super.address3,
    super.city,
    super.taluk,
    super.block,
    super.district,
    super.state,
    super.pincode,
    super.inGst,
    super.parentCropzId,
  });

  factory ProfileAddressModel.fromMap(Map<String, Object?> map) {
    String? readString(List<String> keys) {
      for (final key in keys) {
        final value = map[key];
        if (value is String) {
          return value;
        }
      }
      return null;
    }

    final inGstValue = (map['ingst'] ?? map['in_gst']) as int?;
    return ProfileAddressModel(
      id: map['id'] as int?,
      profileId: map['profile_id'] as int?,
      cropzId: readString(const ['cropzid', 'cropz_id']),
      addressType: readString(const ['addresstype', 'address_type']),
      address1: readString(const ['address1']),
      address2: readString(const ['address2']),
      address3: readString(const ['address3']),
      city: readString(const ['city']),
      taluk: readString(const ['taluk']),
      block: readString(const ['block']),
      district: readString(const ['district']),
      state: readString(const ['state']),
      pincode: readString(const ['pincode']),
      inGst: inGstValue == null ? null : inGstValue == 1,
      parentCropzId: readString(const ['parentcropzid', 'parent_cropz_id']),
    );
  }

  Map<String, Object?> toMap({int? overrideProfileId}) {
    return <String, Object?>{
      'id': id,
      'profile_id': overrideProfileId ?? profileId,
      'cropzid': cropzId,
      'addresstype': addressType,
      'address1': address1,
      'address2': address2,
      'address3': address3,
      'city': city,
      'taluk': taluk,
      'block': block,
      'district': district,
      'state': state,
      'pincode': pincode,
      'ingst': inGst == null ? null : (inGst! ? 1 : 0),
      'parentcropzid': parentCropzId,
    };
  }
}
