import 'package:sqflite/sqflite.dart';

import '../../../../../shared/data/local/database/app_database.dart';
import '../../models/card_sync_queue_item.dart';

class CropzCardSyncLocalDatasource {
  const CropzCardSyncLocalDatasource(this._appDatabase);

  final AppDatabase _appDatabase;

  Future<void> upsertQueueItem(CardSyncQueueItem item) async {
    final db = await _appDatabase.database;
    await db.insert(
      AppDatabase.cardSyncQueueTable,
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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
