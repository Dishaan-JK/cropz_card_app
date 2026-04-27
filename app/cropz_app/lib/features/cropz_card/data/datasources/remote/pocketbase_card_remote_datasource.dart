import 'dart:convert';
import 'dart:io';

import '../../../../../shared/core/config/pocketbase_config.dart';

class PocketbaseCardRemoteDatasource {
  const PocketbaseCardRemoteDatasource();

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('${PocketbaseConfig.baseUrl}$path').replace(queryParameters: query);

  Future<void> upsertCard({
    required String ownerKey,
    required String cardKey,
    required String payloadJson,
    required bool deleted,
    required int updatedAtMs,
    String? authToken,
  }) async {
    final filter = 'card_key="${_escapeFilter(cardKey)}"';
    final list = await _requestJson(
      method: 'GET',
      uri: _uri(PocketbaseConfig.cardsRecordsPath, <String, String>{
        'filter': filter,
        'perPage': '1',
      }),
      authToken: authToken,
    );

    final items = (list['items'] as List<dynamic>? ?? const <dynamic>[]);
    final payload = <String, Object?>{
      'owner_key': ownerKey,
      'card_key': cardKey,
      'payload_json': jsonDecode(payloadJson),
      'deleted': deleted,
      'updated_at_ms': updatedAtMs,
    };

    if (items.isEmpty) {
      await _requestJson(
        method: 'POST',
        uri: _uri(PocketbaseConfig.cardsRecordsPath),
        body: payload,
        authToken: authToken,
      );
      return;
    }

    final first = items.first;
    final id = first is Map<String, dynamic> ? (first['id'] ?? '').toString() : '';
    if (id.isEmpty) {
      throw const FormatException('PocketBase cards record id is missing.');
    }
    await _requestJson(
      method: 'PATCH',
      uri: _uri('${PocketbaseConfig.cardsRecordsPath}/$id'),
      body: payload,
      authToken: authToken,
    );
  }

  String _escapeFilter(String value) => value.replaceAll('"', r'\"');

  Future<Map<String, dynamic>> _requestJson({
    required String method,
    required Uri uri,
    Map<String, Object?>? body,
    String? authToken,
  }) async {
    final client = HttpClient();
    try {
      final request = await client.openUrl(method, uri);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      if (authToken != null && authToken.trim().isNotEmpty) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $authToken');
      }
      if (body != null) {
        request.headers.contentType = ContentType.json;
        request.write(jsonEncode(body));
      }
      final response = await request.close();
      final bodyText = await response.transform(utf8.decoder).join();
      final parsed = bodyText.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(bodyText) as Map<String, dynamic>;
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message = (parsed['message'] ?? bodyText).toString();
        throw HttpException(
          'PocketBase cards request failed (${response.statusCode}): $message',
          uri: uri,
        );
      }
      return parsed;
    } finally {
      client.close();
    }
  }
}
