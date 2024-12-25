import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rent_and_return/services/data_services.dart';
import 'package:rent_and_return/widgets/error_snackbar.dart';

class ItemDetailController extends GetxController {
  final DatabaseHelper dbHelper = DatabaseHelper();

  RxList<Map<String, dynamic>> slaveCardList = <Map<String, dynamic>>[].obs;
  RxList<Map<dynamic, dynamic>> masterListData = <Map<dynamic, dynamic>>[].obs;
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController buypriceController = TextEditingController();
  final TextEditingController rentpriceController = TextEditingController();
  final RxString skuname = ''.obs;
  final RxInt placedQuantity = 0.obs;
  final RxInt addedQuantity = 0.obs;
  final RxDouble lastBuyprice = 0.0.obs;
  final RxDouble lastRentprice = 0.0.obs;
  final RxInt finalRemainingQuantity = 0.obs;
  RxList<Map<String, dynamic>> placedOrdersData = <Map<String, dynamic>>[].obs;

  Future<void> fetchItemsBySkuId(String skuId, String skuName) async {
    try {
      final slavecardData = await dbHelper.getSlaveCardDetail();
      final data = await dbHelper.getCartData("sku_name", [skuName]);

      final filteredData =
          data.where((item) => item['status'] == "Active").toList();
      placedOrdersData.assignAll(filteredData);

      if (placedOrdersData.isNotEmpty) {
        for (var item in placedOrdersData) {
          placedQuantity.value = item['quantity'] ?? 0;
        }
      }

      if (slavecardData.isNotEmpty) {
        slaveCardList.value =
            slavecardData.where((item) => item['sku_id'] == skuId).toList();
        slaveCardList
            .sort((a, b) => b['added_date'].compareTo(a['added_date']));

        for (var item in slaveCardList) {
          addedQuantity.value = item['latest_quantity'] ?? 0;
        }

        calculateFinalQuantity();
        calculateMasterData(skuName);
      } else {
        slaveCardList.clear();
        masterListData.clear();
      }
    } catch (e, stacktrace) {
      print("Error fetching items: $e");
      print("Stacktrace: $stacktrace");
    }
  }

  Future<void> addMasterCard(String skuId, String skuName) async {
    try {
      final updatedMasterCard = {
        "sku_id": skuId,
        "sku_name": skuName,
        "avg_buy_price": lastBuyprice.value,
        "avg_rent_price": lastRentprice.value,
        "total_quantity": finalRemainingQuantity.value,
      };

      await dbHelper.insertOrUpdateMasterCard(updatedMasterCard);

      await updateSKUData(
        skuId,
        finalRemainingQuantity.value,
        lastBuyprice.value,
        lastRentprice.value,
      );

      print("MasterCard Updated: $updatedMasterCard");
    } catch (e, stacktrace) {
      print("Error in addMasterCard: $e");
      print("Stacktrace: $stacktrace");
      showErrorSnackbar("Error", "Failed to add MasterCard: $e");
      rethrow; // Re-throw the exception for further debugging if needed
    }
  }

  Future<void> updateSKUData(
      String skuId, int quantity, double buyPrice, double rentPrice) async {
    try {
      await dbHelper.updateSKUData(skuId, quantity, buyPrice, rentPrice);
      print("SKU Data updated for SKU: $skuId");
    } catch (e, stacktrace) {
      print("Error updating SKU data: $e");
      print("Stacktrace: $stacktrace");
      showErrorSnackbar("Error", "Failed to update SKU data: $e");
    }
  }

  Future<void> calculateMasterData(String skuName) async {
    if (slaveCardList.isEmpty) {
      print("No data to calculate master data.");
      return;
    }

    // Use the most recent entry for prices
    final latestSlaveCard = slaveCardList.first;

    lastBuyprice.value = double.tryParse(
            latestSlaveCard['latest_buy_price']?.toString() ?? '0.0') ??
        0.0;
    lastRentprice.value = double.tryParse(
            latestSlaveCard['latest_rent_price']?.toString() ?? '0.0') ??
        0.0;

    masterListData.value = [
      {
        "sku_id": latestSlaveCard['sku_id'],
        "sku_name": skuName,
        "avg_buy_price": lastBuyprice.value,
        "avg_rent_price": lastRentprice.value,
        "total_quantity": finalRemainingQuantity.value,
      }
    ];

    // Update SKU after MasterCard
    await updateSKUData(
      latestSlaveCard['sku_id'],
      finalRemainingQuantity.value,
      lastBuyprice.value,
      lastRentprice.value,
    );

    print("Master Data Calculated: $masterListData");
  }

  Future<void> addmoreStock(String skuID, categoryId, itemId, sizeId) async {
    if (buypriceController.text.isEmpty ||
        rentpriceController.text.isEmpty ||
        quantityController.text.isEmpty) {
      showErrorSnackbar("Error", "Fill All Fields");
      return;
    }

    final slaveData = {
      "sku_id": skuID,
      'category_id': categoryId,
      'item_id': itemId,
      'size_id': sizeId,
      'latest_buy_price': buypriceController.text,
      'latest_rent_price': rentpriceController.text,
      'latest_quantity': quantityController.text,
      'status': 'active',
      'added_date': DateTime.now().toIso8601String(),
    };

    try {
      lastBuyprice.value = double.tryParse(buypriceController.text) ?? 0.0;
      lastRentprice.value = double.tryParse(rentpriceController.text) ?? 0.0;
      await addMasterCard(skuID, skuname.value);
      await dbHelper.insertSlaveCard(slaveData);

      buypriceController.clear();
      quantityController.clear();
      rentpriceController.clear();

      Get.back();
      Get.snackbar(
        'Success',
        'Stock added successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e, stacktrace) {
      print("Error adding stock: $e");
      print("Stacktrace: $stacktrace");

      Get.snackbar(
        'Error',
        'Failed to add stock: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 15),
      );
    }
  }

  void calculateFinalQuantity() {
    try {
      int totalAddedQuantity = slaveCardList.fold(
        0,
        (sum, item) =>
            sum +
            (int.tryParse(item['latest_quantity']?.toString() ?? '0') ?? 0),
      );
      int totalPlacedQuantity = placedOrdersData.fold(
        0,
        (sum, item) =>
            sum + (int.tryParse(item['quantity']?.toString() ?? '0') ?? 0),
      );

      finalRemainingQuantity.value = totalAddedQuantity - totalPlacedQuantity;

      print(
          "Calculated Final Remaining Quantity >>> ${finalRemainingQuantity.value}");
    } catch (e, stacktrace) {
      print("Error calculating final quantity: $e");
      print("Stacktrace: $stacktrace");
    }
  }
}
