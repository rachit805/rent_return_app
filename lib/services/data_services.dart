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
        sku_name TEXT,
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
        
        sku_name TEXT,
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

      await db.execute('''
  CREATE TABLE IF NOT EXISTS "customer_data" (
    "customer_id" INTEGER NOT NULL UNIQUE PRIMARY KEY,
    "customer_name" TEXT,
    "mob_number" TEXT,
    "alternative_mob_number" TEXT,
    "id_type" TEXT,
    "id_number" TEXT,
    "address" TEXT,
    "ref_name" TEXT,
    "ref_number" TEXT,
    "delivery_date" DATE,
    "return_date" DATE
  
  )
''');
      await db.execute('''
  CREATE TABLE "cart_items_data" (
    "cart_id" INTEGER NOT NULL UNIQUE PRIMARY KEY,
    "order_id" INTERGER,
    "sku_id" INTEGER,
    "sku_name" TEXT,
    "quantity" INTEGER,
    "buy_price" REAL,
    "rent_price" REAL,
    "total_price" REAL,
    "image" TEXT,
    "delivery_date" TEXT,
    "return_date" TEXT,
    "customer_id" INTEGER,
    "status" TEXT,
    FOREIGN KEY(customer_id) REFERENCES customer_data(customer_id),
    
    FOREIGN KEY(order_id) REFERENCES order_summary(order_id),
    FOREIGN KEY(sku_id) REFERENCES sku(sku_id),
    FOREIGN KEY(sku_name) REFERENCES sku(sku_name)
  )
''');

      await db.execute('''
  CREATE TABLE "order_summary" (
    "id" INTEGER NOT NULL UNIQUE PRIMARY KEY,
    "order_id" INTERGER,
    "cart_id" INTEGER,
    "customer_id" INTEGER,
    "transcation_mode" TEXT,
    "transcation_id" TEXT,
    'transcation_date_time' TEXT,
    "total_bill_amount" REAL,
    "delivery_date" DATE,
    "return_date" DATE,
    "advance_amount" REAL,
    "pending_amount" REAL,
    "status" TEXT,
    
    FOREIGN KEY(customer_id) REFERENCES customer_data(customer_id),
    FOREIGN KEY(order_id) REFERENCES cart_items_data(order_id),
    FOREIGN KEY(cart_id) REFERENCES cart_items_data(cart_id)
  )
''');
    });
  }

// Update masterCrad quantity
  Future<void> updateMasterCardQty(
    int remainingQty,
    String category,
    String item,
    String size,
  ) async {
    print(
        "MASTERCARD IN UPDATATION IN DB>> $remainingQty AND $category$item$size ");
    final db = await database;
    db.update(
      'mastercarddetail',
      {'total_quantity': remainingQty},
      where: 'category_name = ? AND item_name = ? AND size_name = ?',
      whereArgs: [category, item, size],
    );
  }

// Update SKU quantity
  Future<void> updateSkuQty(int remainingQty, String skuName) async {
    print("IN UPDATATION IN DB>> ${remainingQty} AND ${skuName} ");
    final db = await database;
    db.update(
      'sku',
      {'quantity': remainingQty},
      where: 'sku_name = ?',
      whereArgs: [skuName],
    );
  }

  // Fetch order summary
  Future<List<Map<String, dynamic>>> getOrderSummary() async {
    final db = await database;
    return await db.query('order_summary');
  }

  ///// GET CART DATA DYNAMIC WAY :::
  Future<List<Map<String, Object?>>> getCartData(
      String columnName, List<Object?> whereArgs) async {
    final db = await database;

    try {
      print("Querying $columnName with whereArgs: $whereArgs");
      final data = await db.query(
        'cart_items_data',
        where: '$columnName = ?',
        whereArgs: whereArgs,
      );
      print("Fetched Cart Data: $columnName = $whereArgs: $data");
      return data;
    } catch (e) {
      print('Error fetching cart data by $columnName: $e');
      throw Exception('Database query failed');
    }
  }

  Future<List<Map<String, Object?>>> getCartDataByOrderId(
      String orderID) async {
    final db = await database;

    try {
      final data = await db.query(
        'cart_items_data',
        where: 'order_id = ?',
        whereArgs: [orderID],
      );
      print("Fetched Cart Data for OrderID $orderID: $data");
      return data;
    } catch (e) {
      print('Error fetching cart data by orderId: $e');
      throw e;
    }
  }

  Future<List<Map<String, dynamic>>?> insertOrderSummary(
      Map<String, dynamic> orderSummary) async {
    final db = await database;

    try {
      // Insert the order summary and get the inserted row ID
      int insertedId = await db.insert(
        'order_summary',
        orderSummary,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      final result = await db.query(
        'order_summary',
        where: 'order_id = ?',
        whereArgs: [orderSummary["order_id"]],
      );

      if (result.isNotEmpty) {
        print('Inserted Order Summary DB: $result');
        return result;
      } else {
        print('Failed to retrieve the Order Summary.');
        throw Exception('Order Summary retrieval failed.');
      }
    } catch (e) {
      print(
          'Error inserting Order Summary or retrieving the inserted data: $e');
      throw e; // Re-throw the error to stop navigation in case of failure
    }
  }

  Future<List<Map<String, dynamic>>?> insertCartItem(
      Map<String, dynamic> cartItem, String orderID) async {
    final db = await database;
    try {
      int insertedId = await db.insert(
        'cart_items_data',
        cartItem,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      final result = await db.query(
        'cart_items_data',
        where: 'order_id = ?',
        whereArgs: [orderID],
      );
      if (result.isNotEmpty) {
        print("INSERTED CART ITEM DATA IN DB::: $result");
        print("INSERTED CART ITEM DATA IN DB::: ${result.length}");

        return result;
      } else {
        print('Failed to retrieve the inserted cart items.');
        return null;
      }
    } catch (e) {
      print('Error inserting cart item or retrieving the data: $e');
      return null;
    }
  }

  Future<List<Map<String, Object?>>> getOrderedItemsDataById(
      String orderId) async {
    final db = await database;

    return db
        .query("cart_items_data", where: 'order_id = ?', whereArgs: [orderId]);
  }

  Future<void> updateOrderedItemStatus(orderId) async {
    try {
      final db = await database;

      await db.update(
        "cart_items_data",
        {"status": "Return"},
        where: "order_id = ?",
        whereArgs: [orderId],
      );

      // print("Item with ID ${item['id']} status updated to 'Return'.");
    } catch (e) {
      print("Error updating item status: $e");
    }
  }
Future<void> updateOrderedSummmaryStatus(orderId) async {
    try {
      final db = await database;

      await db.update(
        "order_summary",
        {"status": "Return"},
        where: "order_id = ?",
        whereArgs: [orderId],
      );

      // print("Item with ID ${item['id']} status updated to 'Return'.");
    } catch (e) {
      print("Error updating item status: $e");
    }
  }

  Future<Map<String, dynamic>> insertCustomerAndReturnDetails(
      Map<String, dynamic> customerData) async {
    final db = await database;

    // Check if a customer with the same mob_number already exists
    final existingCustomer = await db.query(
      'customer_data',
      where: 'mob_number = ?',
      whereArgs: [customerData['mob_number']],
      limit: 1,
    );

    if (existingCustomer.isNotEmpty) {
      // Customer exists, update the record
      await db.update(
        'customer_data',
        customerData,
        where: 'mob_number = ?',
        whereArgs: [customerData['mob_number']],
      );

      // Return the updated customer data
      return existingCustomer.first;
    } else {
      // Insert a new customer record
      int customerId = await db.insert(
        'customer_data',
        customerData,
        conflictAlgorithm: ConflictAlgorithm.fail, // Prevent overwriting
      );

      // Retrieve and return the newly inserted record
      final result = await db.query(
        'customer_data',
        where: 'customer_id = ?',
        whereArgs: [customerId],
        limit: 1,
      );

      if (result.isNotEmpty) {
        return result.first;
      } else {
        throw Exception('Failed to retrieve customer data.');
      }
    }
  }

  Future<Map<String, dynamic>?> getCustomerDataById(String customerId) async {
    final db = await database; // Assume your DB instance is defined
    final result = await db.query('customer_data',
        where: 'customer_id = ?', whereArgs: [customerId]);
    return result.first;
  }

  Future<List<Map<String, Object?>>> getAllCustomersData() async {
    final db = await database;
    return db.query("customer_data");
  }

  Future<void> insertCustomerData(Map<String, dynamic> customerData) async {
    final db = await database;
    await db.insert('customer_data', customerData,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertCartData(Map<String, dynamic> cartData) async {
    final db = await database;
    await db.insert(
      'order_cart',
      cartData,
    );
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
// void updateSKUData()async{
// final db = await database;
// await db.update("sku", values)

// }
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

// Update SKU version
  Future<void> updateSKUData(
      String skuId, int quantity, double buyPrice, double rentPrice) async {
    final db = await database;
    db.query("mastercarddetail");
    await db.update(
      'sku',
      {
        'quantity': quantity,
        'purchase_price': buyPrice,
        'rent_price': rentPrice
      },
      where: 'sku_uid = ?',
      whereArgs: [skuId],
    );
    print("$skuId AND $quantity AND $buyPrice AND $rentPrice");
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

  Future<List<Map<String, dynamic>>> getItemByNameAndCategory(
      String itemName, int categoryUid) async {
    final db = await database;
    return await db.query(
      'item',
      where: 'item_name = ? AND category_uid = ?',
      whereArgs: [itemName, categoryUid],
    );
  }

  Future<List<Map<String, dynamic>>> getSIzeByItem(
      String sizeName, int itemID) async {
    final db = await database;
    return await db.query(
      'size',
      where: 'size_name = ? AND item_id = ?',
      whereArgs: [sizeName, itemID],
    );
  }

  // Fetch all items under a category_name
  Future<List<Map<String, dynamic>>> getCategoryByName(
      String categoryName) async {
    final db = await database;
    return await db.query(
      'category',
      where: 'category_name = ?',
      whereArgs: [categoryName],
    );
  }

  // Fetch SKU by SKU Name:
  Future<List<Map<String, dynamic>>> getSKUByName(String skuName) async {
    final db = await database;
    return await db.query(
      'sku',
      where: 'sku_name = ?',
      whereArgs: [skuName],
    );
  }

  Future<List<Map<String, dynamic>>> getItemsByCategoryId(
      int categoryUid) async {
    final db = await database;
    return await db.query(
      'item',
      where: 'category_uid = ?',
      whereArgs: [categoryUid],
    );
  }

  Future<List<Map<String, dynamic>>> getItemByName(String itemName) async {
    final db = await database;
    return await db.query(
      'item',
      where: 'item_name = ?',
      whereArgs: [itemName],
    );
  }

  Future<List<Map<String, dynamic>>> getSizesByItemId(int itemId) async {
    final db = await database;
    return await db.query(
      'size',
      where: 'item_id = ?',
      whereArgs: [itemId],
    );
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
