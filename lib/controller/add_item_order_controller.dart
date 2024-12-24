import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rent_and_return/services/data_services.dart';
import 'package:rent_and_return/ui/orders/add_address_screen.dart';
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
  RxInt availableQty = 0.obs;
  RxList<String> sizes = <String>["Select Size"].obs;
  RxString selectedSize = ''.obs;
  RxInt remainingQty = 0.obs;
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
  final RxString orderid = ''.obs;
  final RxInt customerId = 0.obs;
  final RxString cartId = ''.obs;
  final RxString returnDate = ''.obs;
  final RxString deliveryDate = ''.obs;
  final RxList<Map<String, dynamic>> cartItems = <Map<String, dynamic>>[].obs;
  final RxString skuname = ''.obs;
  final RxString scategory = ''.obs;
  final RxString sitem = ''.obs;
  final RxString ssize = ''.obs;
  Future<void> storeCartItemsInDBAndPlaceOrder() async {
    for (var cartItem in cartItems) {
      // final orderId =
      //     "${customerData['customer_id']}_${cartItems.length}_${DateTime.now().millisecondsSinceEpoch}";

      skuname.value =
          "${cartItem['category']}_${cartItem['item']}_${cartItem['size']}";
      scategory.value = cartItem['category'];
      sitem.value = cartItem['item'];
      ssize.value = cartItem['size'];
      final parentOrderId =
          "${customerData['customer_id']}_${DateTime.now().day}${DateTime.now().month}${DateTime.now().year}_${DateTime.now().hour}:${DateTime.now().minute}";

      final cartItemData = {
        'sku_name':
            "${cartItem['category']}_${cartItem['item']}_${cartItem['size']}",
        'quantity': cartItem['quantity'],
        'buy_price': cartItem['price'],
        'rent_price': cartItem['rentPrice'],
        'total_price': cartItem['totalItemRent'],
        'delivery_date': cartItem['deliveryDate'],
        'return_date': customerData['return_date'] ?? '',
        'customer_id': customerData['customer_id'] ?? 0,
        'order_id': parentOrderId,
        'image': cartItem['image'] ?? '',
        'status': "Active",
      };

      try {
        ///// Problem is here [I/flutter (26731): IN UPDATATION IN DB>> 50 AND __ ]
        ///HOW TO GET HERE SKU_NAME
        print("REMAING QTY ON ORDER PLCING >> $remainingQty");
        final insertedData =
            await dbHelper.insertCartItem(cartItemData, parentOrderId);
        // final String skuName =
        //     "${selectedCategory.value}_${selectedItem.value}_${selectedSize.value}";
        await dbHelper.updateSkuQty(remainingQty.value, skuname.value);
        await dbHelper.updateMasterCardQty(
            remainingQty.value, scategory.value, sitem.value, ssize.value);
        print("REMAINING QTY>> $remainingQty");

        if (insertedData != null) {
          itemsData.value = insertedData;
          customerId.value = insertedData.first['customer_id'] ?? '';
          orderid.value = insertedData.first['order_id'] ?? '';
          returnDate.value = insertedData.first['return_date'] ?? '';
          deliveryDate.value = insertedData.first['delivery_date'] ?? '';

          // print('Inserted cart item DATA>>>> $insertedData');
          Get.to(() => AddAddressScreen(totalAmount: totalAmount));
        } else {
          print('Failed to insert cart item.');
        }
      } catch (e) {
        print('Error inserting cart item: $e');
      }
    }
  }

  // Set initial cart items
  void setCartItems(List<Map<String, dynamic>> items) {
    cartItems.assignAll(items);
  }

  void setCustomerData(data) {
    customerData.value = data;
  }

  Future<void> refreshCartItems() async {
    await Future.delayed(const Duration(seconds: 1));
    cartItems.refresh();
  }

  void removeItem(int index) {
    if (index >= 0 && index < cartItems.length) {
      cartItems.removeAt(index);
      itemsData.removeAt(index);
      currentItemIndex.value = itemsData.length; // Update the current index

      calculateTotalAmount();
      print("REMOVED INDEX :: $index");
    }
  }

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
      return;
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
        final int qty = skuData.first['quantity'];
        availableQty.value = qty;
        // print("finalAvQty>> ${finalAvQty(qty)}");
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
      'status': "Active",
    };

    if (currentItemIndex.value < itemsData.length) {
      itemsData[currentItemIndex.value] = currentItem;
    } else {
      try {
        // print("Available Item DATA >> $itemsData");
        // print("Available CART ITEM >> $cartItems");
        itemsData.add(currentItem);
      } catch (e) {
        print("Error in ADDING IN ITEMDATA:: $e");
      }
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
      // 'status': "Active",
    } else {
      selectedCategory.value = '';
      selectedItem.value = '';
      selectedSize.value = '';
      priceController.clear();
      quantityController.clear();
      rentpriceController.clear();
      deliverydateController.clear();
    }
  }

  Future<void> previewOrder() async {
    // Parse the entered quantity from the TextEditingController
    final enteredQty = int.tryParse(quantityController.text) ?? 0;

    // Check if available quantity is less than 1 or entered quantity exceeds available quantity
    if (availableQty < 1) {
      showErrorSnackbar("Error", "This stock is Empty");
      return;
    } else if (enteredQty > availableQty.value) {
      showErrorSnackbar("Error", "Entered quantity exceeds available stock");
      return;
    }

    // Validate fields and proceed if valid
    if (_validateFields()) {
      saveCurrentItem(); // Save the current item details
      loadCurrentItem(); // Load the current item for processing
      calculateTotalAmount(); // Ensure total amount is updated

      // Prepare order data for preview
      final orderData = {
        'customerName': customerData['customer_name'] ?? '',
        'customerMobile': customerData['mob_number'] ?? '',
        'items': itemsData,
        "total_amount": totalAmount.value,
        "cart_id": "cartID",
      };
      print("Order placed in local List: $orderData");

      // Navigate to the order preview screen with arguments
      Get.to(() => PreviewOrderScreen(), arguments: {
        "cart_items": itemsData,
        "total_amount": totalAmount.value,
      });
    } else {
      showErrorSnackbar("Error", "Fill all the Item Details");
    }
  }
}
