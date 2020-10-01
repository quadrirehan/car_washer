import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper{
  //TODO: PASS "DATABASE_NAME.db"
  String _databaseName = "carwasher.db";
  int _databaseVersion = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

// only have a single app-wide reference to the database
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) {
    //TODO: CREATE TABLE QUERY
    db.execute("CREATE TABLE washer(id INTEGER PRIMARY KEY AUTOINCREMENT, washer_id TEXT, washer_name TEXT, washer_mobile TEXT, washer_email TEXT, washer_password TEXT, washer_address TEXT)");
  }

  Future<int> insertWasher(String washer_id, String washer_name, String washer_mobile, String washer_email, String washer_password, String washer_address) async{
    //TODO: RAW INSERT QUERY
    Database db = await instance.database;
    return db.rawInsert("INSERT INTO washer(washer_id, washer_name, washer_mobile, washer_email, washer_password, washer_address) VALUES('$washer_id', '$washer_name', '$washer_mobile', '$washer_email', '$washer_password', '$washer_address')");
  }

  Future<int> getCount() async {
    Database db = await instance.database;
    var x = await db.rawQuery('SELECT COUNT (*) from washer');
    int count = Sqflite.firstIntValue(x);
    return count;
  }

  Future<List> getWasher() async{
    Database db = await instance.database;
    return db.rawQuery("SELECT * FROM washer");
  }
  
  Future<void> deleteWasher() async{
    Database db = await instance.database;
    db.rawDelete("DELETE FROM washer");
  }
}	//class DatabaseHelper close