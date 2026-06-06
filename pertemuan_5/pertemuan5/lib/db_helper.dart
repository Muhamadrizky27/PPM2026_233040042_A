import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'catatan.dart';

class DbHelper {
  DbHelper._();
  static final DbHelper instance = DbHelper._();

  static const _dbName = 'catatan.db';
  static const _dbVersion = 1;
  static const tabel = 'catatan';

  Database? _db;

  // GLOBAL MEMORY STORAGE UNTUK WEB
  static final List<Catatan> _dbWebMemori = [];
  static int _nextWebId = 1;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _openDb();
    return _db!;
  }

  Future<Database> _openDb() async {
    if (kIsWeb) {
      debugPrint("DB_HELPER: Mode WEB Aktif");
      return DatabaseDummy();
    }
    
    final dir = await getDatabasesPath();
    final path = join(dir, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tabel (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            judul       TEXT    NOT NULL,
            isi         TEXT    NOT NULL,
            kategori    TEXT    NOT NULL,
            dibuat_pada INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> insert(Catatan c) async {
    if (kIsWeb) {
      final baru = Catatan(
        id: _nextWebId++,
        judul: c.judul,
        isi: c.isi,
        kategori: c.kategori,
        dibuatPada: c.dibuatPada,
      );
      _dbWebMemori.add(baru);
      return baru.id!;
    }
    final db = await database;
    return db.insert(tabel, c.toMap());
  }

  Future<List<Catatan>> getAll() async {
    if (kIsWeb) {
      final sorted = List<Catatan>.from(_dbWebMemori);
      sorted.sort((a, b) => b.dibuatPada.compareTo(a.dibuatPada));
      return sorted;
    }
    final db = await database;
    final rows = await db.query(tabel, orderBy: 'dibuat_pada DESC');
    return rows.map(Catatan.fromMap).toList();
  }

  Future<int> update(Catatan c) async {
    if (kIsWeb) {
      final index = _dbWebMemori.indexWhere((item) => item.id == c.id);
      if (index != -1) {
        _dbWebMemori[index] = c;
        return 1;
      }
      return 0;
    }
    final db = await database;
    return db.update(tabel, c.toMap(), where: 'id = ?', whereArgs: [c.id]);
  }

  Future<int> delete(int id) async {
    if (kIsWeb) {
      _dbWebMemori.removeWhere((item) => item.id == id);
      return 1;
    }
    final db = await database;
    return db.delete(tabel, where: 'id = ?', whereArgs: [id]);
  }
}

// PERBAIKAN: Menambahkan noSuchMethod agar tidak error kompilasi di Web
class DatabaseDummy implements Database {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
