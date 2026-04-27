import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/device_telemetry_service.dart';
import '../../data/services/local_session_backend_adapter.dart';
import '../../data/services/session_backend_adapter.dart';
import '../../data/services/session_guard_event.dart';
import '../../data/services/session_guard_service.dart';

final localSessionBackendAdapterProvider = Provider<LocalSessionBackendAdapter>(
  (ref) => LocalSessionBackendAdapter(),
);

final sessionBackendAdapterProvider = Provider<SessionBackendAdapter>((ref) {
  return ref.watch(localSessionBackendAdapterProvider);
});

final deviceTelemetryServiceProvider = Provider<DeviceTelemetryService>((ref) {
  return DeviceTelemetryService();
});

final sessionGuardServiceProvider = Provider<SessionGuardService>((ref) {
  final service = SessionGuardService(
    backendAdapter: ref.watch(sessionBackendAdapterProvider),
    telemetryService: ref.watch(deviceTelemetryServiceProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});

final sessionGuardEventsProvider = StreamProvider<SessionGuardEvent>((ref) {
  return ref.watch(sessionGuardServiceProvider).events;
});
