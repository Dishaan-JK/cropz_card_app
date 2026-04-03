class ActiveDeviceInfo {
  const ActiveDeviceInfo({
    required this.deviceId,
    required this.deviceType,
    required this.deviceModel,
    this.lastSeenAt,
  });

  final String deviceId;
  final String deviceType;
  final String deviceModel;
  final DateTime? lastSeenAt;
}

enum SessionGuardEventType { active, revoked, invalid, error }

class SessionGuardEvent {
  const SessionGuardEvent({
    required this.type,
    required this.message,
    this.activeDevice,
  });

  final SessionGuardEventType type;
  final String message;
  final ActiveDeviceInfo? activeDevice;
}
