import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  // Initialize the database
  Future<Database> initDatabase() async {
    final path = join(await getDatabasesPath(), 'inventory.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
      CREATE TABLE category (
        category_uid INTEGER PRIMARY KEY AUTOINCREMENT,
        category_name TEXT,
        category_desc TEXT
      )
    ''');

      await db.execute('''
      CREATE TABLE item (
        item_id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_uid INTEGER,
        item_name TEXT,
        item_desc TEXT,
        status TEXT,
        FOREIGN KEY(category_uid) REFERENCES category(category_uid)
      )
    ''');

      await db.execute('''
      CREATE TABLE size (
        size_id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_id INTEGER,
        size_name TEXT,
        size_desc TEXT,
        status TEXT,
        FOREIGN KEY(item_id) REFERENCES item(item_id)
      )
    ''');

      await db.execute('''
      CREATE TABLE IF NOT EXISTS sku (
        sku_uid TEXT PRIMARY KEY,
        sku_name TEXT,
        sku_desc TEXT,
        category_id INTEGER,
        category_name TEXT,
        item_name TEXT,
        item_id INTEGER,         
        size_id INTEGER,
        size_name TEXT,
        quantity INTEGER,
        purchase_price REAL,
        rent_price REAL,
        version INTEGER,
        added_date TEXT,
        status TEXT,
        expire_date TEXT,
        FOREIGN KEY(item_id) REFERENCES item(item_id),   -- Correct foreign key reference
        FOREIGN KEY(size_id) REFERENCES size(size_id)      -- Correct foreign key reference
      );
    ''');

      await db.execute('''
      CREATE TABLE mastercarddetail(
        sku_id INTEGER,
        category_name TEXT,
        item_name TEXT,
        item_id INTEGER,         
        size_id INTEGER,
        size_name TEXT,
        avg_buy_price REAL,
        avg_rent_price REAL,
        total_quantity INTEGER,
        FOREIGN KEY(sku_id) REFERENCES sku(sku_id)
              )
    ''');
      await db.execute('''
      CREATE TABLE slavecarddetail (
        history_id PRIMARY KEY,
        sku_id INTEGER,
        category_id INTEGER,
        category_name TEXT,
        item_name TEXT,
        item_id INTEGER,         
        size_id INTEGER,
        size_name TEXT,
        latest_buy_price REAL,
        latest_rent_price REAL,
        latest_quantity INTEGER,
        added_date TEXT,
        status TEXT,
        
        FOREIGN KEY(size_id) REFERENCES size(size_id)
        FOREIGN KEY(category_id) REFERENCES category(category_id)
        FOREIGN KEY(item_id) REFERENCES item(item_id)
        FOREIGN KEY(sku_id) REFERENCES sku(sku_id)
      )
    ''');
    });
  }

  Future<Map<String, dynamic>?> getMasterCardBySkuId(String skuId) async {
    final db = await database; // Assume your DB instance is defined
    final result = await db.query('masterCardDetail',
        where: 'sku_id = ?', whereArgs: [skuId], limit: 1);
    return result.isNotEmpty ? result.first : null;
  }

  // Insert or Update masterCard data
  Future<void> insertOrUpdateMasterCard(Map<String, dynamic> masterCard) async {
    final db = await database; // Assume your DB instance is defined
    await db.insert('masterCardDetail', masterCard,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Insert a SKU into the database
  Future<void> insertSku(Map<String, dynamic> sku) async {
    final db = await database;
    await db.insert('sku', sku, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Insert a MasterCard into the database
  Future<void> insertMasterCard(Map<String, dynamic> masterCardData) async {
    final db = await database;
    await db.insert('mastercarddetail', masterCardData,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

// Fetch an SKU based on category, item, and size IDs
  Future<Map<String, dynamic>?> getSku(
      int categoryId, int itemId, int sizeId) async {
    final db = await database;
    final result = await db.query(
      'sku',
      where: 'category_id = ? AND item_id = ? AND size_id = ?',
      whereArgs: [categoryId, itemId, sizeId],
    );
    return result.isNotEmpty ? result.first : null;
  }

// Update SKU version
  Future<void> updateSkuVersion(
      int categoryId, int itemId, int sizeId, int newVersion) async {
    final db = await database;
    await db.update(
      'sku',
      {'version': newVersion},
      where: 'category_id = ? AND item_id = ? AND size_id = ?',
      whereArgs: [categoryId, itemId, sizeId],
    );
  }

// Insert new stock data into slavecarddetail
  Future<void> insertSlaveCard(Map<String, dynamic> slavecarddetail) async {
    final db = await database;
    await db.insert(
      'slavecarddetail',
      slavecarddetail,
    );
  }

  // Insert a category
  Future<void> insertCategory(Map<String, dynamic> category) async {
    final db = await database;
    await db.insert('category', category,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Insert an item under a category
  Future<void> insertItem(Map<String, dynamic> item) async {
    final db = await database;
    await db.insert('item', item, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Insert size for an item
  Future<void> insertSize(Map<String, dynamic> size) async {
    final db = await database;
    await db.insert('size', size, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Fetch all categories
  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await database;
    return await db.query('category');
  }

  // Fetch all items under a category
  Future<List<Map<String, dynamic>>> getItems(int categoryUid) async {
    final db = await database;
    return await db
        .query('item', where: 'category_uid = ?', whereArgs: [categoryUid]);
  }

  // Fetch all sizes for an item
  Future<List<Map<String, dynamic>>> getSizes(int itemId) async {
    final db = await database;
    return await db.query('size', where: 'item_id = ?', whereArgs: [itemId]);
  }

  Future<List<Map<String, dynamic>>> getSKUs() async {
    final db = await database;
    return await db.query('sku');
  }

  Future<List<Map<String, dynamic>>> getMasterCard() async {
    final db = await database;
    return await db.query('mastercarddetail');
  }

// Get existing stock from slavecarddetail

  Future<List<Map<String, dynamic>>> getSlaveCardDetail() async {
    final db = await database;
    return await db.query('slavecarddetail');
  }

// Update existing stock in slavecarddetail
  Future<void> updateSlaveCard(
      int categoryId, int itemId, int sizeId, Map<String, dynamic> data) async {
    final db = await database;
    await db.update(
      'slavecarddetail',
      data,
      where: 'category_id = ? AND item_id = ? AND size_id = ?',
      whereArgs: [categoryId, itemId, sizeId],
    );
  }

  // Insert item and get the ID
  Future<int?> insertItemAndGetId(Map<String, dynamic> item) async {
    final db = await database;
    return await db.insert('item', item,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> printAllTablesData() async {
    final db = await database; // Access the database instance

    List<Map<String, dynamic>> categories = await db.query('category');
    print('Available categories: ${categories.length}');

    // List of all table names
    final tableNames = ['category', 'item', 'size', 'sku', 'slavecarddetail'];

    for (String tableName in tableNames) {
      try {
        // Query all rows from the current table
        final List<Map<String, dynamic>> tableData = await db.query(tableName);

        print('--- Data from $tableName ---');
        for (var row in tableData) {
          print(row);
        }
        print('---------------------------\n');
      } catch (e) {
        print('Error querying table $tableName: $e');
      }
    }
  }
}
