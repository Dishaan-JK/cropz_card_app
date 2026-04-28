import 'package:sqflite/sqflite.dart';

import '../../../../../shared/data/local/database/app_database.dart';
import '../../models/card_sync_queue_item.dart';

class CropzCardSyncLocalDatasource {
  const CropzCardSyncLocalDatasource(this._appDatabase);

  final AppDatabase _appDatabase;

  Future<void> upsertQueueItem(CardSyncQueueItem item) async {
    final db = await _appDatabase.database;
    final row = await _buildSafeInsertRow(db, item);
    await db.insert(
      AppDatabase.cardSyncQueueTable,
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, Object?>> _buildSafeInsertRow(
    Database db,
    CardSyncQueueItem item,
  ) async {
    final row = item.toMap();
    row['operation'] = (row['operation'] ?? 'upsert').toString();
    row['local_profile_id'] = row['local_profile_id'] ?? item.localProfileId;

    final tableInfo = await db.rawQuery(
      'PRAGMA table_info(${AppDatabase.cardSyncQueueTable})',
    );

    for (final info in tableInfo) {
      final name = (info['name'] ?? '').toString();
      if (name.isEmpty || name == 'id') {
        continue;
      }
      final notNull = (info['notnull'] as num?)?.toInt() == 1;
      if (!notNull || row.containsKey(name)) {
        continue;
      }

      final defaultValue = info['dflt_value'];
      if (defaultValue != null) {
        row[name] = _parseSqlDefault(defaultValue.toString());
        continue;
      }

      final type = (info['type'] ?? '').toString().toUpperCase();
      if (type.contains('INT') || type.contains('REAL') || type.contains('NUM')) {
        row[name] = 0;
      } else {
        row[name] = '';
      }
    }

    return row;
  }

  Object _parseSqlDefault(String raw) {
    var value = raw.trim();
    if (value.startsWith("'") && value.endsWith("'") && value.length >= 2) {
      value = value.substring(1, value.length - 1);
    }
    final asInt = int.tryParse(value);
    if (asInt != null) {
      return asInt;
    }
    final asDouble = double.tryParse(value);
    if (asDouble != null) {
      return asDouble;
    }
    return value;
  }

  Future<List<CardSyncQueueItem>> pendingQueue({int limit = 25}) async {
    final db = await _appDatabase.database;
    final rows = await db.query(
      AppDatabase.cardSyncQueueTable,
      orderBy: 'updated_at_ms DESC',
      limit: limit,
    );
    return rows.map(CardSyncQueueItem.fromMap).toList(growable: false);
  }

  Future<void> markSynced(int id) async {
    final db = await _appDatabase.database;
    await db.delete(
      AppDatabase.cardSyncQueueTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markFailed({
    required int id,
    required int attempts,
    required String error,
  }) async {
    final db = await _appDatabase.database;
    await db.update(
      AppDatabase.cardSyncQueueTable,
      <String, Object?>{
        'attempts': attempts,
        'last_error': error,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
