import 'package:sqflite/sqflite.dart';
import 'package:task_project/models/sql_model.dart';

import 'local_database_service.dart';

class TodoFunctions {
  final tableName = 'todos';

  Future<void> createTable(Database database) async {
    await database.execute("""
    CREATE TABLE IF NOT EXISTS $tableName (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      description TEXT, 
      created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
      updated_at INTEGER
    );
  """);
  }

  Future<int> create({required String title, required String description}) async {
    final database = await DatabaseService().database;
    return await database.rawInsert(
      '''INSERT INTO $tableName (title, description, created_at) VALUES (?, ?, ?)''',
      [title, description, DateTime.now().millisecondsSinceEpoch],
    );
  }

  Future<List<SQLModel>> fetchAll() async {
    final database = await DatabaseService().database;
    final todos = await database.rawQuery(
        '''SELECT * FROM $tableName ORDER BY COALESCE(description, updated_at, created_at)'''
    );
    return todos.map((todo) => SQLModel.fromSqfliteDatabase(todo)).toList();
  }

  Future<SQLModel> fetchById(int id) async{
    final database = await DatabaseService().database;
    final todo = await database.rawQuery(
        '''SELECT * from $tableName WHERE id = ?''',[id]
    );
    return SQLModel.fromSqfliteDatabase(todo.first);
  }

  Future<int> update({required int id, String? title, String? description}) async {
    final database = await DatabaseService().database;
    return await database.update(
      tableName,
      {
        'title': title,
        'description':description,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      conflictAlgorithm: ConflictAlgorithm.rollback,
      whereArgs: [id],
    );
  }

  Future<void> delete(int id) async{
    final database = await DatabaseService().database;
    await database.rawDelete(
        '''DELETE FROM $tableName WHERE id = ? ''',[id]
    );
  }
}
