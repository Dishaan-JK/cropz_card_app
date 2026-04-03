import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class AccessPermissionService {
  const AccessPermissionService();

  Future<bool> requestStorageAccess(
    BuildContext context, {
    required String reason,
  }) async {
    final approved = await _showAccessExplainer(context, reason: reason);
    if (!approved) {
      return false;
    }

    if (!Platform.isAndroid && !Platform.isIOS) {
      return true;
    }

    if (Platform.isIOS) {
      final photosStatus = await Permission.photos.request();
      return photosStatus.isGranted || photosStatus.isLimited;
    }

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;
    if (sdkInt >= 33) {
      final photosStatus = await Permission.photos.request();
      if (photosStatus.isGranted || photosStatus.isLimited) {
        return true;
      }
      final mediaStatus = await Permission.videos.request();
      return mediaStatus.isGranted || mediaStatus.isLimited;
    }

    final storageStatus = await Permission.storage.request();
    return storageStatus.isGranted;
  }

  Future<bool> _showAccessExplainer(
    BuildContext context, {
    required String reason,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Permission Required'),
          content: Text(reason),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Not Now'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }
}
