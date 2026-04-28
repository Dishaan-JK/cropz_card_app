import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class CropzCardLocalJsonExportService {
  const CropzCardLocalJsonExportService();

  Future<List<String>> export({
    required String fileStem,
    required String payloadJson,
  }) async {
    final written = <String>[];
    final sanitizedStem = _sanitizeFileStem(fileStem);
    final candidates = <Directory>[];

    final appDocs = await getApplicationDocumentsDirectory();
    candidates.add(Directory(p.join(appDocs.path, 'Cropz Card')));

    final externalDir = await getExternalStorageDirectory();
    if (externalDir != null) {
      candidates.add(Directory(p.join(externalDir.path, 'Cropz Card')));
    }

    final docDirs = await getExternalStorageDirectories(
      type: StorageDirectory.documents,
    );
    if (docDirs != null) {
      for (final dir in docDirs) {
        candidates.add(Directory(p.join(dir.path, 'Cropz Card')));
      }
    }

    candidates.addAll([
      Directory('/storage/emulated/0/Documents/Cropz Card'),
      Directory('/storage/emulated/0/Download/Cropz Card'),
    ]);

    for (final target in candidates) {
      try {
        await target.create(recursive: true);
        final file = File(p.join(target.path, '$sanitizedStem.json'));
        await file.writeAsString(payloadJson, flush: true);
        written.add(file.path);
      } catch (_) {
        // Continue trying next location.
      }
    }

    if (written.isEmpty) {
      throw const FileSystemException(
        'Unable to export card JSON to any local storage location.',
      );
    }

    return written;
  }

  String _sanitizeFileStem(String input) {
    final sanitized = input.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    return sanitized.isEmpty ? 'card' : sanitized;
  }
}
