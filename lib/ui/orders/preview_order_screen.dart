import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rent_and_return/controller/add_item_order_controller.dart';
import 'package:rent_and_return/ui/orders/add_address_screen.dart';
import 'package:rent_and_return/utils/theme.dart';
import 'package:rent_and_return/widgets/c_btn.dart';
import 'package:rent_and_return/widgets/c_sizedbox.dart';

class PreviewOrderScreen extends StatelessWidget {
  PreviewOrderScreen({super.key});

  final AddItemOrderController controller = Get.find();
  final Map<String, dynamic> orderData = Get.arguments ?? {};

  Future<void> refreshData() async {
    await Future.delayed(const Duration(seconds: 1));
    await controller.refreshCartItems(); // Implement in controller
  }

  @override
  Widget build(BuildContext context) {
    double sH = MediaQuery.of(context).size.height;

    // If orderData contains initial cart items, set them in the controller
// Remove this code since `cartItems` is already reactive
    final List<Map<String, dynamic>> finalCartItems =
        (orderData['cart_items'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    controller.setCartItems(finalCartItems);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.theme.scaffoldBackgroundColor,
        automaticallyImplyLeading: false,
        leading: InkWell(
          onTap: () => Get.back(),
          child: const Icon(Icons.close,
              size: 24, weight: 60, color: Colors.black),
        ),
        title: const Text(
          "Preview Order",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => Get.back(),
              color: AppTheme.theme.primaryColor,
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(15),
          child: Divider(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: refreshData,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => RichText(
                  text: TextSpan(
                    text: 'Grand Total:- ',
                    style: AppTheme.theme.textTheme.labelMedium
                        ?.copyWith(fontWeight: FontWeight.w500, fontSize: 20),
                    children: [
                      TextSpan(
                        text: '₹',
                        style: AppTheme.theme.textTheme.labelMedium?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      TextSpan(
                        text: controller.totalAmount.value.toStringAsFixed(0),
                        // text: "${orderData['total_amount'] ?? 0.0}",
                        style: AppTheme.theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 25,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              cspacingHeight(sH * 0.06),
              cBtn(
                "Place Order",
                () {
                  print("InititalCartItem IN UI:: $finalCartItems");

                  print("InititalCartItem IN UI:: ${finalCartItems.length}");
                  print("ORDERDATA IN UI:: $orderData");

                  print("ORDERDATA IN UI:: ${orderData.length}");
                  Get.to(() =>
                      AddAddressScreen(totalAmount: controller.totalAmount));
                },
                AppTheme.theme.scaffoldBackgroundColor,
              ),
              cspacingHeight(sH * 0.02),
              const Divider(),
              cspacingHeight(sH * 0.03),

              // Update the ListView.builder
              Expanded(
                child: Obx(() {
                  return ListView.builder(
                    itemCount: controller.cartItems.length,
                    itemBuilder: (context, index) {
                      final item = controller.cartItems[index];
                      return cartItemCard(item, index, context);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget cartItemCard(
      Map<String, dynamic> item, int index, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Card(
        elevation: 4,
        color: AppTheme.theme.scaffoldBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Image.asset(
                item['image'] ?? "assets/images/chair.png",
                width: 80,
                height: 80,
                fit: BoxFit.fill,
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['item'] ?? "Item Name",
                    style: AppTheme.theme.textTheme.labelMedium,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      "Return: ${item['deliveryDate'] ?? 'N/A'}",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        color: Colors.grey.shade300,
                        padding: const EdgeInsets.all(2),
                        child: Text(
                          "${item['quantity'] ?? 0}",
                          style: AppTheme.theme.textTheme.labelMedium,
                        ),
                      ),
                      Text(
                        " x Rs ${item['rentPrice'] ?? 0}",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Column(
                children: [
                  RichText(
                    text: TextSpan(
                      text: '₹',
                      style: AppTheme.theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppTheme.theme.primaryColor,
                      ),
                      children: [
                        TextSpan(
                          text: item["totalItemRent"].toStringAsFixed(0),
                          style: AppTheme.theme.textTheme.labelMedium?.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.theme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                    radius: 25,
                                    backgroundColor:
                                        Colors.red.withOpacity(0.3),
                                    child: const Icon(Icons.delete,
                                        size: 35, color: Colors.red)),
                                // SizedBox(width: 8),
                                // Text("Remove Item"),
                              ],
                            ),
                            content: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                text:
                                    "Are you sure you want to ", // Normal text
                                style: AppTheme.theme.textTheme.bodyMedium
                                    ?.copyWith(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500),
                                children: [
                                  TextSpan(
                                    text:
                                        "Remove this item", // Highlighted text
                                    style: AppTheme.theme.textTheme.bodyMedium
                                        ?.copyWith(
                                            color: Colors.red, fontSize: 20),
                                  ),
                                  TextSpan(
                                    text:
                                        "? This action cannot be undo!", // Remaining normal text
                                    style: AppTheme.theme.textTheme.bodyMedium
                                        ?.copyWith(fontSize: 20),
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(
                                    color: AppTheme.theme.primaryColor,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  controller.removeItem(index);
                                  Navigator.of(context).pop();
                                },
                                child: const Text(
                                  "Remove",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.theme.primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(5),
                      child: Text(
                        "Remove",
                        textAlign: TextAlign.center,
                        style: AppTheme.theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.theme.scaffoldBackgroundColor,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
