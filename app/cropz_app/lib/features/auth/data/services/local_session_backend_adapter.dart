import 'package:shared_preferences/shared_preferences.dart';

import 'device_telemetry_service.dart';
import 'session_backend_adapter.dart';
import 'session_guard_event.dart';

class LocalSessionBackendAdapter implements SessionBackendAdapter {
  static const String _userIdKey = 'auth_user_id';
  static const String _activeSessionPrefix = 'active_session_for_';

  @override
  Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_userIdKey);
    if (userId == null || userId.trim().isEmpty) {
      return null;
    }
    return userId;
  }

  Future<void> setCurrentUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }

  Future<void> clearCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
  }

  @override
  Future<void> upsertDeviceTelemetry(
    String userId,
    DeviceTelemetry telemetry,
  ) async {}

  @override
  Future<String> createActiveSession(
    String userId,
    DeviceTelemetry telemetry,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId =
        '${DateTime.now().millisecondsSinceEpoch}_${telemetry.deviceId}';
    await prefs.setString('$_activeSessionPrefix$userId', sessionId);
    return sessionId;
  }

  @override
  Future<void> revokeOtherSessions(String userId, String activeSessionId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_activeSessionPrefix$userId', activeSessionId);
  }

  @override
  Future<bool> isSessionActive(String userId, String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_activeSessionPrefix$userId') == sessionId;
  }

  @override
  Future<ActiveDeviceInfo?> fetchLatestActiveDevice(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('$_activeSessionPrefix$userId');
    if (sessionId == null || sessionId.isEmpty) {
      return null;
    }
    return const ActiveDeviceInfo(
      deviceId: 'local-device',
      deviceType: 'local',
      deviceModel: 'this-device',
    );
  }

  @override
  bool isAccessDeniedError(Object error) => false;
}
