class CardSyncQueueItem {
  const CardSyncQueueItem({
    this.id,
    required this.ownerKey,
    required this.cardKey,
    required this.payloadJson,
    this.deleted = false,
    required this.updatedAtMs,
    this.attempts = 0,
    this.lastError,
  });

  final int? id;
  final String ownerKey;
  final String cardKey;
  final String payloadJson;
  final bool deleted;
  final int updatedAtMs;
  final int attempts;
  final String? lastError;

  CardSyncQueueItem copyWith({
    int? id,
    String? ownerKey,
    String? cardKey,
    String? payloadJson,
    bool? deleted,
    int? updatedAtMs,
    int? attempts,
    String? lastError,
  }) {
    return CardSyncQueueItem(
      id: id ?? this.id,
      ownerKey: ownerKey ?? this.ownerKey,
      cardKey: cardKey ?? this.cardKey,
      payloadJson: payloadJson ?? this.payloadJson,
      deleted: deleted ?? this.deleted,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'owner_key': ownerKey,
      'card_key': cardKey,
      'payload_json': payloadJson,
      'deleted': deleted ? 1 : 0,
      'updated_at_ms': updatedAtMs,
      'attempts': attempts,
      'last_error': lastError,
    };
  }

  factory CardSyncQueueItem.fromMap(Map<String, Object?> map) {
    return CardSyncQueueItem(
      id: map['id'] as int?,
      ownerKey: (map['owner_key'] ?? '').toString(),
      cardKey: (map['card_key'] ?? '').toString(),
      payloadJson: (map['payload_json'] ?? '{}').toString(),
      deleted: (map['deleted'] as int? ?? 0) == 1,
      updatedAtMs: (map['updated_at_ms'] as num?)?.toInt() ?? 0,
      attempts: (map['attempts'] as num?)?.toInt() ?? 0,
      lastError: map['last_error'] as String?,
    );
  }
}
