import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:hive/hive.dart';


// Database Service
class DatabaseService {
  static late Box taskBox;
  static late Database _database;

  static Future<void> init() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
    taskBox = await Hive.openBox('tasks');

    final dbPath = join(appDocumentDir.path, 'tasks.db');
    _database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        isCompleted INTEGER,
        dueDate TEXT  -- Add this line for the due date
      )
    ''');
  }

  static Database get database => _database;
}