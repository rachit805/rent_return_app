import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rent_and_return/controller/orders_controller/return_summary_controller.dart';
import 'package:rent_and_return/services/data_services.dart';
import 'package:rent_and_return/ui/orders/view_return_summary_screen.dart';

class OrderedItemController extends GetxController {
  @override
  void onInit() {
    orderedItems.refresh();
    returnedOrdersData.refresh();

    super.onInit();
  }

  final RxString orderId = ''.obs;
  final DatabaseHelper dbHelper = DatabaseHelper();

  final RxList<Map<String, dynamic>> orderedItems =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> missingOrdersData =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> returnedOrdersData =
      <Map<String, dynamic>>[].obs;

  final TextEditingController totalQtyController = TextEditingController();
  final TextEditingController missingQtyController = TextEditingController();
  final TextEditingController rentPriceController = TextEditingController();
  final TextEditingController missingPriceController = TextEditingController();
  final TextEditingController skuNameController = TextEditingController();

  final RxBool lastItem = false.obs;
  final RxInt currentIndex = 0.obs;
  void setOrderId(String id) {
    orderId.value = id;
    print("Order ID in onInit>> $orderId");
  }

  // Fetch ordered items based on the current orderId
  Future<void> getOrderedItems() async {
    try {
      if (orderId.isEmpty) {
        print("Order ID is empty. Cannot fetch ordered items.");
        return;
      }

      final data = await dbHelper.getOrderedItemsDataById(orderId.value);

      if (data != null && data.isNotEmpty) {
        orderedItems.assignAll(data);
        print("Fetched Ordered Items: $orderedItems");

        // Populate TextEditingControllers with the first item's data
        populateControllersWithCurrentItem();
      } else {
        print("No ordered items found for Order ID: ${orderId.value}");
      }
    } catch (e) {
      print("Error fetching ordered items: $e");
    }
  }

  void populateControllersWithCurrentItem() {
    if (orderedItems.isEmpty || currentIndex.value >= orderedItems.length)
      return;

    final item = orderedItems[currentIndex.value];

    skuNameController.text = item['sku_name'] ?? '';
    totalQtyController.text = item['quantity']?.toString() ?? '';
    rentPriceController.text = item['rent_price']?.toString() ?? '';
    missingPriceController.text = item['buy_price']?.toString() ?? '';
  }

  Future<void> updateOrderedItemStatus(Map<String, dynamic> item) async {
    try {
      final db = await dbHelper.database;

      // Update the status field in the database
      await db.update(
        "cart_items_data",
        {"status": "Return"},
        where: "cart_id = ?",
        whereArgs: [item['cart_id']],
      );

      print("Item with ID ${item['cart_id']} status updated to 'Return'.");
    } catch (e) {
      print("Error updating item status: $e");
    }
  }

  Future<void> getAndUpdateReturnQty(int returnedQty, String skuName) async {
    try {
      final db = await dbHelper.database;

      // Fetch the current available quantity for the given SKU
      final List<Map<String, dynamic>> result = await db.query(
        "masterCardDetail",
        where: "sku_name = ?",
        whereArgs: [skuName],
      );

      print("RESULT OF $skuName IN MASTERCARD >> ${result}");
      // final List<Map<String, dynamic>> allMasterdata = await db.query(
      //   "masterCardDetail",
      // );
      // print('ALL MASTER DATA >> $allMasterdata');
      if (result.isNotEmpty) {
        int availableQty = result[0]['total_quantity'] ?? 0;
        int newAvailableQty = availableQty + returnedQty;

        // Update the total_quantity in the masterCardDetail table
        await db.update(
          "masterCardDetail",
          {"total_quantity": newAvailableQty},
          where: "sku_name = ?",
          whereArgs: [skuName],
        );

        print(
            "Updated SKU: $skuName, Available Quantity: $availableQty -> $newAvailableQty");
      } else {
        print("No matching SKU found in masterCardDetail for SKU: $skuName");
      }
    } catch (e) {
      print("Error updating quantity in masterCardDetail: $e");
    }
  }

  void moveToNextItem() async {
    try {
      // Check if the current item's missingQtyController is not empty
      if (missingQtyController.text.isNotEmpty) {
        int? missingQty =
            int.tryParse(missingQtyController.text); // Parse to int
        if (missingQty != null && missingQty > 0) {
          // Create a modifiable copy of the current item
          final currentItem =
              Map<String, dynamic>.from(orderedItems[currentIndex.value]);

          // Add the missing quantity to the copied item
          currentItem['missing_qty'] = missingQty;

          // Add the modified item to the missingOrdersData list
          missingOrdersData.add(currentItem);
          print("Added to missingOrdersData: $currentItem");

          // Clear the missingQtyController
          missingQtyController.text = '';
        }
      }

      // Update the current item's status to 'Return'
      await updateOrderedItemStatus(orderedItems[currentIndex.value]);

      // Add the current item to the returnedOrdersData list
      returnedOrdersData.add(orderedItems[currentIndex.value]);

      int returnedQty = int.tryParse(totalQtyController.text) ?? 0;
      String skuName = skuNameController.text;

      if (returnedQty > 0) {
        await getAndUpdateReturnQty(returnedQty, skuName);
      }

      // Move to the next item
      if (currentIndex.value < orderedItems.length - 1) {
        currentIndex.value++;
        populateControllersWithCurrentItem(); // Populate controllers with new data
      } else {
        // Final step when all items are processed
        print(
            "All items have been returned."); // Define the lazyPut for ReturnSummaryController
        Get.lazyPut<ReturnSummaryController>(() => ReturnSummaryController());

// Access the controller where needed
        final returnSummaryController = Get.find<ReturnSummaryController>();

// Set missing item data in the summary controller
        returnSummaryController.setMissingitemData(missingOrdersData);

        // Clear ordered items list
        orderedItems.clear();

        // Navigate to the return summary screen
        Get.off(() => ViewReturnSummaryScreen(
              orderId: orderId.value,
            ));
      }
    } catch (e) {
      print("Error in moveToNextItem: $e");
    }
  }

  void addMissingOrder(Map<String, dynamic> item) {
    missingOrdersData.add(item);
  }
}
