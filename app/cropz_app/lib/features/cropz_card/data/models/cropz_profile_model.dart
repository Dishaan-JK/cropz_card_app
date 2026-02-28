import '../../domain/entities/cropz_profile.dart';

class CropzProfileModel extends CropzProfile {
  const CropzProfileModel({
    super.id,
    super.cropzId,
    required super.firmName,
    super.ownerName,
    required super.mobile,
    super.whatsapp,
    super.email,
    super.gstNo,
    super.slNo,
    super.slExpiryDate,
    super.plNo,
    super.retailFlNo,
    super.retailFlExpiryDate,
    super.wsFlNo,
    super.wsFlExpiryDate,
    super.fmsRetailId,
    super.fmsWsId,
    super.gstDocument,
    super.slDocument,
    super.plDocument,
    super.flDocument,
    super.profilePicture,
    super.companies,
    super.upiId,
    super.qrCode,
    super.transport,
  });

  factory CropzProfileModel.fromEntity(CropzProfile profile) {
    return CropzProfileModel(
      id: profile.id,
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
    );
  }

  factory CropzProfileModel.fromMap(Map<String, Object?> map) {
    String? readString(List<String> keys) {
      for (final key in keys) {
        final value = map[key];
        if (value is String) {
          return value;
        }
      }
      return null;
    }

    return CropzProfileModel(
      id: map['id'] as int?,
      cropzId: readString(const ['cropz_id', 'cropzid']),
      firmName: readString(const ['firm_name', 'firmname']) ?? '',
      ownerName: readString(const ['owner_name', 'ownername']),
      mobile: readString(const ['mobile']) ?? '',
      whatsapp: readString(const ['whatsapp']),
      email: readString(const ['email']),
      gstNo: readString(const ['gst_no', 'gstno']),
      slNo: readString(const ['sl_no', 'slno']),
      slExpiryDate: readString(const [
        'sl_expiry_date',
        'slexpirydate',
        'slexpdate',
      ]),
      plNo: readString(const ['pl_no', 'plno']),
      retailFlNo: readString(const ['retail_fl_no', 'retailflno']),
      retailFlExpiryDate: readString(const [
        'retail_fl_expiry_date',
        'retailflexpirydate',
        'retailflexpdate',
      ]),
      wsFlNo: readString(const ['ws_fl_no', 'wsflno']),
      wsFlExpiryDate: readString(const [
        'ws_fl_expiry_date',
        'wsflexpirydate',
        'wsflexpdate',
      ]),
      fmsRetailId: readString(const ['fms_retail_id', 'fmsretailid']),
      fmsWsId: readString(const ['fms_ws_id', 'fmswsid']),
      gstDocument: readString(const ['gst_document']),
      slDocument: readString(const ['sl_document']),
      plDocument: readString(const ['pl_document']),
      flDocument: readString(const ['fl_document']),
      profilePicture: readString(const ['profile_picture', 'profilepicture']),
      companies: map['companies'] as String?,
      upiId: readString(const ['upiid', 'upi_id']),
      qrCode: readString(const ['qrcode', 'qr_code', 'qr code']),
      transport: readString(const ['transport']),
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'cropzid': cropzId,
      'firmname': firmName,
      'ownername': ownerName,
      'mobile': mobile,
      'whatsapp': whatsapp,
      'email': email,
      'gstno': gstNo,
      'slno': slNo,
      'slexpdate': slExpiryDate,
      'plno': plNo,
      'retailflno': retailFlNo,
      'retailflexpdate': retailFlExpiryDate,
      'wsflno': wsFlNo,
      'wsflexpdate': wsFlExpiryDate,
      'fmsretailid': fmsRetailId,
      'fmswsid': fmsWsId,
      'gst_document': gstDocument,
      'sl_document': slDocument,
      'pl_document': plDocument,
      'fl_document': flDocument,
      'profile_picture': profilePicture,
      'companies': companies,
      'upiid': upiId,
      'qrcode': qrCode,
      'transport': transport,
    };
  }
}
