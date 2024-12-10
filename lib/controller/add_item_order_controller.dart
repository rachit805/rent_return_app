import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rent_and_return/services/data_services.dart';
import 'package:rent_and_return/ui/orders/preview_order_screen.dart';
import 'package:rent_and_return/widgets/error_snackbar.dart';

class AddItemOrderController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    calculateTotalAmount();
    print("CUSTOMER DATA ::: $customerData");
  }

  RxList<String> categories = <String>["Select Category"].obs;
  RxString selectedCategory = ''.obs;
  RxList<String> items = <String>["Select Item"].obs;
  RxString selectedItem = ''.obs;

  RxList<String> sizes = <String>["Select Size"].obs;
  RxString selectedSize = ''.obs;

  final TextEditingController categoryController = TextEditingController();
  final TextEditingController itemController = TextEditingController();
  final TextEditingController sizeController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController rentpriceController = TextEditingController();

  final TextEditingController returndateController = TextEditingController();
  final TextEditingController deliverydateController = TextEditingController();

  // Local data storage
  RxList<Map<String, dynamic>> itemsData = <Map<String, dynamic>>[].obs;
  RxInt currentItemIndex = 0.obs;
  DatabaseHelper dbHelper = DatabaseHelper();
  var customerData = <String, dynamic>{}.obs;
  final RxList<Map<String, dynamic>> cartItems = <Map<String, dynamic>>[].obs;

  // Set initial cart items
  void setCartItems(List<Map<String, dynamic>> items) {
    cartItems.assignAll(items);
  }

  void setCustomerData(data) {
    customerData.value = data;
  }

  // Refresh cart items (can fetch from API if needed)
  Future<void> refreshCartItems() async {
    // Simulate fetching updated data
    await Future.delayed(const Duration(seconds: 1));
    // Update with a refreshed list (example update logic)
    cartItems.refresh(); // Notify listeners explicitly
  }

  void removeItem(int index) {
    if (index >= 0 && index < cartItems.length) {
      cartItems.removeAt(index);
      itemsData.removeAt(index);
      currentItemIndex.value = itemsData.length; // Update the current index

      calculateTotalAmount(); // Recalculate total amount
      print("REMOVED INDEX :: $index");
    }
  }

  // void removeItem(int index) {
  //   if (index >= 0 && index < cartItems.length) {
  //     // Remove the item from the local list
  //     itemsData.removeAt(index);
  //     currentItemIndex.value = itemsData.length; // Update the current index
  //     calculateTotalAmount(); // Recalculate total amount

  //     // Persist the updated items list to the database
  //     // dbHelper.saveItems(itemsData); // Example function to save items
  //     print(" ITem IS REmovesd ::: $index");
  //     Get.snackbar("Success", "Item removed successfully!");
  //   }
  // }

  var totalAmount = 0.0.obs;
  void calculateTotalAmount() {
    final double total = itemsData.fold(0.0, (sum, item) {
      return sum + (item['totalItemRent'] ?? 0.0);
    });
    totalAmount.value = total; // Update observable value
    print("Updated Total Amount: $total");
  }

  Future<void> fetchCategories() async {
    try {
      final List<Map<String, dynamic>> categoryData =
          await dbHelper.getCategories();
      categories.value =
          categoryData.map((e) => e['category_name'].toString()).toList();
      categories.insert(0, "Select Category"); // Add default option
    } catch (e) {
      Get.snackbar("Error", "Failed to load categories: $e");
    }
  }

  Future<void> fetchItems(String categoryName) async {
    // if (categoryName == "Select Category" || categoryName.isEmpty) {
    //   items.value = ["Select Item"];
    //   selectedItem.value = "Select Item";
    //   sizes.value = ["Select Size"];
    //   return;
    // }

    try {
      final List<Map<String, dynamic>> categoryData =
          await dbHelper.getCategoryByName(categoryName);

      if (categoryData.isNotEmpty) {
        final int categoryUid = categoryData.first['category_uid'];
        final List<Map<String, dynamic>> itemData =
            await dbHelper.getItemsByCategoryId(categoryUid);

        items.value = itemData.map((e) => e['item_name'].toString()).toList();
        items.insert(0, "Select Item"); // Add default option
        selectedItem.value = "Select Item"; // Reset selected item
        sizes.value = ["Select Size"]; // Reset sizes
      } else {
        items.value = ["Select Item"];
        sizes.value = ["Select Size"];
        Get.snackbar("Error", "Category not found");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load items: $e");
    }
  }

  Future<void> fetchSizes(String itemName) async {
    // if (itemName == "Select Item" || itemName.isEmpty) {
    //   sizes.value = ["Select Size"];
    //   selectedSize.value = "Select Size";
    //   return;
    // }

    try {
      final List<Map<String, dynamic>> itemData =
          await dbHelper.getItemByName(itemName);

      if (itemData.isNotEmpty) {
        final int itemId = itemData.first['item_id'];
        final List<Map<String, dynamic>> sizeData =
            await dbHelper.getSizesByItemId(itemId);

        sizes.value = sizeData.map((e) => e['size_name'].toString()).toList();
        sizes.insert(0, "Select Size"); // Add default option
        selectedSize.value = "Select Size"; // Reset selected size
        fetchSKUData(); // Automatically fetch SKU data if necessary
      } else {
        sizes.value = ["Select Size"];
        Get.snackbar("Error", "Item not found");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load sizes: $e");
    }
  }

  Future<void> fetchSKUData() async {
    if (selectedCategory.value.isEmpty ||
        selectedCategory.value == "Select Category" ||
        selectedItem.value.isEmpty ||
        selectedItem.value == "Select Item" ||
        selectedSize.value.isEmpty ||
        selectedSize.value == "Select Size") {
      priceController.clear();
      rentpriceController.clear();
      return; // Do not show an error, just exit
    }

    final String skuName =
        "${selectedCategory.value}_${selectedItem.value}_${selectedSize.value}";

    try {
      final List<Map<String, dynamic>> skuData =
          await dbHelper.getSKUByName(skuName);

      if (skuData.isNotEmpty) {
        final double buyPrice = skuData.first['purchase_price'];
        final double rentPrice = skuData.first['rent_price'];
        priceController.text = buyPrice.toStringAsFixed(1);

        rentpriceController.text = rentPrice.toStringAsFixed(1);
      } else {
        priceController.clear();
        rentpriceController.clear();
        Get.snackbar("Error", "SKU not found");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load SKU data: $e");
    }
  }

  // Method to reset controllers (Optional utility function)
  void resetForm() {
    selectedCategory.value = "Select Category";
    selectedItem.value = "Select Item";
    selectedSize.value = "Select Size";
    items.value = ["Select Item"];
    sizes.value = ["Select Size"];
    priceController.clear();
    rentpriceController.clear();
    quantityController.clear();
    returndateController.clear();
    deliverydateController.clear();
  }

  void saveCurrentItem() {
    if (!_validateFields()) {
      showErrorSnackbar("Error", "Fill all the Item Details");
      return;
    }

    double rentPrice = double.tryParse(rentpriceController.text) ?? 0.0;
    int quantity = int.tryParse(quantityController.text) ?? 0;
    double totalItemRent = rentPrice * quantity;

    final currentItem = {
      'category': selectedCategory.value,
      'item': selectedItem.value,
      'size': selectedSize.value,
      'price': priceController.text,
      'rentPrice': rentPrice,
      'quantity': quantity,
      'deliveryDate': deliverydateController.text,
      'totalItemRent': totalItemRent,
    };

    if (currentItemIndex.value < itemsData.length) {
      itemsData[currentItemIndex.value] = currentItem;
    } else {
      itemsData.add(currentItem);
    }

    currentItemIndex.value++;
    calculateTotalAmount();
  }

  void nextItem() {
    if (_validateFields()) {
      saveCurrentItem();
      loadCurrentItem(); // Load the next item
    } else {
      showErrorSnackbar("Error", "Fill all the Item Details");
    }
  }

// Validate required fields
  bool _validateFields() {
    return selectedCategory.value.isNotEmpty &&
        selectedCategory.value != "Select Category" &&
        selectedItem.value.isNotEmpty &&
        selectedItem.value != "Select Item" &&
        selectedSize.value.isNotEmpty &&
        selectedSize.value != "Select Size" &&
        quantityController.text.isNotEmpty &&
        deliverydateController.text.isNotEmpty;
  }

  void previousItem() {
    if (currentItemIndex.value > 0) {
      currentItemIndex.value--; // Decrement the index
      loadCurrentItem();
    }
  }

  // Load data for the current item
  void loadCurrentItem() {
    if (currentItemIndex.value < itemsData.length) {
      final currentItem = itemsData[currentItemIndex.value];
      selectedCategory.value = currentItem['category'] ?? '';
      selectedItem.value = currentItem['item'] ?? '';
      selectedSize.value = currentItem['size'] ?? '';
      priceController.text = currentItem['price']?.toString() ?? '';
      quantityController.text = (currentItem['quantity'] ?? 0).toString();
      rentpriceController.text = currentItem['rentPrice']?.toString() ?? '';
      deliverydateController.text = currentItem['deliveryDate'] ?? '';
    } else {
      // Reset fields if no data exists for the current index
      selectedCategory.value = '';
      selectedItem.value = '';
      selectedSize.value = '';
      priceController.clear();
      quantityController.clear();
      rentpriceController.clear();
      deliverydateController.clear();
    }
  }

// // Method to calculate the total amount
//   void calculateTotalAmount() {
//     final double total = itemsData.fold(0.0, (sum, item) {
//       return sum + (item['quantity'] * item['price']);
//     });
//     totalAmount.value = total;
//   }

  Future<void> previweOrder() async {
    if (_validateFields()) {
      saveCurrentItem();
      loadCurrentItem();
      calculateTotalAmount(); // Ensure total amount is updated
      final orderData = {
        'customerName': customerData['customer_name'] ?? '',
        'customerMobile': customerData['mob_number'] ?? '',
        'items': itemsData,
        "total_amount": totalAmount.value, // Use totalAmount
        "cart_id": "cartID",
      };
      print("Order placed: $orderData");
      Get.to(() => PreviewOrderScreen(), arguments: {
        "cart_items": itemsData,
        "total_amount": totalAmount.value, // Pass updated totalAmount
      });
      // Get.snackbar("Success", "Order preview is ready!");
    } else {
      showErrorSnackbar("Error", "Fill all the Item Details");
    }
  }
  
}
