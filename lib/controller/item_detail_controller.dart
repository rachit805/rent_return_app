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

  Future<void> fetchItemsBySkuId(String skuId) async {
    print("Fetching items for SKU: $skuId");
    try {
      final slavecardData = await dbHelper.getSlaveCardDetail();

      if (slavecardData.isNotEmpty) {
        slaveCardList.value =
            slavecardData.where((item) => item['sku_id'] == skuId).toList();
        slaveCardList
            .sort((a, b) => b['added_date'].compareTo(a['added_date']));

        print("Filtered slaveCardList length: ${slaveCardList.length}");

        calculateMasterData();
      } else {
        slaveCardList.clear();
        masterListData.clear();
        print("No matching data for SKU: $skuId");
      }
    } catch (e) {
      print("Error fetching items: $e");
    }
  }

  Future<void> addMasterCard(String skuId) async {
    final lastMasterCard = await dbHelper.getMasterCardBySkuId(skuId);

    double prevBuyPrice = lastMasterCard?['avg_buy_price'] ?? 0.0;
    double prevRentPrice = lastMasterCard?['avg_rent_price'] ?? 0.0;
    int prevQuantity = lastMasterCard?['total_quantity'] ?? 0;

    int newQuantity = int.tryParse(quantityController.text) ?? 0;
    double newBuyPrice = double.tryParse(buypriceController.text) ?? 0.0;
    double newRentPrice = double.tryParse(rentpriceController.text) ?? 0.0;

    if (newQuantity == 0) {
      print("Invalid new quantity, skipping update.");
      return;
    }

    double updatedBuyPrice =
        ((prevBuyPrice * prevQuantity) + (newBuyPrice * newQuantity)) /
            (prevQuantity + newQuantity);
    double updatedRentPrice =
        ((prevRentPrice * prevQuantity) + (newRentPrice * newQuantity)) /
            (prevQuantity + newQuantity);
    int updatedQuantity = prevQuantity + newQuantity;

    final updatedMasterCard = {
      "sku_id": skuId,
      "avg_buy_price": updatedBuyPrice,
      "avg_rent_price": updatedRentPrice,
      "total_quantity": updatedQuantity,
    };

    try {
      await dbHelper.insertOrUpdateMasterCard(updatedMasterCard);

      // Update SKU after MasterCard
      await updateSKUData(
        skuId,
        updatedQuantity,
        updatedBuyPrice,
        updatedRentPrice,
      );

      print("MasterCard Updated: $updatedMasterCard");
    } catch (e) {
      print("Error updating MasterCard: $e");
    }
  }

  Future<void> updateSKUData(
      String skuId, int quantity, double buyPrice, double rentPrice) async {
    try {
      await dbHelper.updateSKUData(skuId, quantity, buyPrice, rentPrice);
      print("SKU Data updated for SKU: $skuId");
      print(
          "Updated Values: Quantity=$quantity, BuyPrice=$buyPrice, RentPrice=$rentPrice");
    } catch (e) {
      print("Error updating SKU data: $e");
    }
  }

  Future<void> calculateMasterData() async {
    if (slaveCardList.isEmpty) {
      print("No data to calculate master data.");
      return;
    }

    double totalBuyPrice = 0.0;
    double totalRentPrice = 0.0;
    int totalQuantity = 0;
    double weightedBuyPriceSum = 0.0;
    double weightedRentPriceSum = 0.0;

    for (var item in slaveCardList) {
      int itemQuantity =
          int.tryParse(item['latest_quantity']?.toString() ?? '') ?? 0;
      double itemBuyPrice =
          double.tryParse(item['latest_buy_price']?.toString() ?? '') ?? 0;
      double itemRentPrice =
          double.tryParse(item['latest_rent_price']?.toString() ?? '') ?? 0;

      totalQuantity += itemQuantity;
      weightedBuyPriceSum += itemBuyPrice * itemQuantity;
      weightedRentPriceSum += itemRentPrice * itemQuantity;
    }

    double avgBuyPrice = (weightedBuyPriceSum / totalQuantity);
    double avgRentPrice = (weightedRentPriceSum / totalQuantity);
    int totalQuantityCeil = totalQuantity.ceil();

    masterListData.value = [
      {
        "sku_id": slaveCardList[0]['sku_id'],
        "avg_buy_price": avgBuyPrice,
        "avg_rent_price": avgRentPrice,
        "total_quantity": totalQuantityCeil,
      }
    ];
    // Update SKU after MasterCard
    await updateSKUData(
      slaveCardList[0]['sku_id'],
      totalQuantity,
      avgBuyPrice,
      avgRentPrice,
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
      await addMasterCard(skuID);

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
      await dbHelper.insertSlaveCard(slaveData);
    } catch (e) {
      print("Error adding stock: $e");

      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 15),
      );
    }
  }
}
