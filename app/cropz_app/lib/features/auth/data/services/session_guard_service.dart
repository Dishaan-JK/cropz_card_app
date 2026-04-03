import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import 'device_telemetry_service.dart';
import 'session_backend_adapter.dart';
import 'session_guard_event.dart';

class SessionGuardService {
  SessionGuardService({
    required SessionBackendAdapter backendAdapter,
    required DeviceTelemetryService telemetryService,
  }) : _backendAdapter = backendAdapter,
       _telemetryService = telemetryService;

  static const String _sessionIdKey = 'active_session_id';

  final SessionBackendAdapter _backendAdapter;
  final DeviceTelemetryService _telemetryService;
  final StreamController<SessionGuardEvent> _events =
      StreamController<SessionGuardEvent>.broadcast();

  Timer? _heartbeatTimer;

  Stream<SessionGuardEvent> get events => _events.stream;

  Future<void> bootstrapAfterLogin() async {
    final userId = await _backendAdapter.getCurrentUserId();
    if (userId == null) {
      return;
    }

    try {
      final telemetry = await _telemetryService.collect();
      await _backendAdapter.upsertDeviceTelemetry(userId, telemetry);

      final sessionId = await _backendAdapter.createActiveSession(
        userId,
        telemetry,
      );
      await _backendAdapter.revokeOtherSessions(userId, sessionId);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionIdKey, sessionId);

      _heartbeatTimer?.cancel();
      _heartbeatTimer = Timer.periodic(
        const Duration(seconds: 45),
        (_) => validateCurrentSession(),
      );
      _events.add(
        const SessionGuardEvent(
          type: SessionGuardEventType.active,
          message: 'Session active on current device.',
        ),
      );
    } catch (error) {
      _events.add(
        SessionGuardEvent(
          type: SessionGuardEventType.error,
          message: 'Session guard setup failed: $error',
        ),
      );
    }
  }

  Future<void> validateCurrentSession() async {
    final userId = await _backendAdapter.getCurrentUserId();
    if (userId == null) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString(_sessionIdKey);
    if (sessionId == null || sessionId.isEmpty) {
      return;
    }

    try {
      final isActive = await _backendAdapter.isSessionActive(userId, sessionId);
      if (!isActive) {
        final activeDevice = await _backendAdapter.fetchLatestActiveDevice(
          userId,
        );
        final details = activeDevice == null
            ? ''
            : ' Active device: ${activeDevice.deviceType.toUpperCase()} ${activeDevice.deviceModel}.';

        _events.add(
          SessionGuardEvent(
            type: SessionGuardEventType.revoked,
            message: 'This device session is no longer active.$details',
            activeDevice: activeDevice,
          ),
        );
      }
    } catch (error) {
      _events.add(
        SessionGuardEvent(
          type: SessionGuardEventType.error,
          message: 'Session validation failed: $error',
        ),
      );
    }
  }

  Future<void> handleAccessError(Object error) async {
    if (_backendAdapter.isAccessDeniedError(error)) {
      _events.add(
        const SessionGuardEvent(
          type: SessionGuardEventType.invalid,
          message: 'Access denied by session policy.',
        ),
      );
    }
  }

  Future<void> clearLocalSession() async {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionIdKey);
  }

  void dispose() {
    _heartbeatTimer?.cancel();
    _events.close();
  }
}
