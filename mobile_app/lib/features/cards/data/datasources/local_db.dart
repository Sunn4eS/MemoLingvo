import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;



part 'local_db.g.dart';

class WordTables extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get original => text()();
  TextColumn get translated => text()();
  TextColumn get example => text().nullable()();
}

@DriftDatabase(tables: [WordTables])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Stream<List<WordTable>> watchWords() => select(wordTables).watch();

  Future<int> insertWord(WordTablesCompanion word) => into(wordTables).insert(word);

  Future<void> deleteWord(int id) => (delete(wordTables)..where((t) => t.id.equals(id))).go();

}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

