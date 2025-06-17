import 'dart:async';
import 'dart:collection';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  DatabaseHelper._internal(); //自定义构造函数

  static final _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  static Database? _database;
  static const _strTableClassesName = "classes_infor";
  static const _strTableStudentName = "students_infor";

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final docDir = await getApplicationDocumentsDirectory();

    String dbStr = join(docDir.path, 'local_database.db');
    return await openDatabase(dbStr, version: 1, onCreate: _onCreate);
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    await db.execute('PRAGMA foreign_keys = ON');
    await db.execute('''
    CREATE TABLE IF NOT EXISTS classes_info(
    class_number INTEGER NOT NULL UNIQUE,
    class_name TEXT NOT NULL UNIQUE,
    PRIMARY KEY(class_number AUTOINCREMENT)
    );
    CREATE TABLE IF NOT EXISTS students_info(
    student_id INTEGER NOT NULL UNIQUE,
    class_number INTEGET NOT NULL,
    student_name TEXT NOT NULL,
    PRIMARY KEY(student_id AUTOINCREMENT),
    FOREIGN KEY(class_number) REFERENCES classes_info(class_number) 
    ON DELETE CASCADE ON UPDATE CASCADE
    )''');
  }

  void insertClassInfor(String className) async {
    final db = await database;
    await db.insert(_strTableClassesName, {'class_name': className});
  }

  void insertStudentInfo(String className, String studentName) async {
    final db = await database;
    await db.insert(_strTableStudentName, {
      'class_name': className,
      'student_name': studentName,
    });
  }

  //查询整个classInfor表格
  Future selectClassesInfor() async {
    final db = await database;
    return await db.query(_strTableClassesName);
  }

  Future selectStudentInfor() async {
    final db = await database;
    return await db.query(_strTableStudentName);
  }
}
