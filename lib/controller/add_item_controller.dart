import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rent_and_return/services/data_services.dart';
import 'package:rent_and_return/ui/inventory/home_screen.dart';
import 'package:rent_and_return/ui/bottom_nav_bar/homepage.dart';
import 'package:rent_and_return/widgets/error_snackbar.dart';

class AddItemController extends GetxController {
  final DatabaseHelper dbHelper = DatabaseHelper();

  // Dropdown Data
  RxList<String> categories = <String>[].obs;
  RxString selectedCategory = ''.obs;

  RxList<String> items = <String>[].obs;
  RxString selectedItem = ''.obs;

  RxList<String> sizes = <String>[].obs;
  RxString selectedSize = ''.obs;

  // Text Field Controllers
  TextEditingController categoryNameController = TextEditingController();
  TextEditingController itemNameController = TextEditingController();
  TextEditingController sizeNameController = TextEditingController();

  TextEditingController quantityController = TextEditingController();
  TextEditingController purchasePriceController = TextEditingController();
  TextEditingController rentPriceController = TextEditingController();

  void debugPrintDatabase() async {
    final dbHelper = DatabaseHelper(); // Create an instance of DatabaseHelper
    await dbHelper.printAllTablesData(); // Call the method
  }

  // Load data from the database
  Future<void> loadCategories() async {
    final categoryData = await dbHelper.getCategories();
    categories.value =
        categoryData.map((c) => c['category_name'].toString()).toList();
  }

  Future<void> loadItems(int categoryUid) async {
    final itemData = await dbHelper.getItems(categoryUid);
    items.value = itemData.map((i) => i['item_name'].toString()).toList();
  }

  Future<void> loadSizes(int itemId) async {
    final sizeData = await dbHelper.getSizes(itemId);
    sizes.value = sizeData.map((s) => s['size_name'].toString()).toList();
  }

  // Add a new category
  Future<void> addCategory(String categoryName) async {
    final category = {'category_name': categoryName, 'category_desc': ''};
    await dbHelper.insertCategory(category);
    await loadCategories();
    Get.snackbar("Success", "Category added.");
  }

  // Add a new item under the selected category
  Future<void> addItem(String itemName) async {
    if (selectedCategory.isEmpty) {
      Get.snackbar("Error", "Please select a category first.");
      return;
    }

    // Get the selected category's UID
    final categoryUid = await _getCategoryUidByName(selectedCategory.value);
    if (categoryUid == null) {
      Get.snackbar("Error", "Invalid category selection.");
      return;
    }

    final item = {
      'category_uid': categoryUid,
      'item_name': itemName,
      'item_desc': '',
      'status': 'active',
    };

    // Insert item and get item ID
    final itemId = await dbHelper.insertItemAndGetId(item);
    if (itemId != null) {
      await loadItems(categoryUid);
      Get.snackbar("Success", "Item added successfully with ID: $itemId.");
    } else {
      Get.snackbar("Error", "Failed to add item.");
    }
  }

  // Add a new size under the selected item
  Future<void> addSize(String sizeName) async {
    if (selectedItem.isEmpty) {
      Get.snackbar("Error", "Please select an item first.");
      return;
    }

    // Get the selected item's ID
    final itemId = await _getItemIdByName(selectedItem.value);
    if (itemId == null) {
      Get.snackbar("Error", "Invalid item selection.");
      return;
    }

    final size = {
      'item_id': itemId,
      'size_name': sizeName,
      'size_desc': '',
      'status': 'active',
    };
    await dbHelper.insertSize(size);
    await loadSizes(itemId);
    Get.snackbar("Success", "Size added.");
  }

// Add SKU to inventory or update stock in slavecarddetail
  Future<void> addItemToInventory() async {
    if (selectedCategory.isEmpty ||
        selectedItem.isEmpty ||
        selectedSize.isEmpty ||
        quantityController.text.isEmpty ||
        purchasePriceController.text.isEmpty ||
        rentPriceController.text.isEmpty) {
      showErrorSnackbar("Error", "Please fill all fields.");
      return;
    }

    // Fetch identifiers
    final categoryUid = await _getCategoryUidByName(selectedCategory.value);
    final itemId = await _getItemIdByName(selectedItem.value);
    final sizeId = await _getSizeIdByName(selectedSize.value, itemId!);

    if (categoryUid == null || itemId == null || sizeId == null) {
      Get.snackbar("Error", "Invalid selections.");
      return;
    }

    final quantity = int.parse(quantityController.text);
    final purchasePrice = double.parse(purchasePriceController.text);
    final rentPrice = double.parse(rentPriceController.text);

    // Check if SKU already exists
    final existingSku = await dbHelper.getSku(categoryUid, itemId, sizeId);

    if (existingSku == null) {
      // Add new SKU to the SKU table
      final newSku = {
        'sku_uid': "${categoryUid}_${itemId}_$sizeId",
        'sku_name':
            "${selectedCategory.value}_${selectedItem.value}_${selectedSize.value}",
        'category_id': categoryUid,
        'category_name': selectedCategory.value,
        'item_id': itemId,
        'item_name': selectedItem.value,
        'size_id': sizeId,
        'size_name': selectedSize.value,
        'quantity': quantity,
        'purchase_price': purchasePrice,
        'rent_price': rentPrice,
        'version': 1,
        'status': 'active',
        'added_date': DateTime.now().toIso8601String(),
        'expire_date': null,
      };

      await dbHelper.insertSku(newSku);
      final String skuId = '${categoryUid}_${itemId}_$sizeId';

      final slaveData = {
        'sku_id': skuId,
        'category_id': categoryUid,
        'item_id': itemId,
        'size_id': sizeId,
        'latest_buy_price': purchasePrice,
        'latest_rent_price': rentPrice,
        'latest_quantity': quantity,
        'status': 'active',
        'added_date': DateTime.now().toIso8601String().split('T')[0],
      };

      await dbHelper.insertSlaveCard(slaveData);

      Get.snackbar("Success", "New SKU added successfully.");
    } else {
      // Update existing SKU's version and add data to slavecarddetail
      final newVersion = existingSku['version'] + 1;
      await dbHelper.updateSkuVersion(categoryUid, itemId, sizeId, newVersion);
      final String skuId = '${categoryUid}_${itemId}_$sizeId';
      final slaveData = {
        'sku_id': skuId,
        'category_id': categoryUid,
        'item_id': itemId,
        'size_id': sizeId,
        'latest_buy_price': purchasePrice,
        'latest_rent_price': rentPrice,
        'latest_quantity': quantity,
        'status': 'active',
        'added_date': DateTime.now().toIso8601String().split('T')[0],
      };

      await dbHelper.insertSlaveCard(slaveData);
      Get.snackbar(
          "Success", "SKU updated, and data added to slavecarddetail.");
    }

    // Reset input fields
    selectedCategory.value = '';
    selectedItem.value = '';
    selectedSize.value = '';
    quantityController.clear();
    purchasePriceController.clear();
    rentPriceController.clear();

    Get.off(() => Homepage());
  }

  Future<int?> _getCategoryUidByName(String categoryName) async {
    final categories = await dbHelper.getCategories();
    final category = categories.firstWhere(
      (c) => c['category_name'] == categoryName,
      orElse: () => {},
    );
    return category.isNotEmpty ? category['category_uid'] : null;
  }

  Future<int?> _getItemIdByName(String itemName) async {
    // Get the selected category UID
    final categoryUid = await _getCategoryUidByName(selectedCategory.value);
    if (categoryUid == null) {
      Get.snackbar("Error", "Invalid category selection.");
      return null;
    }

    final items = await dbHelper.getItems(categoryUid);
    final item = items.firstWhere(
      (i) => i['item_name'] == itemName,
      orElse: () => {},
    );

    return item.isNotEmpty ? item['item_id'] : null;
  }

  Future<int?> _getSizeIdByName(String sizeName, int itemId) async {
    final sizes = await dbHelper.getSizes(itemId);
    final size = sizes.firstWhere(
      (s) => s['size_name'] == sizeName,
      orElse: () => {},
    );
    return size.isNotEmpty ? size['size_id'] : null;
  }

  var version = 1.obs;
  void addexistingStock() {}
}
