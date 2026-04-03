import 'package:supabase_flutter/supabase_flutter.dart';

import 'device_telemetry_service.dart';
import 'session_backend_adapter.dart';
import 'session_guard_event.dart';

class SupabaseSessionBackendAdapter implements SessionBackendAdapter {
  SupabaseSessionBackendAdapter(this._supabaseClient);

  final SupabaseClient _supabaseClient;

  @override
  Future<String?> getCurrentUserId() async {
    return _supabaseClient.auth.currentUser?.id;
  }

  @override
  Future<void> upsertDeviceTelemetry(
    String userId,
    DeviceTelemetry telemetry,
  ) async {
    await _supabaseClient.from('user_devices').upsert({
      'user_id': userId,
      'device_id': telemetry.deviceId,
      'platform': telemetry.platform,
      'model': telemetry.model,
      'last_login_at': DateTime.now().toIso8601String(),
      'last_seen_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id,device_id');
  }

  @override
  Future<String> createActiveSession(
    String userId,
    DeviceTelemetry telemetry,
  ) async {
    final inserted = await _supabaseClient
        .from('user_sessions')
        .insert({
          'user_id': userId,
          'device_id': telemetry.deviceId,
          'device_type': telemetry.platform,
          'device_model': telemetry.model,
          'is_active': true,
          'last_seen_at': DateTime.now().toIso8601String(),
        })
        .select('id')
        .single();

    final id = (inserted['id'] ?? '').toString();
    if (id.isEmpty) {
      throw StateError('Session id was empty.');
    }

    return id;
  }

  @override
  Future<void> revokeOtherSessions(
    String userId,
    String activeSessionId,
  ) async {
    await _supabaseClient
        .from('user_sessions')
        .update({
          'is_active': false,
          'revoked_at': DateTime.now().toIso8601String(),
        })
        .eq('user_id', userId)
        .neq('id', activeSessionId)
        .eq('is_active', true);
  }

  @override
  Future<bool> isSessionActive(String userId, String sessionId) async {
    final row = await _supabaseClient
        .from('user_sessions')
        .select('is_active')
        .eq('user_id', userId)
        .eq('id', sessionId)
        .maybeSingle();

    return row != null && row['is_active'] == true;
  }

  @override
  Future<ActiveDeviceInfo?> fetchLatestActiveDevice(String userId) async {
    final row = await _supabaseClient
        .from('user_sessions')
        .select(
          'device_id, device_type, device_model, last_seen_at, created_at',
        )
        .eq('user_id', userId)
        .eq('is_active', true)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (row == null) {
      return null;
    }

    DateTime? lastSeenAt;
    final rawLastSeen = (row['last_seen_at'] ?? '').toString();
    if (rawLastSeen.isNotEmpty) {
      lastSeenAt = DateTime.tryParse(rawLastSeen);
    }

    return ActiveDeviceInfo(
      deviceId: (row['device_id'] ?? '').toString(),
      deviceType: (row['device_type'] ?? 'unknown').toString(),
      deviceModel: (row['device_model'] ?? 'unknown').toString(),
      lastSeenAt: lastSeenAt,
    );
  }

  @override
  bool isAccessDeniedError(Object error) {
    return error is PostgrestException && error.code == '42501';
  }
}
