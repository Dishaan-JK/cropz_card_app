import 'dart:convert';

import '../../domain/entities/bank_info.dart';
import '../../domain/entities/cropz_card_details.dart';
import '../../domain/entities/cropz_profile.dart';
import '../../domain/entities/profile_address.dart';

class CropzCardPayloadCodec {
  const CropzCardPayloadCodec();

  String encode(CropzCardDetails details) {
    return jsonEncode(<String, Object?>{
      'profile': _profileMap(details.profile),
      'bank_infos': details.bankInfos.map(_bankMap).toList(growable: false),
      'addresses': details.addresses.map(_addressMap).toList(growable: false),
    });
  }

  CropzCardDetails decode(String jsonPayload) {
    final root = jsonDecode(jsonPayload) as Map<String, dynamic>;
    final profile = CropzProfile(
      id: _asInt(root['profile']?['id']),
      cropzId: _asString(root['profile']?['cropz_id']),
      firmName: _asString(root['profile']?['firm_name']) ?? '',
      ownerName: _asString(root['profile']?['owner_name']),
      mobile: _asString(root['profile']?['mobile']) ?? '',
      whatsapp: _asString(root['profile']?['whatsapp']),
      email: _asString(root['profile']?['email']),
      gstNo: _asString(root['profile']?['gst_no']),
      slNo: _asString(root['profile']?['sl_no']),
      slExpiryDate: _asString(root['profile']?['sl_expiry_date']),
      plNo: _asString(root['profile']?['pl_no']),
      retailFlNo: _asString(root['profile']?['retail_fl_no']),
      retailFlExpiryDate: _asString(root['profile']?['retail_fl_expiry_date']),
      wsFlNo: _asString(root['profile']?['ws_fl_no']),
      wsFlExpiryDate: _asString(root['profile']?['ws_fl_expiry_date']),
      fmsRetailId: _asString(root['profile']?['fms_retail_id']),
      fmsWsId: _asString(root['profile']?['fms_ws_id']),
      gstDocument: _asString(root['profile']?['gst_document']),
      slDocument: _asString(root['profile']?['sl_document']),
      plDocument: _asString(root['profile']?['pl_document']),
      flDocument: _asString(root['profile']?['fl_document']),
      profilePicture: _asString(root['profile']?['profile_picture']),
      companies: _asString(root['profile']?['companies']),
      upiId: _asString(root['profile']?['upi_id']),
      qrCode: _asString(root['profile']?['qr_code']),
      transport: _asString(root['profile']?['transport']),
    );

    final banks = (root['bank_infos'] as List<dynamic>? ?? const <dynamic>[])
        .map((entry) {
          final map = entry as Map<String, dynamic>;
          return BankInfo(
            id: _asInt(map['id']),
            profileId: _asInt(map['profile_id']),
            accountHolderName: _asString(map['account_holder_name']),
            accountNo: _asString(map['account_no']),
            accountType: _asString(map['account_type']),
            ifscCode: _asString(map['ifsc_code']),
            bankName: _asString(map['bank_name']),
            branch: _asString(map['branch']),
          );
        })
        .toList(growable: false);

    final addresses = (root['addresses'] as List<dynamic>? ?? const <dynamic>[])
        .map((entry) {
          final map = entry as Map<String, dynamic>;
          return ProfileAddress(
            id: _asInt(map['id']),
            profileId: _asInt(map['profile_id']),
            cropzId: _asString(map['cropz_id']),
            addressType: _asString(map['address_type']),
            address1: _asString(map['address1']),
            address2: _asString(map['address2']),
            address3: _asString(map['address3']),
            city: _asString(map['city']),
            taluk: _asString(map['taluk']),
            block: _asString(map['block']),
            district: _asString(map['district']),
            state: _asString(map['state']),
            pincode: _asString(map['pincode']),
            inGst: map['in_gst'] == true,
            parentCropzId: _asString(map['parent_cropz_id']),
          );
        })
        .toList(growable: false);

    return CropzCardDetails(profile: profile, bankInfos: banks, addresses: addresses);
  }

  Map<String, Object?> _profileMap(CropzProfile p) => <String, Object?>{
    'id': p.id,
    'cropz_id': p.cropzId,
    'firm_name': p.firmName,
    'owner_name': p.ownerName,
    'mobile': p.mobile,
    'whatsapp': p.whatsapp,
    'email': p.email,
    'gst_no': p.gstNo,
    'sl_no': p.slNo,
    'sl_expiry_date': p.slExpiryDate,
    'pl_no': p.plNo,
    'retail_fl_no': p.retailFlNo,
    'retail_fl_expiry_date': p.retailFlExpiryDate,
    'ws_fl_no': p.wsFlNo,
    'ws_fl_expiry_date': p.wsFlExpiryDate,
    'fms_retail_id': p.fmsRetailId,
    'fms_ws_id': p.fmsWsId,
    'gst_document': p.gstDocument,
    'sl_document': p.slDocument,
    'pl_document': p.plDocument,
    'fl_document': p.flDocument,
    'profile_picture': p.profilePicture,
    'companies': p.companies,
    'upi_id': p.upiId,
    'qr_code': p.qrCode,
    'transport': p.transport,
  };

  Map<String, Object?> _bankMap(BankInfo b) => <String, Object?>{
    'id': b.id,
    'profile_id': b.profileId,
    'account_holder_name': b.accountHolderName,
    'account_no': b.accountNo,
    'account_type': b.accountType,
    'ifsc_code': b.ifscCode,
    'bank_name': b.bankName,
    'branch': b.branch,
  };

  Map<String, Object?> _addressMap(ProfileAddress a) => <String, Object?>{
    'id': a.id,
    'profile_id': a.profileId,
    'cropz_id': a.cropzId,
    'address_type': a.addressType,
    'address1': a.address1,
    'address2': a.address2,
    'address3': a.address3,
    'city': a.city,
    'taluk': a.taluk,
    'block': a.block,
    'district': a.district,
    'state': a.state,
    'pincode': a.pincode,
    'in_gst': a.inGst,
    'parent_cropz_id': a.parentCropzId,
  };

  String? _asString(Object? value) {
    if (value == null) {
      return null;
    }
    final str = value.toString();
    return str.isEmpty ? null : str;
  }

  int? _asInt(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value.toString());
  }
}
