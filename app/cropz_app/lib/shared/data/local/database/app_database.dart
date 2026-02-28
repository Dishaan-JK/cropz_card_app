import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static const String _databaseName = 'cropz_local.db';
  static const int _databaseVersion = 3;

  static const String profilesTable = 'profiles';
  static const String bankInfoTable = 'bank_info';
  static const String addressesTable = 'addresses';

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
  }

  Future<void> _dropAllTables(Database db) async {
    await db.execute('DROP TABLE IF EXISTS $addressesTable');
    await db.execute('DROP TABLE IF EXISTS $bankInfoTable');
    await db.execute('DROP TABLE IF EXISTS $profilesTable');
  }
}
