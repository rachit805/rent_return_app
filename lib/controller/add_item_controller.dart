import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rent_and_return/services/data_services.dart';
import 'package:rent_and_return/ui/bottom_nav_bar/homepage.dart';
import 'package:rent_and_return/widgets/error_snackbar.dart';

import 'package:image/image.dart' as img;

class AddItemController extends GetxController {
  @override
  void onInit() {
    loadInterstitialAd();
    super.onInit();
  }

  final DatabaseHelper dbHelper = DatabaseHelper();

  // Dropdown Data
  RxList<String> categories = <String>[].obs;
  RxString selectedCategory = ''.obs;

  RxList<String> items = <String>[].obs;
  RxString selectedItem = ''.obs;

  RxList<String> sizes = <String>[].obs;
  RxString selectedSize = ''.obs;

  TextEditingController quantityController = TextEditingController();
  TextEditingController purchasePriceController = TextEditingController();
  TextEditingController rentPriceController = TextEditingController();

  InterstitialAd? interstitialAd;
  RxBool isLoaded = false.obs;

  ///
  ///

  var pickedImage = Rx<File?>(null);
  var isLoading = false.obs;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage(ImageSource source) async {
    isLoading.value = true; // Start loading
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate delay
      pickedImage.value = File(image.path);
    }
    isLoading.value = false; // Stop loading
  }

  ////// COMPRESED IMAGE
  Future<Uint8List> compressAndResizeImage(File file) async {
    // Read the image file as bytes
    Uint8List imageBytes = await file.readAsBytes();

    // Decode the image
    img.Image? originalImage = img.decodeImage(imageBytes);

    if (originalImage != null) {
      // Resize the image to a smaller dimension (e.g., max width: 300px)
      img.Image resizedImage = img.copyResize(originalImage, width: 300);

      // Encode the resized image to JPEG with compression
      return Uint8List.fromList(
          img.encodeJpg(resizedImage, quality: 75)); // 75% quality
    }

    throw Exception("Failed to process image");
  }

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: "ca-app-pub-2514113084570130/7674595051",
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          isLoaded.value = true;
          interstitialAd = ad;

          interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              Get.offAll(() => Homepage());
              ad.dispose();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              Get.offAll(() => Homepage());
              ad.dispose();
            },
          );
        },
        onAdFailedToLoad: (error) {
          print("Failed to load interstitial ad: ${error.message}");
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (isLoaded.value && interstitialAd != null) {
      interstitialAd!.show();
    } else {
      print("Ad not ready, navigating directly.");
      Get.to(() => Homepage());
    }
  }

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

  Future<void> addCategory(String categoryName) async {
    try {
      // Check if the category already exists
      final existingCategory = await dbHelper.getCategoryByName(categoryName);

      if (existingCategory.isNotEmpty) {
        Get.snackbar("Error", "Category already exists.");
      } else {
        final category = {'category_name': categoryName, 'category_desc': ''};
        await dbHelper.insertCategory(category);
        await loadCategories();
        Get.snackbar("Success", "Category added.");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to add category: $e");
    }
  }

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

    // Check if the item already exists under the selected category
    final existingItem =
        await dbHelper.getItemByNameAndCategory(itemName, categoryUid);
    if (existingItem.isNotEmpty) {
      Get.snackbar("Error", "Item already exists in this category.");
      return;
    }

    // Prepare the new item data
    final item = {
      'category_uid': categoryUid,
      'item_name': itemName,
      'item_desc': '',
      'status': 'active',
    };

    // Insert item and get item ID
    final itemId = await dbHelper.insertItemAndGetId(item);
    if (itemId != null) {
      await loadItems(
          categoryUid); // Refresh the item list for the selected category
      showSuccessSnackbar(
          "Success", "Item added successfully with ID: $itemId.");
    } else {
      showErrorSnackbar("Error", "Failed to add item.");
    }
  }

  // Add a new size under the selected item
  Future<void> addSize(String sizeName) async {
    if (selectedItem.isEmpty) {
      showErrorSnackbar("Error", "Please select an item first.");
      return;
    }

    // Get the selected item's ID
    final itemId = await _getItemIdByName(selectedItem.value);
    if (itemId == null) {
      showErrorSnackbar("Error", "Invalid item selection.");
      return;
    }
    // Check if the size already exists under the selected category
    final existingSize = await dbHelper.getSIzeByItem(sizeName, itemId);
    if (existingSize.isNotEmpty) {
      showErrorSnackbar("Error", "Size already exists in this category.");
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
    showSuccessSnackbar("Success", "Size added.");
  }

// Add SKU to inventory or update stock in slavecarddetail
  Future<void> addItemToInventory() async {
    if (selectedCategory.isEmpty ||
        selectedItem.isEmpty ||
        selectedSize.isEmpty ||
        quantityController.text.isEmpty ||
        purchasePriceController.text.isEmpty ||
        rentPriceController.text.isEmpty ||
        pickedImage.value == null) {
      showErrorSnackbar("Error", "Please fill all fields.");
      return;
    }

    // Fetch identifiers
    final categoryUid = await _getCategoryUidByName(selectedCategory.value);
    final itemId = await _getItemIdByName(selectedItem.value);
    final sizeId = await _getSizeIdByName(selectedSize.value, itemId!);

    if (categoryUid == null || itemId == null || sizeId == null) {
      showErrorSnackbar("Error", "Invalid selections.");
      return;
    }

    final quantity = int.parse(quantityController.text);
    final purchasePrice = double.parse(purchasePriceController.text);
    final rentPrice = double.parse(rentPriceController.text);

    // Check if SKU already exists
    final existingSku = await dbHelper.getSku(categoryUid, itemId, sizeId);

    if (existingSku == null) {
      // Add new SKU to the SKU table
      Uint8List? imageBytes = await compressAndResizeImage(pickedImage.value!);

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
        "image": imageBytes,
        'added_date': DateTime.now().toIso8601String(),
        'expire_date': null,
      };

      await dbHelper.insertSku(newSku);
      final String skuId = '${categoryUid}_${itemId}_$sizeId';
      final String skuName =
          '${selectedCategory.value}_${selectedItem.value}_${selectedSize.value}';
      final slaveData = {
        'sku_id': skuId,
        'sku_name': skuName,
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

      showSuccessSnackbar("Success", "New SKU added successfully.");
    } else {
      // Update existing SKU's version and add data to slavecarddetail
      final newVersion = existingSku['version'] + 1;
      await dbHelper.updateSkuVersion(categoryUid, itemId, sizeId, newVersion);
      final String skuName =
          '${selectedCategory.value}_${selectedItem.value}_${selectedSize.value}';

      final String skuId = '${categoryUid}_${itemId}_$sizeId';
      final slaveData = {
        'sku_id': skuId,
        'sku_name': skuName,
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
      // showSuccessSnackbar(
      //     "Success", "SKU updated, and data added to slavecarddetail.");
    }

    // Reset input fields
    selectedCategory.value = '';
    selectedItem.value = '';
    selectedSize.value = '';
    quantityController.clear();
    purchasePriceController.clear();
    rentPriceController.clear();
    pickedImage.value = null;
    showInterstitialAd();
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
      showErrorSnackbar("Error", "Invalid category selection.");
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
