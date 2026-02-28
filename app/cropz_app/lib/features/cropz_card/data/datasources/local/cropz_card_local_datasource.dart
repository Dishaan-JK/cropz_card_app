import 'package:sqflite/sqflite.dart';

import '../../models/bank_info_model.dart';
import '../../models/cropz_profile_model.dart';
import '../../models/profile_address_model.dart';
import '../../../../../shared/data/local/database/app_database.dart';

class CropzCardLocalDatasource {
  const CropzCardLocalDatasource(this._appDatabase);

  final AppDatabase _appDatabase;

  Future<List<CropzProfileModel>> getProfiles() async {
    final Database db = await _appDatabase.database;
    final rows = await db.query(AppDatabase.profilesTable, orderBy: 'id DESC');
    return rows.map(CropzProfileModel.fromMap).toList();
  }

  Future<List<BankInfoModel>> getBankInfosByProfileId(int profileId) async {
    final Database db = await _appDatabase.database;
    final rows = await db.query(
      AppDatabase.bankInfoTable,
      where: 'profile_id = ?',
      whereArgs: [profileId],
      orderBy: 'id ASC',
    );
    return rows.map(BankInfoModel.fromMap).toList();
  }

  Future<List<ProfileAddressModel>> getAddressesByProfileId(
    int profileId,
  ) async {
    final Database db = await _appDatabase.database;
    final rows = await db.query(
      AppDatabase.addressesTable,
      where: 'profile_id = ?',
      whereArgs: [profileId],
      orderBy: 'id ASC',
    );
    return rows.map(ProfileAddressModel.fromMap).toList();
  }

  Future<int> saveProfileWithRelations({
    required CropzProfileModel profile,
    required List<BankInfoModel> bankInfos,
    required List<ProfileAddressModel> addresses,
  }) async {
    final Database db = await _appDatabase.database;
    return db.transaction((txn) async {
      final profileId = await upsertProfile(txn, profile);
      await replaceBankInfos(txn, profileId, bankInfos);
      await replaceAddresses(txn, profileId, addresses);
      return profileId;
    });
  }

  Future<int> upsertProfile(
    DatabaseExecutor db,
    CropzProfileModel profile,
  ) async {
    final map = profile.toMap()..remove('id');
    if (profile.id == null) {
      return db.insert(
        AppDatabase.profilesTable,
        map,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    }
    await db.update(
      AppDatabase.profilesTable,
      map,
      where: 'id = ?',
      whereArgs: [profile.id],
    );
    return profile.id!;
  }

  Future<void> replaceBankInfos(
    DatabaseExecutor db,
    int profileId,
    List<BankInfoModel> bankInfos,
  ) async {
    await db.delete(
      AppDatabase.bankInfoTable,
      where: 'profile_id = ?',
      whereArgs: [profileId],
    );
    for (final bankInfo in bankInfos) {
      await db.insert(
        AppDatabase.bankInfoTable,
        bankInfo.toMap(overrideProfileId: profileId)..remove('id'),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> replaceAddresses(
    DatabaseExecutor db,
    int profileId,
    List<ProfileAddressModel> addresses,
  ) async {
    await db.delete(
      AppDatabase.addressesTable,
      where: 'profile_id = ?',
      whereArgs: [profileId],
    );
    for (final address in addresses) {
      await db.insert(
        AppDatabase.addressesTable,
        address.toMap(overrideProfileId: profileId)..remove('id'),
      );
    }
  }
}
