import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/voice_test.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'parkinson_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE voice_tests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        date TEXT NOT NULL,
        probability REAL NOT NULL,
        level TEXT NOT NULL,
        fo REAL,
        fhi REAL,
        flo REAL,
        jitter_percent REAL,
        jitter_abs REAL,
        rap REAL,
        ppq REAL,
        ddp REAL,
        shimmer REAL,
        shimmer_db REAL,
        apq3 REAL,
        apq5 REAL,
        apq REAL,
        dda REAL,
        nhr REAL,
        hnr REAL,
        rpde REAL,
        dfa REAL,
        spread1 REAL,
        spread2 REAL,
        d2 REAL,
        ppe REAL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 1) {
      await _onCreate(db, newVersion);
    }
  }

  // Insertar resultado de prueba de voz
  Future<int> insertVoiceTest(VoiceTest voiceTest) async {
    final db = await database;
    return await db.insert('voice_tests', voiceTest.toMap());
  }

  // Obtener todos los resultados de un usuario
  Future<List<VoiceTest>> getVoiceTestsByUserId(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'voice_tests',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => VoiceTest.fromMap(maps[i]));
  }

  // Obtener todos los resultados
  Future<List<VoiceTest>> getAllVoiceTests() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'voice_tests',
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => VoiceTest.fromMap(maps[i]));
  }

  // Obtener un resultado por ID
  Future<VoiceTest?> getVoiceTestById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'voice_tests',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return VoiceTest.fromMap(maps.first);
    }
    return null;
  }

  // Eliminar un resultado
  Future<int> deleteVoiceTest(int id) async {
    final db = await database;
    return await db.delete(
      'voice_tests',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Actualizar un resultado
  Future<int> updateVoiceTest(VoiceTest voiceTest) async {
    final db = await database;
    return await db.update(
      'voice_tests',
      voiceTest.toMap(),
      where: 'id = ?',
      whereArgs: [voiceTest.id],
    );
  }
}





