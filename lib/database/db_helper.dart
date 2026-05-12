import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/todo_model.dart';
import '../models/user_model.dart';

class DbHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'agenda_nusantara.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Tabel Users
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT,
            password TEXT
          )
        ''');

        // Insert akun default
        await db.insert('users', {'username': 'user', 'password': 'user'});

        // Tabel Tasks
        await db.execute('''
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            judul TEXT,
            deskripsi TEXT,
            tanggal TEXT,
            kategori TEXT,
            status_selesai INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }

  // ==========================================
  // FITUR USER (LOGIN & GANTI PASSWORD)
  // ==========================================
  
  Future<bool> login(String username, String password) async {
    final db = await database;
    var res = await db.query('users', where: 'username = ? AND password = ?', whereArgs: [username, password]);
    return res.isNotEmpty;
  }

  Future<bool> updatePassword(String oldPassword, String newPassword) async {
    final db = await database;
    // Cek password lama dulu
    var res = await db.query('users', where: 'username = ? AND password = ?', whereArgs: ['user', oldPassword]);
    if (res.isNotEmpty) {
      await db.update('users', {'password': newPassword}, where: 'username = ?', whereArgs: ['user']);
      return true;
    }
    return false;
  }

  // ==========================================
  // FITUR TUGAS (CRUD & STATISTIK)
  // ==========================================

  // CREATE: Tambah tugas baru
  Future<int> insertTask(Todo todo) async {
    final db = await database;
    return await db.insert('tasks', todo.toMap());
  }

  // READ: Ambil semua data tugas
  Future<List<Todo>> getTasks() async {
    final db = await database;
    var res = await db.query('tasks', orderBy: 'id DESC');
    return res.isNotEmpty ? res.map((c) => Todo.fromMap(c)).toList() : [];
  }

  // UPDATE: Edit isi tugas secara utuh (Fitur Edit)
  Future<int> updateTask(Todo todo) async {
    final db = await database;
    return await db.update(
      'tasks',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  // UPDATE: Ubah status selesai (Fitur Checkbox)
  Future<int> updateTaskStatus(int id, int statusSelesai) async {
    final db = await database;
    return await db.update('tasks', {'status_selesai': statusSelesai}, where: 'id = ?', whereArgs: [id]);
  }

  // DELETE: Hapus tugas (Fitur Swipe-to-Delete)
  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // STATISTIK: Hitung jumlah data
  Future<int> getCount(int status) async {
    final db = await database;
    var res = await db.rawQuery('SELECT COUNT(*) FROM tasks WHERE status_selesai = $status');
    return Sqflite.firstIntValue(res) ?? 0;
  }
}