import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/cropz_card_details.dart';

class PdfField {
  const PdfField(this.label, this.value);

  final String label;
  final String value;
}

class BankPreview {
  const BankPreview({required this.title, required this.fields});

  final String title;
  final List<PdfField> fields;
}

class AddressPreview {
  const AddressPreview({required this.title, required this.lines});

  final String title;
  final List<String> lines;
}

class CropzCardPreviewData {
  const CropzCardPreviewData({
    required this.essentialFields,
    required this.businessFields,
    required this.bankAccounts,
    required this.addresses,
    required this.firmName,
    required this.mobile,
    required this.ownerName,
    required this.imagePath,
    required this.dealerships,
  });

  final List<PdfField> essentialFields;
  final List<PdfField> businessFields;
  final List<BankPreview> bankAccounts;
  final List<AddressPreview> addresses;
  final String firmName;
  final String mobile;
  final String ownerName;
  final String? imagePath;
  final List<String> dealerships;

  factory CropzCardPreviewData.fromDetails(CropzCardDetails details) {
    final profile = details.profile;
    return CropzCardPreviewData(
      essentialFields: [
        PdfField('Firm Name', profile.firmName),
        PdfField('Mobile', profile.mobile),
        PdfField('Owner Name', profile.ownerName ?? ''),
        PdfField('WhatsApp', profile.whatsapp ?? ''),
      ],
      businessFields: [
        PdfField('Email', profile.email ?? ''),
        PdfField('GST Number', profile.gstNo ?? ''),
        PdfField('UPI ID', profile.upiId ?? ''),
        PdfField('Transport', profile.transport ?? ''),
        PdfField('SL No', profile.slNo ?? ''),
        PdfField('SL Expiry Date', profile.slExpiryDate ?? ''),
        PdfField('PL No', profile.plNo ?? ''),
        PdfField('Retail FL No', profile.retailFlNo ?? ''),
        PdfField('Retail FL Expiry Date', profile.retailFlExpiryDate ?? ''),
        PdfField('WS FL No', profile.wsFlNo ?? ''),
        PdfField('WS FL Expiry Date', profile.wsFlExpiryDate ?? ''),
        PdfField('FMS Retail ID', profile.fmsRetailId ?? ''),
        PdfField('FMS WS ID', profile.fmsWsId ?? ''),
      ],
      bankAccounts: details.bankInfos
          .asMap()
          .entries
          .map(
            (entry) => BankPreview(
              title: 'Account ${entry.key + 1}',
              fields: [
                PdfField('Account Holder', entry.value.accountHolderName ?? ''),
                PdfField('Account Number', entry.value.accountNo ?? ''),
                PdfField('Account Type', entry.value.accountType ?? ''),
                PdfField('IFSC Code', entry.value.ifscCode ?? ''),
                PdfField('Bank Name', entry.value.bankName ?? ''),
                PdfField('Branch', entry.value.branch ?? ''),
              ],
            ),
          )
          .where(
            (account) => account.fields.any((field) => field.value.isNotEmpty),
          )
          .toList(),
      addresses: details.addresses
          .asMap()
          .entries
          .map((entry) {
            final type = (entry.value.addressType ?? '').trim();
            final lines =
                <String?>[
                      entry.value.address1,
                      entry.value.address2,
                      entry.value.address3,
                      entry.value.city,
                      entry.value.taluk,
                      entry.value.block,
                      entry.value.district,
                      entry.value.state,
                      entry.value.pincode,
                    ]
                    .whereType<String>()
                    .map((value) => value.trim())
                    .where((v) => v.isNotEmpty)
                    .toList();
            final title = type.isEmpty
                ? 'Address ${entry.key + 1}'
                : '${type[0].toUpperCase()}${type.substring(1)} Address';
            return AddressPreview(title: title, lines: lines);
          })
          .where((address) => address.lines.isNotEmpty)
          .toList(),
      firmName: profile.firmName,
      mobile: profile.mobile,
      ownerName: profile.ownerName ?? '',
      imagePath: profile.profilePicture,
      dealerships: (profile.companies ?? '')
          .split(',')
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toList(growable: false),
    );
  }
}

class CropzCardPreviewPage extends StatefulWidget {
  const CropzCardPreviewPage({super.key, required this.data});

  final CropzCardPreviewData data;

  static Future<void> sharePdf(
    BuildContext context,
    CropzCardPreviewData data, {
    required bool includeBusiness,
    required bool includeLicenseInfo,
    required bool includeBankAccounts,
    required bool includeAddress,
    required Set<int> selectedBankIndexes,
    required Set<int> selectedAddressIndexes,
  }) async {
    try {
      if (!includeBusiness &&
          !includeLicenseInfo &&
          !(includeBankAccounts && selectedBankIndexes.isNotEmpty) &&
          !(includeAddress && selectedAddressIndexes.isNotEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Select at least one section to share.'),
          ),
        );
        return;
      }
      final selectedBanks = data.bankAccounts
          .asMap()
          .entries
          .where((entry) => selectedBankIndexes.contains(entry.key))
          .map((entry) => entry.value)
          .toList();
      final selectedAddresses = data.addresses
          .asMap()
          .entries
          .where((entry) => selectedAddressIndexes.contains(entry.key))
          .map((entry) => entry.value)
          .toList();
      final doc = pw.Document();
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Cropz Card - Business & License Info',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 16),
                if (includeBusiness) ...[
                  pw.Text(
                    'Business',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 8),
                  ...data.essentialFields.map(_buildPdfFieldRow),
                  pw.SizedBox(height: 12),
                ],
                if (includeLicenseInfo) ...[
                  pw.Text(
                    'License Info',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 8),
                  ...data.businessFields.map(_buildPdfFieldRow),
                  pw.SizedBox(height: 12),
                ],
                if (includeBankAccounts && selectedBanks.isNotEmpty) ...[
                  pw.Text(
                    'Bank Accounts',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 8),
                  for (final account in selectedBanks) ...[
                    pw.Text(
                      account.title,
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 6),
                    ...account.fields.map(_buildPdfFieldRow),
                    pw.SizedBox(height: 8),
                  ],
                ],
                if (includeAddress && selectedAddresses.isNotEmpty) ...[
                  pw.Text(
                    'Address',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  for (final address in selectedAddresses) ...[
                    pw.SizedBox(height: 8),
                    pw.Text(
                      address.title,
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(address.lines.join('\n')),
                  ],
                ],
              ],
            );
          },
        ),
      );

      final bytes = await doc.save();
      final appDocDir = await getApplicationDocumentsDirectory();
      final targetDir = Directory(p.join(appDocDir.path, 'cropz_exports'));
      if (!targetDir.existsSync()) {
        targetDir.createSync(recursive: true);
      }
      final fileName =
          'cropz_preview_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = p.join(targetDir.path, fileName);
      final file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Cropz Card Business & License Info Details',
        ),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to generate PDF. Please try again.'),
        ),
      );
    }
  }

  static pw.Widget _buildPdfFieldRow(PdfField field) {
    final value = field.value.isEmpty ? '-' : field.value;
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 3,
            child: pw.Text(
              field.label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Expanded(flex: 5, child: pw.Text(value)),
        ],
      ),
    );
  }

  @override
  State<CropzCardPreviewPage> createState() => _CropzCardPreviewPageState();
}

class _CropzCardPreviewPageState extends State<CropzCardPreviewPage> {
  bool _includeBusiness = true;
  bool _includeLicenseInfo = true;
  bool _includeBankAccounts = true;
  bool _includeAddress = true;
  late Set<int> _selectedBankIndexes;
  late Set<int> _selectedAddressIndexes;
  final GlobalKey _businessCardKey = GlobalKey();
  bool _isSharingBusinessCard = false;
  int _selectedBusinessCardTemplate = 0;
  static const List<String> _templateNames = [
    'Classic',
    'Executive',
    'Grid',
    'Ledger',
    'Tagline',
  ];

  @override
  void initState() {
    super.initState();
    _selectedBankIndexes = widget.data.bankAccounts.asMap().keys.toSet();
    _selectedAddressIndexes = widget.data.addresses.asMap().keys.toSet();
  }

  bool get _hasSelection =>
      _includeBusiness ||
      _includeLicenseInfo ||
      (_includeBankAccounts && _selectedBankIndexes.isNotEmpty) ||
      (_includeAddress && _selectedAddressIndexes.isNotEmpty);

  String _fieldValue(List<PdfField> fields, String label) {
    for (final field in fields) {
      if (field.label == label) {
        return field.value;
      }
    }
    return '';
  }

  String get _whatsApp => _fieldValue(widget.data.essentialFields, 'WhatsApp');
  String get _gstNumber =>
      _fieldValue(widget.data.businessFields, 'GST Number');

  String get _primaryAddress {
    if (widget.data.addresses.isEmpty) {
      return '';
    }
    final selected = _selectedAddressIndexes.isEmpty
        ? 0
        : _selectedAddressIndexes.first;
    final safeIndex = selected >= 0 && selected < widget.data.addresses.length
        ? selected
        : 0;
    return widget.data.addresses[safeIndex].lines.join(', ');
  }

  Future<void> _openAddressInMaps(String addressText) async {
    final query = addressText.trim();
    if (query.isEmpty) {
      return;
    }

    final encoded = Uri.encodeComponent(query);
    final appUri = Uri.parse('comgooglemaps://?q=$encoded');
    final webUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$encoded',
    );

    final openedInApp = await launchUrl(
      appUri,
      mode: LaunchMode.externalApplication,
    );

    if (openedInApp) {
      return;
    }

    final openedInWeb = await launchUrl(
      webUri,
      mode: LaunchMode.externalApplication,
    );

    if (!openedInWeb && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open address in Google Maps.')),
      );
    }
  }

  Widget _buildSelectedBusinessCard() {
    final data = _BusinessCardViewData(
      firmName: widget.data.firmName,
      ownerName: widget.data.ownerName,
      mobile: widget.data.mobile,
      whatsapp: _whatsApp,
      gstNumber: _gstNumber,
      address: _primaryAddress,
      imagePath: widget.data.imagePath,
      dealerships: widget.data.dealerships,
    );
    switch (_selectedBusinessCardTemplate) {
      case 1:
        return _BusinessCardTemplate2(data: data);
      case 2:
        return _BusinessCardTemplate3(data: data);
      case 3:
        return _BusinessCardTemplate4(data: data);
      case 4:
        return _BusinessCardTemplate5(data: data);
      default:
        return _DigitalBusinessCard(data: data);
    }
  }

  Future<void> _shareBusinessCardImage() async {
    if (_isSharingBusinessCard) {
      return;
    }
    setState(() => _isSharingBusinessCard = true);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 80));
      final boundary =
          _businessCardKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) {
        return;
      }
      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        return;
      }
      final bytes = byteData.buffer.asUint8List();
      final appDocDir = await getApplicationDocumentsDirectory();
      final targetDir = Directory(p.join(appDocDir.path, 'cropz_exports'));
      if (!targetDir.existsSync()) {
        targetDir.createSync(recursive: true);
      }
      final file = File(
        p.join(
          targetDir.path,
          'cropz_business_card_${DateTime.now().millisecondsSinceEpoch}.png',
        ),
      );
      await file.writeAsBytes(bytes, flush: true);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Cropz Digital Business Card',
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to share business card image. Please try again.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharingBusinessCard = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.primary,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Preview')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF7F9FB), Color(0xFFEFF6FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: _PreviewHeader(
                  imagePath: widget.data.imagePath,
                  firmName: widget.data.firmName,
                  mobile: widget.data.mobile,
                  ownerName: widget.data.ownerName,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Digital Business Card', style: titleStyle),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_templateNames.length, (index) {
                return ChoiceChip(
                  label: Text(_templateNames[index]),
                  selected: _selectedBusinessCardTemplate == index,
                  onSelected: (_) {
                    setState(() => _selectedBusinessCardTemplate = index);
                  },
                );
              }),
            ),
            const SizedBox(height: 10),
            RepaintBoundary(
              key: _businessCardKey,
              child: _buildSelectedBusinessCard(),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _isSharingBusinessCard
                  ? null
                  : _shareBusinessCardImage,
              icon: const Icon(Icons.image_outlined),
              label: Text(
                _isSharingBusinessCard
                    ? 'Preparing...'
                    : 'Share Business Card Image',
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Select Sections', style: titleStyle),
                    CheckboxListTile(
                      value: _includeBusiness,
                      onChanged: (value) {
                        setState(() => _includeBusiness = value ?? false);
                      },
                      title: const Text('Business'),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    CheckboxListTile(
                      value: _includeLicenseInfo,
                      onChanged: (value) {
                        setState(() => _includeLicenseInfo = value ?? false);
                      },
                      title: const Text('License Info'),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    CheckboxListTile(
                      value: _includeBankAccounts,
                      onChanged: (value) {
                        setState(() => _includeBankAccounts = value ?? false);
                      },
                      title: const Text('Bank Accounts'),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    CheckboxListTile(
                      value: _includeAddress,
                      onChanged: (value) {
                        setState(() => _includeAddress = value ?? false);
                      },
                      title: const Text('Address'),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _PreviewSectionCard(
              title: 'Business',
              fields: widget.data.essentialFields,
              titleStyle: titleStyle,
            ),
            const SizedBox(height: 16),
            _PreviewSectionCard(
              title: 'License Info',
              fields: widget.data.businessFields,
              titleStyle: titleStyle,
            ),
            const SizedBox(height: 16),
            _BankAccountsSectionCard(
              titleStyle: titleStyle,
              accounts: widget.data.bankAccounts,
              selectedIndexes: _selectedBankIndexes,
              onToggle: (index, checked) {
                setState(() {
                  if (checked) {
                    _selectedBankIndexes.add(index);
                  } else {
                    _selectedBankIndexes.remove(index);
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            _AddressSectionCard(
              titleStyle: titleStyle,
              addresses: widget.data.addresses,
              selectedIndexes: _selectedAddressIndexes,
              onOpenMap: _openAddressInMaps,
              onToggle: (index, checked) {
                setState(() {
                  if (checked) {
                    _selectedAddressIndexes.add(index);
                  } else {
                    _selectedAddressIndexes.remove(index);
                  }
                });
              },
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _hasSelection
                  ? () => CropzCardPreviewPage.sharePdf(
                      context,
                      widget.data,
                      includeBusiness: _includeBusiness,
                      includeLicenseInfo: _includeLicenseInfo,
                      includeBankAccounts: _includeBankAccounts,
                      includeAddress: _includeAddress,
                      selectedBankIndexes: _selectedBankIndexes,
                      selectedAddressIndexes: _selectedAddressIndexes,
                    )
                  : null,
              icon: const Icon(Icons.share_outlined),
              label: const Text('Share PDF'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewHeader extends StatelessWidget {
  const _PreviewHeader({
    required this.imagePath,
    required this.firmName,
    required this.mobile,
    required this.ownerName,
  });

  final String? imagePath;
  final String firmName;
  final String mobile;
  final String ownerName;

  @override
  Widget build(BuildContext context) {
    final imageFile = imagePath != null && imagePath!.isNotEmpty
        ? File(imagePath!)
        : null;
    final hasImage = imageFile != null && imageFile.existsSync();

    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.blueGrey.shade100,
          backgroundImage: hasImage ? FileImage(imageFile!) : null,
          child: hasImage
              ? null
              : Text(
                  _initials(firmName),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                firmName.isEmpty ? 'Cropz Card' : firmName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (mobile.isNotEmpty)
                Text(mobile, style: TextStyle(color: Colors.grey.shade700)),
              if (ownerName.isNotEmpty)
                Text(ownerName, style: TextStyle(color: Colors.grey.shade700)),
            ],
          ),
        ),
      ],
    );
  }

  String _initials(String input) {
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

class _BusinessCardViewData {
  const _BusinessCardViewData({
    required this.firmName,
    required this.ownerName,
    required this.mobile,
    required this.whatsapp,
    required this.gstNumber,
    required this.address,
    required this.imagePath,
    required this.dealerships,
  });

  final String firmName;
  final String ownerName;
  final String mobile;
  final String whatsapp;
  final String gstNumber;
  final String address;
  final String? imagePath;
  final List<String> dealerships;
}

class _DigitalBusinessCard extends StatelessWidget {
  const _DigitalBusinessCard({required this.data});

  final _BusinessCardViewData data;

  @override
  Widget build(BuildContext context) {
    return _BusinessCardShell(
      gradient: const [Color(0xFF0F766E), Color(0xFF1D4ED8)],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _BusinessCardLogo(
                imagePath: data.imagePath,
                firmName: data.firmName,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  data.firmName.isEmpty ? 'Cropz Card' : data.firmName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (data.ownerName.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              data.ownerName,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
          const SizedBox(height: 14),
          _BusinessCardInfoRow(icon: Icons.phone_outlined, text: data.mobile),
          _BusinessCardInfoRow(
            icon: Icons.chat_bubble_outline,
            text: data.whatsapp.isEmpty ? '-' : data.whatsapp,
          ),
          _BusinessCardInfoRow(
            icon: Icons.receipt_long_outlined,
            text: data.gstNumber.isEmpty ? '-' : data.gstNumber,
          ),
          _BusinessCardInfoRow(
            icon: Icons.location_on_outlined,
            text: data.address.isEmpty ? '-' : data.address,
          ),
          _BusinessCardInfoRow(
            icon: Icons.apartment_outlined,
            text: data.dealerships.isEmpty ? '-' : data.dealerships.join(', '),
          ),
        ],
      ),
    );
  }
}

class _BusinessCardTemplate2 extends StatelessWidget {
  const _BusinessCardTemplate2({required this.data});

  final _BusinessCardViewData data;

  @override
  Widget build(BuildContext context) {
    return _BusinessCardShell(
      gradient: const [Color(0xFF0B132B), Color(0xFF1C2541)],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  data.firmName.isEmpty ? 'Cropz Card' : data.firmName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              _BusinessCardLogo(
                imagePath: data.imagePath,
                firmName: data.firmName,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _templateBadge('Owner', data.ownerName),
          _templateBadge('Mobile', data.mobile),
          _templateBadge(
            'WhatsApp',
            data.whatsapp.isEmpty ? '-' : data.whatsapp,
          ),
          _templateBadge('GST', data.gstNumber.isEmpty ? '-' : data.gstNumber),
          _templateBadge(
            'Dealerships',
            data.dealerships.isEmpty ? '-' : data.dealerships.join(', '),
          ),
          const SizedBox(height: 10),
          Text(
            data.address.isEmpty ? '-' : data.address,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _templateBadge(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.white, fontSize: 13),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: value.isEmpty ? '-' : value),
          ],
        ),
      ),
    );
  }
}

class _BusinessCardTemplate3 extends StatelessWidget {
  const _BusinessCardTemplate3({required this.data});

  final _BusinessCardViewData data;

  @override
  Widget build(BuildContext context) {
    return _BusinessCardShell(
      gradient: const [Color(0xFF14532D), Color(0xFF0EA5E9)],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _BusinessCardLogo(
                imagePath: data.imagePath,
                firmName: data.firmName,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.firmName.isEmpty ? 'Cropz Card' : data.firmName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (data.ownerName.isNotEmpty)
                      Text(
                        data.ownerName,
                        style: const TextStyle(color: Colors.white70),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _miniTile('Mobile', data.mobile)),
              const SizedBox(width: 8),
              Expanded(
                child: _miniTile(
                  'WhatsApp',
                  data.whatsapp.isEmpty ? '-' : data.whatsapp,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _miniTile(
                  'GST',
                  data.gstNumber.isEmpty ? '-' : data.gstNumber,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _miniTile(
                  'Dealers',
                  data.dealerships.isEmpty
                      ? '-'
                      : '${data.dealerships.length} brands',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _miniTile('Address', data.address.isEmpty ? '-' : data.address),
        ],
      ),
    );
  }

  Widget _miniTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _BusinessCardTemplate4 extends StatelessWidget {
  const _BusinessCardTemplate4({required this.data});

  final _BusinessCardViewData data;

  @override
  Widget build(BuildContext context) {
    return _BusinessCardShell(
      gradient: const [Color(0xFF7C2D12), Color(0xFF2563EB)],
      child: Column(
        children: [
          Row(
            children: [
              _BusinessCardLogo(
                imagePath: data.imagePath,
                firmName: data.firmName,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  data.firmName.isEmpty ? 'Cropz Card' : data.firmName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: Colors.white38, height: 1),
          const SizedBox(height: 10),
          _BusinessCardInfoRow(
            icon: Icons.person_outline,
            text: data.ownerName.isEmpty ? '-' : data.ownerName,
          ),
          _BusinessCardInfoRow(icon: Icons.phone_outlined, text: data.mobile),
          _BusinessCardInfoRow(
            icon: Icons.chat_outlined,
            text: data.whatsapp.isEmpty ? '-' : data.whatsapp,
          ),
          _BusinessCardInfoRow(
            icon: Icons.receipt_long_outlined,
            text: data.gstNumber.isEmpty ? '-' : data.gstNumber,
          ),
          _BusinessCardInfoRow(
            icon: Icons.apartment_outlined,
            text: data.dealerships.isEmpty ? '-' : data.dealerships.join(', '),
          ),
          _BusinessCardInfoRow(
            icon: Icons.location_on_outlined,
            text: data.address.isEmpty ? '-' : data.address,
          ),
        ],
      ),
    );
  }
}

class _BusinessCardTemplate5 extends StatelessWidget {
  const _BusinessCardTemplate5({required this.data});

  final _BusinessCardViewData data;

  @override
  Widget build(BuildContext context) {
    return _BusinessCardShell(
      gradient: const [Color(0xFF111827), Color(0xFF047857)],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.firmName.isEmpty ? 'Cropz Card' : data.firmName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  data.ownerName.isEmpty ? '-' : data.ownerName,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
              _BusinessCardLogo(
                imagePath: data.imagePath,
                firmName: data.firmName,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _pill('Mob', data.mobile),
              _pill('WA', data.whatsapp.isEmpty ? '-' : data.whatsapp),
              _pill('GST', data.gstNumber.isEmpty ? '-' : data.gstNumber),
            ],
          ),
          const SizedBox(height: 10),
          _BusinessCardInfoRow(
            icon: Icons.apartment_outlined,
            text: data.dealerships.isEmpty ? '-' : data.dealerships.join(', '),
          ),
          _BusinessCardInfoRow(
            icon: Icons.location_on_outlined,
            text: data.address.isEmpty ? '-' : data.address,
          ),
        ],
      ),
    );
  }

  Widget _pill(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}

class _BusinessCardShell extends StatelessWidget {
  const _BusinessCardShell({required this.gradient, required this.child});

  final List<Color> gradient;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}

class _BusinessCardInfoRow extends StatelessWidget {
  const _BusinessCardInfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.white.withOpacity(0.9)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.95),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BusinessCardLogo extends StatelessWidget {
  const _BusinessCardLogo({required this.imagePath, required this.firmName});

  final String? imagePath;
  final String firmName;

  @override
  Widget build(BuildContext context) {
    final file = imagePath != null && imagePath!.isNotEmpty
        ? File(imagePath!)
        : null;
    final hasImage = file != null && file.existsSync();
    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.white24,
      backgroundImage: hasImage ? FileImage(file!) : null,
      child: hasImage
          ? null
          : Text(
              _initials(firmName),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }

  String _initials(String input) {
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

class _PreviewSectionCard extends StatelessWidget {
  const _PreviewSectionCard({
    required this.title,
    required this.fields,
    required this.titleStyle,
  });

  final String title;
  final List<PdfField> fields;
  final TextStyle titleStyle;

  @override
  Widget build(BuildContext context) {
    final visibleFields = fields
        .where((field) => field.value.isNotEmpty)
        .toList(growable: false);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: titleStyle),
            const SizedBox(height: 12),
            if (visibleFields.isEmpty) const Text('No details provided.'),
            for (final field in visibleFields) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      field.label,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(flex: 5, child: Text(field.value)),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _AddressSectionCard extends StatelessWidget {
  const _AddressSectionCard({
    required this.titleStyle,
    required this.addresses,
    required this.selectedIndexes,
    required this.onToggle,
    required this.onOpenMap,
  });

  final TextStyle titleStyle;
  final List<AddressPreview> addresses;
  final Set<int> selectedIndexes;
  final void Function(int index, bool checked) onToggle;
  final Future<void> Function(String addressText) onOpenMap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Address', style: titleStyle),
            const SizedBox(height: 12),
            if (addresses.isEmpty) const Text('No address provided.'),
            for (var i = 0; i < addresses.length; i++)
              CheckboxListTile(
                value: selectedIndexes.contains(i),
                onChanged: (value) => onToggle(i, value ?? false),
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(addresses[i].title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(addresses[i].lines.join('\n')),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _MapActionButton(
                        onTap: () => onOpenMap(addresses[i].lines.join(', ')),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MapActionButton extends StatefulWidget {
  const _MapActionButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_MapActionButton> createState() => _MapActionButtonState();
}

class _MapActionButtonState extends State<_MapActionButton> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final scale = _pressed
        ? 0.96
        : _hover
        ? 1.02
        : 1.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() {
        _hover = false;
        _pressed = false;
      }),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 120),
          scale: scale,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: scheme.primary.withValues(alpha: 0.1),
              border: Border.all(color: scheme.primary.withValues(alpha: 0.4)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _GoogleMapsLogo(),
                SizedBox(width: 6),
                Text(
                  'Open in Google Maps',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleMapsLogo extends StatelessWidget {
  const _GoogleMapsLogo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 18,
      child: Stack(
        children: [
          Positioned(
            left: 3,
            top: 2,
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Color(0xFF34A853),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 7,
            top: 0,
            child: Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: Color(0xFF4285F4),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 5,
            child: Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: Color(0xFFFBBC05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 6,
            top: 9,
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFFEA4335),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BankAccountsSectionCard extends StatelessWidget {
  const _BankAccountsSectionCard({
    required this.titleStyle,
    required this.accounts,
    required this.selectedIndexes,
    required this.onToggle,
  });

  final TextStyle titleStyle;
  final List<BankPreview> accounts;
  final Set<int> selectedIndexes;
  final void Function(int index, bool checked) onToggle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bank Accounts', style: titleStyle),
            const SizedBox(height: 12),
            if (accounts.isEmpty) const Text('No bank accounts provided.'),
            for (var i = 0; i < accounts.length; i++) ...[
              CheckboxListTile(
                value: selectedIndexes.contains(i),
                onChanged: (value) => onToggle(i, value ?? false),
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(
                  accounts[i].title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    for (final field in accounts[i].fields.where(
                      (f) => f.value.isNotEmpty,
                    ))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                field.label,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(flex: 5, child: Text(field.value)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
