import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static const String _databaseName = 'cropz_local.db';
  static const int _databaseVersion = 4;

  static const String profilesTable = 'profiles';
  static const String bankInfoTable = 'bank_info';
  static const String addressesTable = 'addresses';
  static const String cardSyncQueueTable = 'card_sync_queue';

  Database? _db;

  Future<Database> get database async {
    if (_db != null) {
      return _db!;
    }
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _databaseName);

    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: (db) async {
        await _ensureCardSyncQueueSchema(db);
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $profilesTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cropzid TEXT,
        firmname TEXT NOT NULL,
        ownername TEXT,
        mobile TEXT NOT NULL,
        whatsapp TEXT,
        email TEXT,
        gstno TEXT,
        slno TEXT,
        slexpdate TEXT,
        plno TEXT,
        retailflno TEXT,
        retailflexpdate TEXT,
        wsflno TEXT,
        wsflexpdate TEXT,
        fmsretailid TEXT,
        fmswsid TEXT,
        gst_document TEXT,
        sl_document TEXT,
        pl_document TEXT,
        fl_document TEXT,
        profile_picture TEXT,
        companies TEXT,
        upiid TEXT,
        qrcode TEXT,
        transport TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $bankInfoTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        profile_id INTEGER NOT NULL,
        name TEXT,
        accountno TEXT,
        accounttype TEXT,
        ifsccode TEXT,
        bankname TEXT,
        branch TEXT,
        FOREIGN KEY(profile_id) REFERENCES $profilesTable(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE $addressesTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        profile_id INTEGER NOT NULL,
        cropzid TEXT,
        addresstype TEXT,
        address1 TEXT,
        address2 TEXT,
        address3 TEXT,
        city TEXT,
        taluk TEXT,
        block TEXT,
        district TEXT,
        state TEXT,
        pincode TEXT,
        ingst INTEGER,
        parentcropzid TEXT,
        FOREIGN KEY(profile_id) REFERENCES $profilesTable(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE $cardSyncQueueTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        owner_key TEXT NOT NULL,
        card_key TEXT NOT NULL,
        payload_json TEXT NOT NULL,
        deleted INTEGER NOT NULL DEFAULT 0,
        updated_at_ms INTEGER NOT NULL,
        attempts INTEGER NOT NULL DEFAULT 0,
        last_error TEXT
      )
    ''');
    await db.execute(
      'CREATE UNIQUE INDEX idx_card_sync_unique ON $cardSyncQueueTable(card_key)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _dropAllTables(db);
      await _onCreate(db, newVersion);
      return;
    }

    if (oldVersion < 3) {
      await db.execute(
        'ALTER TABLE $profilesTable ADD COLUMN profile_picture TEXT',
      );
    }

    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $cardSyncQueueTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          owner_key TEXT NOT NULL,
          card_key TEXT NOT NULL,
          payload_json TEXT NOT NULL,
          deleted INTEGER NOT NULL DEFAULT 0,
          updated_at_ms INTEGER NOT NULL,
          attempts INTEGER NOT NULL DEFAULT 0,
          last_error TEXT
        )
      ''');
      await db.execute(
        'CREATE UNIQUE INDEX IF NOT EXISTS idx_card_sync_unique ON $cardSyncQueueTable(card_key)',
      );
    }
  }

  Future<void> _dropAllTables(Database db) async {
    await db.execute('DROP TABLE IF EXISTS $cardSyncQueueTable');
    await db.execute('DROP TABLE IF EXISTS $addressesTable');
    await db.execute('DROP TABLE IF EXISTS $bankInfoTable');
    await db.execute('DROP TABLE IF EXISTS $profilesTable');
  }

  Future<void> _ensureCardSyncQueueSchema(Database db) async {
    final tableExists = await _tableExists(db, cardSyncQueueTable);
    if (!tableExists) {
      await db.execute('''
        CREATE TABLE $cardSyncQueueTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          owner_key TEXT NOT NULL,
          card_key TEXT NOT NULL,
          payload_json TEXT NOT NULL,
          deleted INTEGER NOT NULL DEFAULT 0,
          updated_at_ms INTEGER NOT NULL,
          attempts INTEGER NOT NULL DEFAULT 0,
          last_error TEXT
        )
      ''');
      await db.execute(
        'CREATE UNIQUE INDEX IF NOT EXISTS idx_card_sync_unique ON $cardSyncQueueTable(card_key)',
      );
      return;
    }

    final rows = await db.rawQuery('PRAGMA table_info($cardSyncQueueTable)');
    final columns = rows
        .map((row) => (row['name'] ?? '').toString())
        .where((name) => name.isNotEmpty)
        .toSet();

    if (!columns.contains('owner_key')) {
      await db.execute(
        'ALTER TABLE $cardSyncQueueTable ADD COLUMN owner_key TEXT NOT NULL DEFAULT \'\'',
      );
    }
    if (!columns.contains('card_key')) {
      await db.execute(
        'ALTER TABLE $cardSyncQueueTable ADD COLUMN card_key TEXT NOT NULL DEFAULT \'\'',
      );
    }
    if (!columns.contains('payload_json')) {
      await db.execute(
        'ALTER TABLE $cardSyncQueueTable ADD COLUMN payload_json TEXT NOT NULL DEFAULT \'{}\'',
      );
    }
    if (!columns.contains('deleted')) {
      await db.execute(
        'ALTER TABLE $cardSyncQueueTable ADD COLUMN deleted INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (!columns.contains('updated_at_ms')) {
      await db.execute(
        'ALTER TABLE $cardSyncQueueTable ADD COLUMN updated_at_ms INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (!columns.contains('attempts')) {
      await db.execute(
        'ALTER TABLE $cardSyncQueueTable ADD COLUMN attempts INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (!columns.contains('last_error')) {
      await db.execute(
        'ALTER TABLE $cardSyncQueueTable ADD COLUMN last_error TEXT',
      );
    }

    await db.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_card_sync_unique ON $cardSyncQueueTable(card_key)',
    );
  }

  Future<bool> _tableExists(Database db, String tableName) async {
    final rows = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name = ?",
      [tableName],
    );
    return rows.isNotEmpty;
  }
}
