import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/history_model.dart';

class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'calculator_history.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            expression TEXT NOT NULL,
            result TEXT NOT NULL,
            title TEXT,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> insertHistory(HistoryModel item) async {
    final db = await database;
    return db.insert('history', item.toMap());
  }

  Future<List<HistoryModel>> getAllHistory() async {
    final db = await database;
    final rows = await db.query(
      'history',
      orderBy: 'id DESC',
    );

    return rows.map(HistoryModel.fromMap).toList();
  }

  Future<int> updateHistoryTitle(int id, String title) async {
    final db = await database;
    return db.update(
      'history',
      {'title': title},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> clearHistory() async {
    final db = await database;
    return db.delete('history');
  }
}
