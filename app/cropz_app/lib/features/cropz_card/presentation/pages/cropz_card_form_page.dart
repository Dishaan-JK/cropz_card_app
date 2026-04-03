import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/entities/bank_info.dart';
import '../../domain/entities/cropz_card_details.dart';
import '../../domain/entities/cropz_profile.dart';
import '../../domain/entities/profile_address.dart';
import 'cropz_card_preview_page.dart';
import '../providers/cropz_card_providers.dart';
import '../../../../shared/data/local/company_suggestions_data_source.dart';
import '../../../../shared/data/local/pincode_lookup_data_source.dart';
import '../../../../shared/presentation/services/access_permission_service.dart';

class CropzCardFormPage extends ConsumerStatefulWidget {
  const CropzCardFormPage({super.key, this.initialDetails});

  final CropzCardDetails? initialDetails;

  @override
  ConsumerState<CropzCardFormPage> createState() => _CropzCardFormPageState();
}

class _CropzCardFormPageState extends ConsumerState<CropzCardFormPage> {
  final AccessPermissionService _accessPermissionService =
      const AccessPermissionService();
  final _formKey = GlobalKey<FormState>();
  final _pincodeLookup = const PincodeLookupDataSource();
  final _companySuggestionsSource = const CompanySuggestionsDataSource();
  final _companyInputController = TextEditingController();
  TextEditingController? _companyFieldController;
  FocusNode? _companyFieldFocusNode;
  bool _isPincodeLookupReady = false;
  List<String> _companySuggestions = const <String>[];
  List<String> _selectedCompanies = <String>[];

  late final TextEditingController _firmNameController;
  late final TextEditingController _ownerNameController;
  late final TextEditingController _mobileController;
  late final TextEditingController _whatsappController;
  late final TextEditingController _emailController;
  late final TextEditingController _gstController;
  late final TextEditingController _upiController;
  late final TextEditingController _transportController;
  late final TextEditingController _slNoController;
  late final TextEditingController _slExpiryDateController;
  late final TextEditingController _plNoController;
  late final TextEditingController _retailFlNoController;
  late final TextEditingController _retailFlExpiryDateController;
  late final TextEditingController _wsFlNoController;
  late final TextEditingController _wsFlExpiryDateController;
  late final TextEditingController _fmsRetailIdController;
  late final TextEditingController _fmsWsIdController;

  late final List<_BankAccountFormData> _bankAccounts;
  late final List<_AddressFormData> _addresses;
  String? _profileImagePath;
  String? _seedLicenseDocumentPath;
  String? _pesticideLicenseDocumentPath;
  String? _fertilizerLicenseDocumentPath;
  String? _gstDocumentPath;
  int _currentStep = 0;

  bool get _isEdit => widget.initialDetails != null;

  @override
  void initState() {
    super.initState();
    final profile = widget.initialDetails?.profile;
    _firmNameController = TextEditingController(text: profile?.firmName ?? '');
    _ownerNameController = TextEditingController(
      text: profile?.ownerName ?? '',
    );
    _mobileController = TextEditingController(text: profile?.mobile ?? '');
    _whatsappController = TextEditingController(text: profile?.whatsapp ?? '');
    _emailController = TextEditingController(text: profile?.email ?? '');
    _gstController = TextEditingController(text: profile?.gstNo ?? '');
    _upiController = TextEditingController(text: profile?.upiId ?? '');
    _transportController = TextEditingController(
      text: profile?.transport ?? '',
    );
    _slNoController = TextEditingController(text: profile?.slNo ?? '');
    _slExpiryDateController = TextEditingController(
      text: profile?.slExpiryDate ?? '',
    );
    _plNoController = TextEditingController(text: profile?.plNo ?? '');
    _retailFlNoController = TextEditingController(
      text: profile?.retailFlNo ?? '',
    );
    _retailFlExpiryDateController = TextEditingController(
      text: profile?.retailFlExpiryDate ?? '',
    );
    _wsFlNoController = TextEditingController(text: profile?.wsFlNo ?? '');
    _wsFlExpiryDateController = TextEditingController(
      text: profile?.wsFlExpiryDate ?? '',
    );
    _fmsRetailIdController = TextEditingController(
      text: profile?.fmsRetailId ?? '',
    );
    _fmsWsIdController = TextEditingController(text: profile?.fmsWsId ?? '');
    _profileImagePath = profile?.profilePicture;
    _seedLicenseDocumentPath = profile?.slDocument;
    _pesticideLicenseDocumentPath = profile?.plDocument;
    _fertilizerLicenseDocumentPath = profile?.flDocument;
    _gstDocumentPath = profile?.gstDocument;
    _selectedCompanies = (profile?.companies ?? '')
        .split(',')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();

    final initialBanks = widget.initialDetails?.bankInfos ?? const <BankInfo>[];
    final initialAddresses =
        widget.initialDetails?.addresses ?? const <ProfileAddress>[];

    _bankAccounts = initialBanks.isNotEmpty
        ? initialBanks.map(_BankAccountFormData.fromEntity).toList()
        : <_BankAccountFormData>[_BankAccountFormData.empty()];

    _addresses = initialAddresses.isNotEmpty
        ? initialAddresses.map(_AddressFormData.fromEntity).toList()
        : <_AddressFormData>[_AddressFormData.empty()];

    Future<void>(() => _preparePincodeLookup());
    Future<void>(() => _loadCompanySuggestions());
    Future<void>(() => _hydrateAddressLookups());
  }

  Future<void> _loadCompanySuggestions() async {
    try {
      final list = await _companySuggestionsSource.getAll();
      if (!mounted) {
        return;
      }
      setState(() => _companySuggestions = list);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _companySuggestions = const <String>[]);
    }
  }

  Future<void> _preparePincodeLookup() async {
    try {
      await _pincodeLookup.preload();
      if (!mounted) {
        return;
      }
      setState(() => _isPincodeLookupReady = true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _isPincodeLookupReady = false);
    }
  }

  @override
  void dispose() {
    _firmNameController.dispose();
    _ownerNameController.dispose();
    _mobileController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    _gstController.dispose();
    _upiController.dispose();
    _transportController.dispose();
    _slNoController.dispose();
    _slExpiryDateController.dispose();
    _plNoController.dispose();
    _retailFlNoController.dispose();
    _retailFlExpiryDateController.dispose();
    _wsFlNoController.dispose();
    _wsFlExpiryDateController.dispose();
    _fmsRetailIdController.dispose();
    _fmsWsIdController.dispose();
    _companyInputController.dispose();
    for (final bank in _bankAccounts) {
      bank.dispose();
    }
    for (final address in _addresses) {
      address.dispose();
    }
    super.dispose();
  }

  void _addBankAccount() {
    setState(() => _bankAccounts.add(_BankAccountFormData.empty()));
  }

  void _removeBankAccount(int index) {
    if (_bankAccounts.length == 1) {
      return;
    }
    setState(() {
      final removed = _bankAccounts.removeAt(index);
      removed.dispose();
    });
  }

  void _addAddress() {
    setState(() => _addresses.add(_AddressFormData.empty()));
  }

  void _removeAddress(int index) {
    if (_addresses.length == 1) {
      return;
    }
    setState(() {
      final removed = _addresses.removeAt(index);
      removed.dispose();
    });
  }

  Future<void> _hydrateAddressLookups() async {
    for (var i = 0; i < _addresses.length; i++) {
      final pincode = _addresses[i].pincode.text.trim();
      if (RegExp(r'^\d{6}$').hasMatch(pincode)) {
        await _onAddressPincodeChanged(i, pincode);
      }
    }
  }

  Future<void> _onAddressPincodeChanged(int index, String value) async {
    if (index < 0 || index >= _addresses.length) {
      return;
    }
    final pincode = value.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(pincode)) {
      if (mounted) {
        setState(() {
          _addresses[index].villageOptions = const [];
          _addresses[index].lookupStatus = null;
        });
      }
      return;
    }

    try {
      if (!_isPincodeLookupReady) {
        await _pincodeLookup.preload();
        _isPincodeLookupReady = true;
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _addresses[index].lookupStatus =
              'Pincode data unavailable. Please try again.';
        });
      }
      return;
    }

    final lookup = await _pincodeLookup.findByPincode(pincode);
    if (!mounted || index < 0 || index >= _addresses.length) {
      return;
    }
    final address = _addresses[index];
    if (lookup == null) {
      setState(() {
        address.villageOptions = const [];
        address.lookupStatus =
            'No mapping found for this pincode. You can enter village manually.';
      });
      return;
    }

    setState(() {
      if (lookup.state.isNotEmpty) {
        address.state.text = lookup.state;
      }
      if (lookup.district.isNotEmpty) {
        address.district.text = lookup.district;
      }
      if (lookup.block.isNotEmpty) {
        address.block.text = lookup.block;
        address.taluk.text = lookup.block;
      }
      address.villageOptions = lookup.villages;
      address.lookupStatus = 'Auto-filled from pincode mapping.';
      final currentCity = address.city.text.trim();
      if (lookup.villages.isNotEmpty &&
          !lookup.villages.contains(currentCity)) {
        address.city.text = lookup.villages.first;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final profile = CropzProfile(
      id: widget.initialDetails?.profile.id,
      cropzId: widget.initialDetails?.profile.cropzId,
      firmName: _firmNameController.text.trim(),
      ownerName: _ownerNameController.text.trim().isEmpty
          ? null
          : _ownerNameController.text.trim(),
      mobile: _mobileController.text.trim(),
      whatsapp: _whatsappController.text.trim().isEmpty
          ? null
          : _whatsappController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      gstNo: _gstController.text.trim().isEmpty
          ? null
          : _gstController.text.trim(),
      upiId: _upiController.text.trim().isEmpty
          ? null
          : _upiController.text.trim(),
      transport: _transportController.text.trim().isEmpty
          ? null
          : _transportController.text.trim(),
      slNo: _slNoController.text.trim().isEmpty
          ? null
          : _slNoController.text.trim(),
      slExpiryDate: _slExpiryDateController.text.trim().isEmpty
          ? null
          : _slExpiryDateController.text.trim(),
      plNo: _plNoController.text.trim().isEmpty
          ? null
          : _plNoController.text.trim(),
      retailFlNo: _retailFlNoController.text.trim().isEmpty
          ? null
          : _retailFlNoController.text.trim(),
      retailFlExpiryDate: _retailFlExpiryDateController.text.trim().isEmpty
          ? null
          : _retailFlExpiryDateController.text.trim(),
      wsFlNo: _wsFlNoController.text.trim().isEmpty
          ? null
          : _wsFlNoController.text.trim(),
      wsFlExpiryDate: _wsFlExpiryDateController.text.trim().isEmpty
          ? null
          : _wsFlExpiryDateController.text.trim(),
      fmsRetailId: _fmsRetailIdController.text.trim().isEmpty
          ? null
          : _fmsRetailIdController.text.trim(),
      fmsWsId: _fmsWsIdController.text.trim().isEmpty
          ? null
          : _fmsWsIdController.text.trim(),
      gstDocument: _gstDocumentPath,
      slDocument: _seedLicenseDocumentPath,
      plDocument: _pesticideLicenseDocumentPath,
      flDocument: _fertilizerLicenseDocumentPath,
      profilePicture: _profileImagePath,
      companies: _selectedCompanies.isEmpty
          ? null
          : _selectedCompanies.join(', '),
      qrCode: widget.initialDetails?.profile.qrCode,
    );

    final bankInfos = _bankAccounts
        .where((bank) => bank.hasAnyInput)
        .map(
          (bank) => BankInfo(
            id: bank.id,
            profileId: widget.initialDetails?.profile.id,
            accountHolderName: bank.accountHolderName.text.trim().isEmpty
                ? null
                : bank.accountHolderName.text.trim(),
            accountNo: bank.accountNo.text.trim().isEmpty
                ? null
                : bank.accountNo.text.trim(),
            accountType: bank.accountType.text.trim().isEmpty
                ? null
                : bank.accountType.text.trim(),
            ifscCode: bank.ifscCode.text.trim().isEmpty
                ? null
                : bank.ifscCode.text.trim(),
            bankName: bank.bankName.text.trim().isEmpty
                ? null
                : bank.bankName.text.trim(),
            branch: bank.branch.text.trim().isEmpty
                ? null
                : bank.branch.text.trim(),
          ),
        )
        .toList();

    final addresses = _addresses
        .where((address) => address.hasAnyInput)
        .map(
          (address) => ProfileAddress(
            id: address.id,
            profileId: widget.initialDetails?.profile.id,
            cropzId: widget.initialDetails?.profile.cropzId,
            addressType: address.addressType.text.trim().isEmpty
                ? 'shop'
                : address.addressType.text.trim(),
            address1: address.address1.text.trim().isEmpty
                ? null
                : address.address1.text.trim(),
            address2: address.address2.text.trim().isEmpty
                ? null
                : address.address2.text.trim(),
            address3: address.address3.text.trim().isEmpty
                ? null
                : address.address3.text.trim(),
            city: address.city.text.trim().isEmpty
                ? null
                : address.city.text.trim(),
            taluk: address.taluk.text.trim().isEmpty
                ? null
                : address.taluk.text.trim(),
            block: address.block.text.trim().isEmpty
                ? null
                : address.block.text.trim(),
            district: address.district.text.trim().isEmpty
                ? null
                : address.district.text.trim(),
            state: address.state.text.trim().isEmpty
                ? null
                : address.state.text.trim(),
            pincode: address.pincode.text.trim().isEmpty
                ? null
                : address.pincode.text.trim(),
            inGst: address.inGst,
            parentCropzId: address.parentCropzId.text.trim().isEmpty
                ? null
                : address.parentCropzId.text.trim(),
          ),
        )
        .toList();

    final details = CropzCardDetails(
      profile: profile,
      bankInfos: bankInfos,
      addresses: addresses,
    );

    final saved = await ref
        .read(cropzCardFormControllerProvider.notifier)
        .saveCardDetails(details);
    if (!mounted) {
      return;
    }
    if (saved) {
      final profileId = widget.initialDetails?.profile.id;
      if (profileId != null) {
        ref.invalidate(cropzCardDetailsProvider(profileId));
      }
      Navigator.of(context).pop();
      return;
    }

    final message = ref.read(cropzCardFormControllerProvider).errorMessage;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message ?? 'Save failed')));
  }

  Future<void> _pickAndStoreDocument(_DocumentType type) async {
    final hasPermission = await _accessPermissionService.requestStorageAccess(
      context,
      reason:
          'Cropz Card needs storage/media access to select and attach license documents.',
    );
    if (!hasPermission) {
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg', 'webp'],
      allowMultiple: false,
    );
    if (result == null || result.files.single.path == null) {
      return;
    }

    final sourcePath = result.files.single.path!;
    final sourceFile = File(sourcePath);
    if (!sourceFile.existsSync()) {
      return;
    }

    final appDocDir = await getApplicationDocumentsDirectory();
    final targetDir = Directory(p.join(appDocDir.path, 'cropz_documents'));
    if (!targetDir.existsSync()) {
      targetDir.createSync(recursive: true);
    }

    final extension = p.extension(sourceFile.path).toLowerCase();
    final name = type.name;
    final fileName =
        '${name}_${DateTime.now().millisecondsSinceEpoch}$extension';
    final targetPath = p.join(targetDir.path, fileName);
    final copied = await sourceFile.copy(targetPath);

    setState(() {
      switch (type) {
        case _DocumentType.seedLicense:
          _seedLicenseDocumentPath = copied.path;
        case _DocumentType.pesticideLicense:
          _pesticideLicenseDocumentPath = copied.path;
        case _DocumentType.fertilizerLicense:
          _fertilizerLicenseDocumentPath = copied.path;
        case _DocumentType.gst:
          _gstDocumentPath = copied.path;
      }
    });
  }

  Future<void> _pickAndStoreProfileImage() async {
    final hasPermission = await _accessPermissionService.requestStorageAccess(
      context,
      reason:
          'Cropz Card needs storage/media access to select a profile image.',
    );
    if (!hasPermission) {
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['png', 'jpg', 'jpeg', 'webp'],
      allowMultiple: false,
    );
    if (result == null || result.files.single.path == null) {
      return;
    }

    final sourcePath = result.files.single.path!;
    final sourceFile = File(sourcePath);
    if (!sourceFile.existsSync()) {
      return;
    }

    final appDocDir = await getApplicationDocumentsDirectory();
    final targetDir = Directory(p.join(appDocDir.path, 'cropz_profile_pics'));
    if (!targetDir.existsSync()) {
      targetDir.createSync(recursive: true);
    }

    final extension = p.extension(sourceFile.path).toLowerCase();
    final fileName =
        'profile_${DateTime.now().millisecondsSinceEpoch}$extension';
    final targetPath = p.join(targetDir.path, fileName);
    final copied = await sourceFile.copy(targetPath);

    setState(() => _profileImagePath = copied.path);
  }

  void _clearProfileImage() {
    setState(() => _profileImagePath = null);
  }

  Future<void> _shareDocument(String? path, String label) async {
    if (path == null || path.isEmpty) {
      return;
    }
    final file = File(path);
    if (!file.existsSync()) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label file is not available on device')),
      );
      return;
    }
    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, name: p.basename(file.path))],
          text: '$label document',
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to share $label document right now')),
      );
    }
  }

  void _showSnack(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openPreview() async {
    final firmName = _firmNameController.text.trim();
    final mobile = _mobileController.text.trim();
    if (firmName.isEmpty || mobile.isEmpty) {
      _showSnack('Please fill Firm Name and Mobile before preview.');
      return;
    }

    final essentialFields = [
      PdfField('Firm Name', firmName),
      PdfField('Mobile', mobile),
      PdfField('Owner Name', _ownerNameController.text.trim()),
      PdfField('WhatsApp', _whatsappController.text.trim()),
    ];

    final businessFields = [
      PdfField('Email', _emailController.text.trim()),
      PdfField('GST Number', _gstController.text.trim()),
      PdfField('UPI ID', _upiController.text.trim()),
      PdfField('Transport', _transportController.text.trim()),
      PdfField('SL No', _slNoController.text.trim()),
      PdfField('SL Expiry Date', _slExpiryDateController.text.trim()),
      PdfField('PL No', _plNoController.text.trim()),
      PdfField('Retail FL No', _retailFlNoController.text.trim()),
      PdfField(
        'Retail FL Expiry Date',
        _retailFlExpiryDateController.text.trim(),
      ),
      PdfField('WS FL No', _wsFlNoController.text.trim()),
      PdfField('WS FL Expiry Date', _wsFlExpiryDateController.text.trim()),
      PdfField('FMS Retail ID', _fmsRetailIdController.text.trim()),
      PdfField('FMS WS ID', _fmsWsIdController.text.trim()),
    ];
    final addresses = _buildAddressesFromForm();
    final bankAccounts = _buildBankAccountsFromForm();

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CropzCardPreviewPage(
          data: CropzCardPreviewData(
            essentialFields: essentialFields,
            businessFields: businessFields,
            bankAccounts: bankAccounts,
            addresses: addresses,
            firmName: firmName,
            mobile: mobile,
            ownerName: _ownerNameController.text.trim(),
            imagePath: _profileImagePath,
            dealerships: _selectedCompanies,
          ),
        ),
      ),
    );
  }

  void _addCompany(String value) {
    final company = value.trim();
    if (company.isEmpty) {
      return;
    }
    final exists = _selectedCompanies.any(
      (item) => item.toLowerCase() == company.toLowerCase(),
    );
    if (exists) {
      return;
    }
    setState(() => _selectedCompanies.add(company));
    _companyInputController.clear();
    _companyFieldController?.clear();
    _companyFieldFocusNode?.requestFocus();
  }

  void _removeCompany(String company) {
    setState(() {
      _selectedCompanies.removeWhere(
        (item) => item.toLowerCase() == company.toLowerCase(),
      );
    });
  }

  List<AddressPreview> _buildAddressesFromForm() {
    return _addresses
        .asMap()
        .entries
        .map((entry) {
          final data = entry.value;
          final type = data.addressType.text.trim();
          final title = type.isEmpty
              ? 'Address ${entry.key + 1}'
              : '${type[0].toUpperCase()}${type.substring(1)} Address';
          final lines = <String>[
            data.address1.text.trim(),
            data.address2.text.trim(),
            data.address3.text.trim(),
            data.city.text.trim(),
            data.taluk.text.trim(),
            data.block.text.trim(),
            data.district.text.trim(),
            data.state.text.trim(),
            data.pincode.text.trim(),
          ].where((value) => value.isNotEmpty).toList();
          return AddressPreview(title: title, lines: lines);
        })
        .where((address) => address.lines.isNotEmpty)
        .toList();
  }

  List<BankPreview> _buildBankAccountsFromForm() {
    return _bankAccounts
        .asMap()
        .entries
        .where((entry) => entry.value.hasAnyInput)
        .map(
          (entry) => BankPreview(
            title: 'Account ${entry.key + 1}',
            fields: [
              PdfField(
                'Account Holder',
                entry.value.accountHolderName.text.trim(),
              ),
              PdfField('Account Number', entry.value.accountNo.text.trim()),
              PdfField('Account Type', entry.value.accountType.text.trim()),
              PdfField('IFSC Code', entry.value.ifscCode.text.trim()),
              PdfField('Bank Name', entry.value.bankName.text.trim()),
              PdfField('Branch', entry.value.branch.text.trim()),
            ],
          ),
        )
        .toList();
  }

  String? _validateExpiryDate(String? value, String label) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return null;
    }
    final parsed = _parseDateStrict(trimmed);
    if (parsed == null) {
      return '$label must be in DD/MM/YYYY format';
    }
    if (!_isAfterToday(parsed)) {
      return '$label must be after today';
    }
    return null;
  }

  DateTime? _parseDateStrict(String input) {
    final match = RegExp(r'^(\d{2})\D(\d{2})\D(\d{4})$').firstMatch(input);
    if (match == null) {
      return null;
    }
    final day = int.tryParse(match.group(1)!);
    final month = int.tryParse(match.group(2)!);
    final year = int.tryParse(match.group(3)!);
    if (day == null || month == null || year == null) {
      return null;
    }
    if (month < 1 || month > 12) {
      return null;
    }
    final maxDay = DateTime(year, month + 1, 0).day;
    if (day < 1 || day > maxDay) {
      return null;
    }
    return DateTime(year, month, day);
  }

  bool _isAfterToday(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return date.isAfter(today);
  }

  void _clearDocument(_DocumentType type) {
    setState(() {
      switch (type) {
        case _DocumentType.seedLicense:
          _seedLicenseDocumentPath = null;
        case _DocumentType.pesticideLicense:
          _pesticideLicenseDocumentPath = null;
        case _DocumentType.fertilizerLicense:
          _fertilizerLicenseDocumentPath = null;
        case _DocumentType.gst:
          _gstDocumentPath = null;
      }
    });
  }

  int get _totalSteps => 6;

  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text('Business'),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
        content: Column(
          children: [
            _ProfileImageCard(
              imagePath: _profileImagePath,
              firmNameController: _firmNameController,
              onPick: _pickAndStoreProfileImage,
              onClear: _clearProfileImage,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _firmNameController,
              decoration: const InputDecoration(
                labelText: 'Firm Name *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Firm name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _mobileController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              decoration: const InputDecoration(
                labelText: 'Mobile *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) {
                  return 'Mobile number is required';
                }
                if (!RegExp(r'^\d{10}$').hasMatch(trimmed)) {
                  return 'Enter a valid 10 digit mobile number';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _ownerNameController,
              decoration: const InputDecoration(
                labelText: 'Owner Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _whatsappController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              decoration: const InputDecoration(
                labelText: 'WhatsApp',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) {
                  return null;
                }
                if (!RegExp(r'^\d{10}$').hasMatch(trimmed)) {
                  return 'Enter a valid 10 digit WhatsApp number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Company Dealerships',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 8),
            Autocomplete<String>(
              optionsBuilder: (textEditingValue) {
                final query = textEditingValue.text.trim().toLowerCase();
                if (query.isEmpty) {
                  return _companySuggestions.take(12);
                }
                return _companySuggestions
                    .where((item) => item.toLowerCase().contains(query))
                    .take(12);
              },
              optionsViewBuilder: (context, onSelected, options) {
                final list = options.toList(growable: false);
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 320,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 220),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            final option = list[index];
                            return ListTile(
                              dense: true,
                              title: Text(option),
                              onTap: () => onSelected(option),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
              onSelected: _addCompany,
              fieldViewBuilder:
                  (context, textController, focusNode, onFieldSubmitted) {
                    _companyFieldController = textController;
                    _companyFieldFocusNode = focusNode;
                    if (_companyInputController.text != textController.text) {
                      _companyInputController.value = textController.value;
                    }
                    return Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: textController,
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                              labelText: 'Add company',
                              border: OutlineInputBorder(),
                            ),
                            onFieldSubmitted: (_) {
                              _addCompany(textController.text);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: 'Add company',
                          onPressed: () => _addCompany(textController.text),
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    );
                  },
            ),
            if (_selectedCompanies.isNotEmpty) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedCompanies
                      .map(
                        (company) => InputChip(
                          label: Text(company),
                          onDeleted: () => _removeCompany(company),
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
            ],
          ],
        ),
      ),
      Step(
        title: const Text('License Info'),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
        content: Column(
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _gstController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'GST Number',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                final upper = value.toUpperCase();
                if (upper != value) {
                  _gstController.value = _gstController.value.copyWith(
                    text: upper,
                    selection: TextSelection.collapsed(offset: upper.length),
                  );
                }
              },
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) {
                  return null;
                }
                final pattern = RegExp(
                  r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$',
                );
                if (!pattern.hasMatch(trimmed.toUpperCase())) {
                  return 'Enter a valid GST number (15 characters)';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _upiController,
              decoration: const InputDecoration(
                labelText: 'UPI ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _transportController,
              decoration: const InputDecoration(
                labelText: 'Transport',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Licenses & IDs',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _slNoController,
              decoration: const InputDecoration(
                labelText: 'SL No',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _slExpiryDateController,
              decoration: const InputDecoration(
                labelText: 'SL Expiry Date (DD-MM-YYYY)',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  _validateExpiryDate(value, 'SL Expiry Date'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _plNoController,
              decoration: const InputDecoration(
                labelText: 'PL No',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _retailFlNoController,
              decoration: const InputDecoration(
                labelText: 'Retail FL No',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _retailFlExpiryDateController,
              decoration: const InputDecoration(
                labelText: 'Retail FL Expiry Date (DD-MM-YYYY)',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  _validateExpiryDate(value, 'Retail FL Expiry Date'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _wsFlNoController,
              decoration: const InputDecoration(
                labelText: 'WS FL No',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _wsFlExpiryDateController,
              decoration: const InputDecoration(
                labelText: 'WS FL Expiry Date (DD-MM-YYYY)',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  _validateExpiryDate(value, 'WS FL Expiry Date'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _fmsRetailIdController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'FMS Retail ID',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) {
                  return null;
                }
                if (!RegExp(r'^\d+$').hasMatch(trimmed)) {
                  return 'FMS Retail ID must be numeric only';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _fmsWsIdController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'FMS WS ID',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) {
                  return null;
                }
                if (!RegExp(r'^\d+$').hasMatch(trimmed)) {
                  return 'FMS WS ID must be numeric only';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      Step(
        title: const Text('Bank Accounts'),
        isActive: _currentStep >= 2,
        state: _currentStep > 2 ? StepState.complete : StepState.indexed,
        content: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _addBankAccount,
                icon: const Icon(Icons.add),
                label: const Text('Add account'),
              ),
            ),
            for (var i = 0; i < _bankAccounts.length; i++) ...[
              _BankAccountSection(
                index: i,
                data: _bankAccounts[i],
                canRemove: _bankAccounts.length > 1,
                onRemove: () => _removeBankAccount(i),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
      Step(
        title: const Text('Addresses'),
        isActive: _currentStep >= 3,
        state: _currentStep > 3 ? StepState.complete : StepState.indexed,
        content: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _addAddress,
                icon: const Icon(Icons.add),
                label: const Text('Add address'),
              ),
            ),
            for (var i = 0; i < _addresses.length; i++) ...[
              _AddressSection(
                index: i,
                data: _addresses[i],
                canRemove: _addresses.length > 1,
                onRemove: () => _removeAddress(i),
                onInGstChanged: (value) =>
                    setState(() => _addresses[i].inGst = value),
                onPincodeChanged: (value) => _onAddressPincodeChanged(i, value),
                isLookupReady: _isPincodeLookupReady,
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
      Step(
        title: const Text('Documents'),
        isActive: _currentStep >= 4,
        state: _currentStep > 4 ? StepState.complete : StepState.indexed,
        content: Column(
          children: [
            _DocumentFieldCard(
              label: 'Seed License',
              path: _seedLicenseDocumentPath,
              onPick: () => _pickAndStoreDocument(_DocumentType.seedLicense),
              onShare: () =>
                  _shareDocument(_seedLicenseDocumentPath, 'Seed License'),
              onClear: () => _clearDocument(_DocumentType.seedLicense),
            ),
            const SizedBox(height: 12),
            _DocumentFieldCard(
              label: 'Pesticide License',
              path: _pesticideLicenseDocumentPath,
              onPick: () =>
                  _pickAndStoreDocument(_DocumentType.pesticideLicense),
              onShare: () => _shareDocument(
                _pesticideLicenseDocumentPath,
                'Pesticide License',
              ),
              onClear: () => _clearDocument(_DocumentType.pesticideLicense),
            ),
            const SizedBox(height: 12),
            _DocumentFieldCard(
              label: 'Fertilizer License',
              path: _fertilizerLicenseDocumentPath,
              onPick: () =>
                  _pickAndStoreDocument(_DocumentType.fertilizerLicense),
              onShare: () => _shareDocument(
                _fertilizerLicenseDocumentPath,
                'Fertilizer License',
              ),
              onClear: () => _clearDocument(_DocumentType.fertilizerLicense),
            ),
            const SizedBox(height: 12),
            _DocumentFieldCard(
              label: 'GST',
              path: _gstDocumentPath,
              onPick: () => _pickAndStoreDocument(_DocumentType.gst),
              onShare: () => _shareDocument(_gstDocumentPath, 'GST'),
              onClear: () => _clearDocument(_DocumentType.gst),
            ),
          ],
        ),
      ),
      Step(
        title: const Text('Review & Save'),
        isActive: _currentStep >= 5,
        state: StepState.indexed,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Review all sections. You can tap any previous section title to edit before saving.',
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _openPreview,
              icon: const Icon(Icons.preview_outlined),
              label: const Text('Preview & Share'),
            ),
          ],
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final saveState = ref.watch(cropzCardFormControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Cropz Card' : 'Create Cropz Card'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF7F9FB), Color(0xFFEFF6FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.disabled,
              child: SizedBox(
                height: constraints.maxHeight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Builder(
                        builder: (context) {
                          final steps = _buildSteps();
                          final isLast = _currentStep == _totalSteps - 1;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _StepHeaderBar(
                                currentStep: _currentStep,
                                steps: steps,
                                onStepTapped: (step) =>
                                    setState(() => _currentStep = step),
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: Container(
                                      key: ValueKey(_currentStep),
                                      child: steps[_currentStep].content,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  FilledButton(
                                    onPressed: saveState.isSaving
                                        ? null
                                        : () async {
                                            if (_currentStep <
                                                _totalSteps - 1) {
                                              setState(() => _currentStep += 1);
                                              return;
                                            }
                                            await _submit();
                                          },
                                    child: Text(
                                      saveState.isSaving
                                          ? 'Saving...'
                                          : isLast
                                          ? 'Save'
                                          : 'Next',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (_currentStep > 0)
                                    TextButton(
                                      onPressed: () {
                                        setState(() => _currentStep -= 1);
                                      },
                                      child: const Text('Back'),
                                    ),
                                  const Spacer(),
                                  OutlinedButton.icon(
                                    onPressed: saveState.isSaving
                                        ? null
                                        : _submit,
                                    icon: const Icon(Icons.save_outlined),
                                    label: const Text('Save'),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BankAccountSection extends StatelessWidget {
  const _BankAccountSection({
    required this.index,
    required this.data,
    required this.canRemove,
    required this.onRemove,
  });

  final int index;
  final _BankAccountFormData data;
  final bool canRemove;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: Text('Bank Account ${index + 1}')),
                if (canRemove)
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Remove bank account',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: data.accountHolderName,
              decoration: const InputDecoration(
                labelText: 'Account Holder Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: data.accountNo,
              decoration: const InputDecoration(
                labelText: 'Account Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: data.accountType,
              decoration: const InputDecoration(
                labelText: 'Account Type',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: data.ifscCode,
              decoration: const InputDecoration(
                labelText: 'IFSC Code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: data.bankName,
              decoration: const InputDecoration(
                labelText: 'Bank Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: data.branch,
              decoration: const InputDecoration(
                labelText: 'Branch',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileImageCard extends StatelessWidget {
  const _ProfileImageCard({
    required this.imagePath,
    required this.firmNameController,
    required this.onPick,
    required this.onClear,
  });

  final String? imagePath;
  final TextEditingController firmNameController;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null && imagePath!.isNotEmpty;
    final file = hasImage ? File(imagePath!) : null;
    final hasFile = file != null && file.existsSync();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profile Picture',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: firmNameController,
                  builder: (context, value, _) {
                    final initials = _buildInitials(value.text);
                    return CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.blueGrey.shade100,
                      backgroundImage: hasFile ? FileImage(file!) : null,
                      child: hasFile
                          ? null
                          : Text(
                              initials,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                    );
                  },
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: onPick,
                        icon: const Icon(Icons.photo_camera_outlined),
                        label: Text(hasFile ? 'Replace' : 'Upload'),
                      ),
                      if (hasFile)
                        TextButton(
                          onPressed: onClear,
                          child: const Text('Remove'),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _buildInitials(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return '--';
    }
    final letters = trimmed.replaceAll(RegExp(r'\s+'), '');
    if (letters.isEmpty) {
      return '--';
    }
    return letters.length >= 2
        ? letters.substring(0, 2).toUpperCase()
        : letters.substring(0, 1).toUpperCase();
  }
}

class _StepHeaderBar extends StatelessWidget {
  const _StepHeaderBar({
    required this.currentStep,
    required this.steps,
    required this.onStepTapped,
  });

  final int currentStep;
  final List<Step> steps;
  final ValueChanged<int> onStepTapped;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(steps.length, (index) {
          final isActive = index == currentStep;
          final isComplete = index < currentStep;
          final bgColor = isActive || isComplete
              ? scheme.primary
              : Colors.grey.shade300;
          final fgColor = isActive || isComplete
              ? Colors.white
              : Colors.grey.shade700;

          return Padding(
            padding: EdgeInsets.only(right: index == steps.length - 1 ? 0 : 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => onStepTapped(index),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? scheme.primary.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isActive
                        ? scheme.primary.withOpacity(0.4)
                        : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: bgColor,
                      child: isComplete
                          ? const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            )
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: fgColor,
                              ),
                            ),
                    ),
                    const SizedBox(width: 8),
                    DefaultTextStyle(
                      style: TextStyle(
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: isActive ? scheme.primary : Colors.grey.shade700,
                      ),
                      child: steps[index].title,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

enum _DocumentType { seedLicense, pesticideLicense, fertilizerLicense, gst }

class _DocumentFieldCard extends StatelessWidget {
  const _DocumentFieldCard({
    required this.label,
    required this.path,
    required this.onPick,
    required this.onShare,
    required this.onClear,
  });

  final String label;
  final String? path;
  final VoidCallback onPick;
  final VoidCallback onShare;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.primary,
    );
    final hasFile = path != null && path!.isNotEmpty;
    final fileName = hasFile ? p.basename(path!) : 'No file selected';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: titleStyle),
            const SizedBox(height: 8),
            Text(fileName),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: onPick,
                  icon: const Icon(Icons.upload_file_outlined),
                  label: Text(hasFile ? 'Replace' : 'Upload'),
                ),
                if (hasFile)
                  OutlinedButton.icon(
                    onPressed: onShare,
                    icon: const Icon(Icons.share_outlined),
                    label: const Text('Share'),
                  ),
                if (hasFile)
                  TextButton(onPressed: onClear, child: const Text('Remove')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressSection extends StatelessWidget {
  const _AddressSection({
    required this.index,
    required this.data,
    required this.canRemove,
    required this.onRemove,
    required this.onInGstChanged,
    required this.onPincodeChanged,
    required this.isLookupReady,
  });

  final int index;
  final _AddressFormData data;
  final bool canRemove;
  final VoidCallback onRemove;
  final ValueChanged<bool> onInGstChanged;
  final ValueChanged<String> onPincodeChanged;
  final bool isLookupReady;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: Text('Address ${index + 1}')),
                if (canRemove)
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Remove address',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: data.addressType.text.trim().isEmpty
                  ? null
                  : data.addressType.text.trim().toLowerCase(),
              items: const [
                DropdownMenuItem(value: 'shop', child: Text('Shop')),
                DropdownMenuItem(value: 'godown', child: Text('Godown')),
                DropdownMenuItem(value: 'branch', child: Text('Branch')),
              ],
              decoration: const InputDecoration(
                labelText: 'Address Type',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                data.addressType.text = value ?? '';
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please select an address type';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: data.address1,
              decoration: const InputDecoration(
                labelText: 'Address Line 1',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: data.address2,
              decoration: const InputDecoration(
                labelText: 'Address Line 2',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: data.pincode,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              onChanged: onPincodeChanged,
              decoration: const InputDecoration(
                labelText: 'Pincode',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) {
                  return null;
                }
                if (!RegExp(r'^[1-9][0-9]{5}$').hasMatch(trimmed)) {
                  return 'Enter a valid 6 digit pincode';
                }
                return null;
              },
            ),
            if (!isLookupReady)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'Loading pincode mapping...',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ),
              ),
            if (data.lookupStatus != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    data.lookupStatus!,
                    style: TextStyle(
                      fontSize: 12,
                      color: data.lookupStatus!.startsWith('Auto-filled')
                          ? Colors.green.shade700
                          : Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            TextFormField(
              controller: data.city,
              decoration: const InputDecoration(
                labelText: 'Village / City',
                border: OutlineInputBorder(),
              ),
            ),
            if (data.villageOptions.isNotEmpty) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Suggestions from pincode (tap to fill, or type manually):',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: data.villageOptions
                    .take(12)
                    .map(
                      (village) => ActionChip(
                        label: Text(village),
                        onPressed: () {
                          data.city.text = village;
                        },
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
            const SizedBox(height: 12),
            TextFormField(
              controller: data.block,
              decoration: const InputDecoration(
                labelText: 'Block',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: data.district,
              decoration: const InputDecoration(
                labelText: 'District',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: data.state,
              decoration: const InputDecoration(
                labelText: 'State',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Included in GST'),
              value: data.inGst,
              onChanged: onInGstChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _BankAccountFormData {
  _BankAccountFormData({
    this.id,
    required this.accountHolderName,
    required this.accountNo,
    required this.accountType,
    required this.ifscCode,
    required this.bankName,
    required this.branch,
  });

  factory _BankAccountFormData.empty() {
    return _BankAccountFormData(
      accountHolderName: TextEditingController(),
      accountNo: TextEditingController(),
      accountType: TextEditingController(),
      ifscCode: TextEditingController(),
      bankName: TextEditingController(),
      branch: TextEditingController(),
    );
  }

  factory _BankAccountFormData.fromEntity(BankInfo entity) {
    return _BankAccountFormData(
      id: entity.id,
      accountHolderName: TextEditingController(
        text: entity.accountHolderName ?? '',
      ),
      accountNo: TextEditingController(text: entity.accountNo ?? ''),
      accountType: TextEditingController(text: entity.accountType ?? ''),
      ifscCode: TextEditingController(text: entity.ifscCode ?? ''),
      bankName: TextEditingController(text: entity.bankName ?? ''),
      branch: TextEditingController(text: entity.branch ?? ''),
    );
  }

  final int? id;
  final TextEditingController accountHolderName;
  final TextEditingController accountNo;
  final TextEditingController accountType;
  final TextEditingController ifscCode;
  final TextEditingController bankName;
  final TextEditingController branch;

  bool get hasAnyInput {
    return accountHolderName.text.trim().isNotEmpty ||
        accountNo.text.trim().isNotEmpty ||
        accountType.text.trim().isNotEmpty ||
        ifscCode.text.trim().isNotEmpty ||
        bankName.text.trim().isNotEmpty ||
        branch.text.trim().isNotEmpty;
  }

  void dispose() {
    accountHolderName.dispose();
    accountNo.dispose();
    accountType.dispose();
    ifscCode.dispose();
    bankName.dispose();
    branch.dispose();
  }
}

class _AddressFormData {
  _AddressFormData({
    this.id,
    required this.addressType,
    required this.address1,
    required this.address2,
    required this.address3,
    required this.city,
    required this.taluk,
    required this.block,
    required this.district,
    required this.state,
    required this.pincode,
    required this.parentCropzId,
    this.villageOptions = const <String>[],
    this.lookupStatus,
    this.inGst = false,
  });

  factory _AddressFormData.empty() {
    return _AddressFormData(
      addressType: TextEditingController(text: 'shop'),
      address1: TextEditingController(),
      address2: TextEditingController(),
      address3: TextEditingController(),
      city: TextEditingController(),
      taluk: TextEditingController(),
      block: TextEditingController(),
      district: TextEditingController(),
      state: TextEditingController(),
      pincode: TextEditingController(),
      parentCropzId: TextEditingController(),
      villageOptions: const <String>[],
      lookupStatus: null,
    );
  }

  factory _AddressFormData.fromEntity(ProfileAddress entity) {
    final normalized = (entity.addressType ?? '').trim().toLowerCase();
    final allowed = const {'shop', 'godown', 'branch'};
    final value = allowed.contains(normalized) ? normalized : 'shop';
    return _AddressFormData(
      id: entity.id,
      addressType: TextEditingController(text: value),
      address1: TextEditingController(text: entity.address1 ?? ''),
      address2: TextEditingController(text: entity.address2 ?? ''),
      address3: TextEditingController(text: entity.address3 ?? ''),
      city: TextEditingController(text: entity.city ?? ''),
      taluk: TextEditingController(text: entity.taluk ?? ''),
      block: TextEditingController(text: entity.block ?? ''),
      district: TextEditingController(text: entity.district ?? ''),
      state: TextEditingController(text: entity.state ?? ''),
      pincode: TextEditingController(text: entity.pincode ?? ''),
      parentCropzId: TextEditingController(text: entity.parentCropzId ?? ''),
      villageOptions: const <String>[],
      lookupStatus: null,
      inGst: entity.inGst ?? false,
    );
  }

  final int? id;
  final TextEditingController addressType;
  final TextEditingController address1;
  final TextEditingController address2;
  final TextEditingController address3;
  final TextEditingController city;
  final TextEditingController taluk;
  final TextEditingController block;
  final TextEditingController district;
  final TextEditingController state;
  final TextEditingController pincode;
  final TextEditingController parentCropzId;
  List<String> villageOptions;
  String? lookupStatus;
  bool inGst;

  bool get hasAnyInput {
    return addressType.text.trim().isNotEmpty ||
        address1.text.trim().isNotEmpty ||
        address2.text.trim().isNotEmpty ||
        address3.text.trim().isNotEmpty ||
        city.text.trim().isNotEmpty ||
        taluk.text.trim().isNotEmpty ||
        block.text.trim().isNotEmpty ||
        district.text.trim().isNotEmpty ||
        state.text.trim().isNotEmpty ||
        pincode.text.trim().isNotEmpty ||
        parentCropzId.text.trim().isNotEmpty ||
        inGst;
  }

  void dispose() {
    addressType.dispose();
    address1.dispose();
    address2.dispose();
    address3.dispose();
    city.dispose();
    taluk.dispose();
    block.dispose();
    district.dispose();
    state.dispose();
    pincode.dispose();
    parentCropzId.dispose();
  }
}
