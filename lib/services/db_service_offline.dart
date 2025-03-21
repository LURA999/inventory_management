import 'dart:io';
import 'package:control_inv/models/services/services_model.dart';
import 'package:path/path.dart';

// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

class DBService {
  static Database? _database;
  static final DBService db = DBService._();
  DBService._();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDB();

    return _database!;
  }

  Future<Database> initDB() async {
    // Future<Directory?> documentsDirectory =  getApplicationDocumentsDirectory();
    // Future<Directory?> documentsDirectory =  getExternalStorageDirectory();
    Directory directory = Directory('/storage/emulated/0/Download/');
    String path = join(/* (await documentsDirectory)!.path */ directory.path,'inventory.db');
    return await openDatabase(path, version: 1,onOpen: (db) {} ,onCreate: _onCreateDatabase);
  }

  _onCreateDatabase(Database db, int version) async {
    //Registra todas las comidas, con sus caracteristicas respectivas
    await db.execute('''
      CREATE TABLE menu (
        idMenu INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        imagePath TEXT NOT NULL,
        description TEXT,
        price NUMERIC NOT NULL,
        active INTEGER NOT NULL,
        cveCategory INTEGER NOT NULL,
        FOREIGN KEY (cveCategory) REFERENCES categories (idCategory) ON DELETE CASCADE
      );
    ''');

    //Registra las ventas
    await db.execute('''
      CREATE TABLE sale (
        idSale INTEGER PRIMARY KEY AUTOINCREMENT,
        id INTEGER NOT NULL,
        date DATETIME NOT NULL,
        amount INTEGER NOT NULL,
        cveMenu INTEGER NOT NULL,
        FOREIGN KEY (cveMenu) REFERENCES menu (idMenu) ON DELETE CASCADE
      );
    ''');

    //Registra las categorias
    await db.execute('''
      CREATE TABLE categories (
        idCategory INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        active INTEGER NOT NULL
      );
    ''');

    /* await db.execute(
        'CREATE TRIGGER IF NOT EXISTS id_alternative_sale AFTER INSERT ON sale '
        'BEGIN '
          'UPDATE sale SET id = (SELECT COALESCE(MAX(id), 0) FROM sale) + 1 '
          'WHERE  cveMenu = new.cveMenu; '
        'END',
      ); */
  }

  //Table categories
  Future<int> newCategory(Categories obj) async{
    final db = await database;
    final res = await db.insert('categories', obj.toJson());
    return res;
  }

  Future<List<Categories>?> showCategories() async {
    final db = await database;
    final res = await db.query('categories', orderBy: "idCategory asc");
    List<Categories> list = []; 
    for (var el in res) {
      list.add( Categories.fromJson(el));
    } 
    return res.isNotEmpty ? list : null;
  } 

  Future<int> deleteCategory(int id) async{
    final db = await database;
    final res = await db.delete('categories', where: 'idCategory = ?', whereArgs: [id]);
    return res;
  }

  Future<int> updateCategory(Categories obj) async{
    final db = await database;
    final res = await db.update('categories', obj.toJson(), where: 'idCategory = ?', whereArgs: [obj.idCategory]);
    return res;
  }


  //Table menu
  Future<int> newFood(ImageData obj) async{
    final db = await database;
    final res = await db.insert('menu', obj.toJson());
    return res;
  }
  
  Future<List<ImageData>?> showFoods() async {
    final db = await database;
    final res = await db.query('menu');
    List<ImageData> list = []; 
    for (var el in res) {
      list.add(ImageData.fromJson(el));
    } 
    return res.isNotEmpty ? list : null;
  }

  Future<List<CarthistorialModel>?> showFoodsSale(int id) async {
    final db = await database;
    final res = await db.rawQuery(
      'SELECT idMenu, name, imagePath, price, description, active, cveCategory, sum(amount) amount, idSale '
      'FROM sale INNER JOIN menu ON cveMenu = idMenu '
      'WHERE id= $id '
      'GROUP BY cveMenu ORDER BY cveMenu asc');
    List<CarthistorialModel> list = []; 
    for (var el in res) {
      list.add(CarthistorialModel.fromJson(el));
    } 
    return res.isNotEmpty ? list : null;
  }

  Future<List<ImageData>?> showFoodsCategory(int id, int active) async {
    final db = await database;

    List<int> args = [];
    String sentencia = "";

    if (active == 3) {
      args = [id];
    } else {
      sentencia =  "AND active = ?";
      args = [id, active];
    }
    
    final res = await db.query('menu', where: "cveCategory = ?  $sentencia " , whereArgs: args);

    List<ImageData> list = [];
    for (var el in res) {
      list.add(ImageData.fromJson(el));
    } 
    return list.isNotEmpty ? list : null;
  }
  
  Future<int> updateFood(ImageData obj) async {
    final db = await database;
    final res = await db.update('menu', obj.toJson(), where: 'idMenu = ?', whereArgs: [obj.idMenu]);
    return res;
  }

  Future<int> deleteFood(int id) async {
    final db = await database;
    final res = await db.delete('menu', where: 'idMenu = ?', whereArgs: [id]);
    return res;
  } 

  //Table sales
  Future<int> insertSale(SalesModel obj) async {
    final db = await database;
    final res = await db.insert('sale', obj.toJson());
    return res;
  }
  
  Future<int> counterSale() async {
    final db = await database;
    final results = await db.rawQuery('Select id from sale Group by id Order by id desc limit 1');
    int count = results.isNotEmpty ? results.first['id'] as int : 0;
    return count;
  }

  Future<List<HistorialModel>?> showSales() async {
    final db = await database;  
    //GROUP_CONCAT, STRING_AGG
    final res = await db.rawQuery(
      'SELECT id, date, GROUP_CONCAT(name, ", ") name, SUM(price*amount) total, amount '
      'FROM sale INNER JOIN menu ON cveMenu = idMenu GROUP BY id');
    List<HistorialModel> list = [];
    for (var el in res) {
      list.add(HistorialModel.fromJson(el));
    } 
    return list.isNotEmpty ? list : null;
  }

  Future<List<Map<String, dynamic>>?> showSalesReport(String dateInitial, String dateFinal) async {
    final db = await database;
    //GROUP_CONCAT, STRING_AGG
    final res = await db.rawQuery(
      'SELECT id, date, idMenu, name, amount, (price*amount) price  FROM sale ' 
      'INNER JOIN menu ON cveMenu = idMenu '
      'WHERE DATE(date) >= "$dateInitial" AND DATE(date) <= "$dateFinal" '
      'ORDER BY id ASC'
    );
    /* List<ReportsModel> list = [];
    for (var el in res) {
      list.add(ReportsModel.fromJson(el));
    } */ 
    return res.isNotEmpty ? res : null;
  }

  Future<List<PieDataModel>?> showSalesPorcent(String dateInitial, String dateFinal) async {
    final db = await database;
    //GROUP_CONCAT, STRING_AGG
    final res = await db.rawQuery(
      'SELECT idMenu, SUM(amount) amount, name FROM sale '
      'INNER JOIN menu ON cveMenu = idMenu '
      'WHERE DATE(date) >= "$dateInitial" AND DATE(date) <= "$dateFinal" '
      'GROUP BY cveMenu ORDER BY cveMenu ASC'
    );
    List<PieDataModel> list = [];
    for (var el in res) {
      list.add(PieDataModel.fromJson(el));
    } 

    return res.isNotEmpty ? list : null;
  }

  Future<List<HistorialModel>?> showSalesDate(String datei, String datef) async {
    final db = await database;
    //GROUP_CONCAT, STRING_AGG
    final res = await db.rawQuery(
      'SELECT id, date, GROUP_CONCAT(name, ", ") name, SUM(price*amount) total, amount '
      'FROM sale INNER JOIN menu ON cveMenu = idMenu '
      'WHERE DATE(date) >= "$datei" AND DATE(date) <= "$datef" '
      'GROUP BY id'); 
    List<HistorialModel> list = [];
    for (var el in res) {
      list.add(HistorialModel.fromJson(el));
    } 
    return list.isNotEmpty ? list : null;
  }

  Future<int> deleteOneSale(int id) async {
    final db = await database;
    final results = await db.delete('sale', where: 'idSale = ?', whereArgs: [id]);
    return results;
  }

  Future<int> deleteFullSale(int id) async {
    final db = await database;
    final results = await db.delete('sale', where: 'id = ?', whereArgs: [id]);
    return results;
  }

  Future<int> updateSale(int amount, int idSale) async {
    final db = await database;
    final res = await db.rawUpdate(
      'UPDATE sale SET amount = ?  WHERE idSale = ?', [amount, idSale]);
    return res;
  }

 



}