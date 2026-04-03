import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceTelemetry {
  const DeviceTelemetry({
    required this.deviceId,
    required this.platform,
    required this.model,
  });

  final String deviceId;
  final String platform;
  final String model;
}

class DeviceTelemetryService {
  DeviceTelemetryService();

  static const String _deviceIdKey = 'cropz_device_id';

  final DeviceInfoPlugin _infoPlugin = DeviceInfoPlugin();
  final Uuid _uuid = const Uuid();

  Future<DeviceTelemetry> collect() async {
    final prefs = await SharedPreferences.getInstance();
    final existingId = prefs.getString(_deviceIdKey);
    final deviceId = existingId ?? _uuid.v4();
    if (existingId == null) {
      await prefs.setString(_deviceIdKey, deviceId);
    }

    if (Platform.isAndroid) {
      final info = await _infoPlugin.androidInfo;
      return DeviceTelemetry(
        deviceId: deviceId,
        platform: 'android',
        model: info.model,
      );
    }
    if (Platform.isIOS) {
      final info = await _infoPlugin.iosInfo;
      return DeviceTelemetry(
        deviceId: deviceId,
        platform: 'ios',
        model: info.utsname.machine,
      );
    }
    if (Platform.isWindows) {
      final info = await _infoPlugin.windowsInfo;
      return DeviceTelemetry(
        deviceId: deviceId,
        platform: 'windows',
        model: info.computerName,
      );
    }

    return DeviceTelemetry(
      deviceId: deviceId,
      platform: Platform.operatingSystem,
      model: 'unknown',
    );
  }
}
