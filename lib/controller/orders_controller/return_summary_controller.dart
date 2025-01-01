import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rent_and_return/services/data_services.dart';
import 'package:rent_and_return/ui/bottom_nav_bar/homepage.dart';

class ReturnSummaryController extends GetxController {
  @override
  void onInit() {
    print("Order Summary In ReturnC>>> $orderSummaryData");
    print("Missing Item In ReturnC>>> $missingItemData");
    super.onInit();
  }

  final RxString orderId = ''.obs; // Order ID to match
  RxBool showQRcode = false.obs;
  final RxList<Map<String, dynamic>> orderSummaryData =
      <Map<String, dynamic>>[].obs; // List of filtered order summary data
  final RxList<Map<String, dynamic>> missingItemData =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> orderedItemData =
      <Map<String, dynamic>>[].obs;

  final TextEditingController cashAmountController = TextEditingController();
  final RxString ordersummaryID = "".obs;
  // Methods to set values
  void setOrderedSummaryData(List<Map<String, dynamic>> items) {
    orderSummaryData.assignAll(items);
  }

  void setMissingitemData(List<Map<String, dynamic>> items) {
    missingItemData.assignAll(items);
  }

  void setOrdereditemData(List<Map<String, dynamic>> items) {
    orderedItemData.assignAll(items);
  }

  void setOrderID(String id) {
    orderId.value = id;
  }

  final DatabaseHelper dbHelper = DatabaseHelper();

  Future<void> fetchOrderSummary() async {
    try {
      final List<Map<String, dynamic>> data = await dbHelper.getOrderSummary();
      if (data.isNotEmpty) {
        print("ORDER ID IN RC: ${orderId.value}");

        // Filter the data based on order_id
        final filteredData = data.where((order) {
          return order['order_id'] == orderId.value;
        }).toList();

        if (filteredData.isNotEmpty) {
          orderSummaryData.assignAll(filteredData);
          ordersummaryID.value = filteredData[0]["id"].toString();

          print("Summary In Return Controller: $orderSummaryData");
        } else {
          print(
              "No matching order summary found for order_id: ${orderId.value}");
        }
      } else {
        print("No order summary data found.");
      }
    } catch (e) {
      print("Error fetching order summary: $e");
    }
  }

  Future<void> updateOrderStatus(id) async {
    try {
      final db = await dbHelper.database;
      await db.update(
        "order_summary",
        {"status": "Closed Order"},
        where: "id = ?",
        whereArgs: [id],
      );

      print("b  $id} status updated to 'Return'.");
    } catch (e) {
      print("Error updating item status: $e");
    }
  }

  void closeOrder() async {
    print("ORDER S ID>>> ${ordersummaryID.value}");
    await updateOrderStatus(ordersummaryID.value);
    Get.offAll(Homepage(initialPage: 1));
  }
}
