import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/services/device_telemetry_service.dart';
import '../../data/services/session_backend_adapter.dart';
import '../../data/services/session_guard_event.dart';
import '../../data/services/session_guard_service.dart';
import '../../data/services/supabase_session_backend_adapter.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final sessionBackendAdapterProvider = Provider<SessionBackendAdapter>((ref) {
  return SupabaseSessionBackendAdapter(ref.watch(supabaseClientProvider));
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
