import 'dart:convert';
import 'dart:io';

import '../../../../shared/core/config/pocketbase_config.dart';

class PocketbaseOtpRequestResult {
  const PocketbaseOtpRequestResult({required this.otpId});
  final String otpId;
}

class PocketbaseAuthResult {
  const PocketbaseAuthResult({required this.token, required this.recordId});
  final String token;
  final String recordId;
}

class PocketbaseAuthBridge {
  const PocketbaseAuthBridge();

  Uri _uri(String path) => Uri.parse('${PocketbaseConfig.baseUrl}$path');

  Future<PocketbaseOtpRequestResult> requestOtp(String email) async {
    final data = await _postJson(
      _uri(PocketbaseConfig.requestOtpPath),
      <String, Object?>{'email': email.trim()},
    );
    final otpId = (data['otpId'] ?? '').toString();
    if (otpId.isEmpty) {
      throw const FormatException('PocketBase request-otp returned no otpId.');
    }
    return PocketbaseOtpRequestResult(otpId: otpId);
  }

  Future<PocketbaseAuthResult> authWithOtp({
    required String otpId,
    required String code,
  }) async {
    final data = await _postJson(
      _uri(PocketbaseConfig.authWithOtpPath),
      <String, Object?>{
        'otpId': otpId.trim(),
        'password': code.trim(),
      },
    );

    final token = (data['token'] ?? '').toString();
    final record = data['record'];
    final recordId = record is Map<String, dynamic>
        ? (record['id'] ?? '').toString()
        : '';

    if (token.isEmpty || recordId.isEmpty) {
      throw const FormatException(
        'PocketBase auth-with-otp response was missing token or record.id.',
      );
    }
    return PocketbaseAuthResult(token: token, recordId: recordId);
  }

  Future<Map<String, dynamic>> _postJson(
    Uri uri,
    Map<String, Object?> payload,
  ) async {
    final client = HttpClient();
    try {
      final request = await client.postUrl(uri);
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(payload));
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      final parsed = body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(body) as Map<String, dynamic>;
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message = (parsed['message'] ?? body).toString();
        throw HttpException(
          'PocketBase authentication failed (${response.statusCode}): $message',
          uri: uri,
        );
      }
      return parsed;
    } finally {
      client.close();
    }
  }
}
