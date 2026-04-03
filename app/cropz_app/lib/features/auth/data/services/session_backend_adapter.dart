import 'device_telemetry_service.dart';
import 'session_guard_event.dart';

abstract class SessionBackendAdapter {
  Future<String?> getCurrentUserId();

  Future<void> upsertDeviceTelemetry(String userId, DeviceTelemetry telemetry);

  Future<String> createActiveSession(String userId, DeviceTelemetry telemetry);

  Future<void> revokeOtherSessions(String userId, String activeSessionId);

  Future<bool> isSessionActive(String userId, String sessionId);

  Future<ActiveDeviceInfo?> fetchLatestActiveDevice(String userId);

  bool isAccessDeniedError(Object error);
}
