import 'dart:convert';

import 'package:flutter/services.dart';

class CompanySuggestionsDataSource {
  const CompanySuggestionsDataSource();

  static List<String>? _cache;

  Future<List<String>> getAll() async {
    if (_cache != null) {
      return _cache!;
    }
    final raw = await rootBundle.loadString(
      'assets/data/company_suggestions.json',
    );
    final decoded = jsonDecode(raw) as List<dynamic>;
    _cache = decoded.map((item) => item.toString()).toList(growable: false);
    return _cache!;
  }
}
