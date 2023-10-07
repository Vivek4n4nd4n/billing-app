import 'package:flutter/foundation.dart';
import 'package:sqflite_common/sqlite_api.dart';
// ignore: depend_on_referenced_packages

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class SQLHelper {
  static Future<void> createTables(Database database) async {
    await database.execute("""CREATE TABLE Metal(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        metal TEXT,
        gram DOUBLE,
        costPerGram DOUBLE,
        makingCost DOUBLE,
        mcPerGram DOUBLE,

        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);
  }

  static Future<Database> db() async {
    sqfliteFfiInit();
    return databaseFactoryFfi.openDatabase(
      'dbtech.db',
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (Database db, int version) async {
          await createTables(db);
        },
      ),
    );
  }

  static Future<int> createMetal(String metalName,double gram,double costPerGram,double makingCost,doublemcPerGram) async {
    final db = await SQLHelper.db();
    final data = {'metal': metalName,'gram':gram,'costPerGram':costPerGram};
    final id = await db.insert('items', data,

        conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<String>> getItems() async {
    final db = await SQLHelper.db();
    final List<Map<String, dynamic>> results = await db.query('items', orderBy: "id");

    List<String> metalItems = [];
    for (Map<String, dynamic> result in results) {
      // Assuming 'metal' is the key in the database containing metal names.
      metalItems.add(result['metal']);
    }
    return metalItems;
  }


  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await SQLHelper.db();
    return db.query('items', where: "id = ?", whereArgs: [id], limit: 1);
  }

  static Future<int> updateItem(
      int id, String title, String? description) async {
    final db = await SQLHelper.db();
    final data = {
      'title': title,
      'description': description,
      'createdAt': DateTime.now().toString(),
    };

    final result =
        await db.update('items', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  static Future<void> deleteItem(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("items", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
}
