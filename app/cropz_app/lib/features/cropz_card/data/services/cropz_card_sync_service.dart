import '../../domain/entities/cropz_card_details.dart';
import '../datasources/local/cropz_card_sync_local_datasource.dart';
import '../datasources/remote/pocketbase_card_remote_datasource.dart';
import '../models/card_sync_queue_item.dart';
import 'cropz_card_payload_codec.dart';

class CropzCardSyncService {
  const CropzCardSyncService({
    required CropzCardSyncLocalDatasource localDatasource,
    required PocketbaseCardRemoteDatasource remoteDatasource,
    required CropzCardPayloadCodec payloadCodec,
  }) : _localDatasource = localDatasource,
       _remoteDatasource = remoteDatasource,
       _payloadCodec = payloadCodec;

  final CropzCardSyncLocalDatasource _localDatasource;
  final PocketbaseCardRemoteDatasource _remoteDatasource;
  final CropzCardPayloadCodec _payloadCodec;

  Future<void> enqueueUpsert({
    required String ownerKey,
    required String cardKey,
    required CropzCardDetails details,
    bool deleted = false,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final queueItem = CardSyncQueueItem(
      ownerKey: ownerKey,
      cardKey: cardKey,
      payloadJson: _payloadCodec.encode(details),
      deleted: deleted,
      updatedAtMs: now,
    );
    await _localDatasource.upsertQueueItem(queueItem);
  }

  Future<void> flush({String? authToken}) async {
    final pending = await _localDatasource.pendingQueue();
    for (final item in pending) {
      final id = item.id;
      if (id == null) {
        continue;
      }
      try {
        await _remoteDatasource.upsertCard(
          ownerKey: item.ownerKey,
          cardKey: item.cardKey,
          payloadJson: item.payloadJson,
          deleted: item.deleted,
          updatedAtMs: item.updatedAtMs,
          authToken: authToken,
        );
        await _localDatasource.markSynced(id);
      } catch (error) {
        await _localDatasource.markFailed(
          id: id,
          attempts: item.attempts + 1,
          error: error.toString(),
        );
      }
    }
  }
}
