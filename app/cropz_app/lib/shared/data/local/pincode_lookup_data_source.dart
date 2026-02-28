import 'dart:convert';

import 'package:flutter/services.dart';

class PincodeLookupItem {
  const PincodeLookupItem({
    required this.state,
    required this.district,
    required this.block,
    required this.villages,
  });

  final String state;
  final String district;
  final String block;
  final List<String> villages;
}

class PincodeLookupDataSource {
  const PincodeLookupDataSource();

  static Map<String, PincodeLookupItem>? _cache;

  Future<PincodeLookupItem?> findByPincode(String pincode) async {
    final map = await _load();
    return map[pincode];
  }

  Future<void> preload() async {
    await _load();
  }

  Future<Map<String, PincodeLookupItem>> _load() async {
    if (_cache != null) {
      return _cache!;
    }
    final raw = await rootBundle.loadString('assets/data/pincode_lookup.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    _cache = decoded.map((key, value) {
      final row = value as Map<String, dynamic>;
      final villages =
          (row['villages'] as List<dynamic>? ?? const <dynamic>[])
              .map((v) => v.toString())
              .toList(growable: false);
      return MapEntry(
        key,
        PincodeLookupItem(
          state: (row['state'] ?? '').toString(),
          district: (row['district'] ?? '').toString(),
          block: (row['block'] ?? '').toString(),
          villages: villages,
        ),
      );
    });
    return _cache!;
  }
}
