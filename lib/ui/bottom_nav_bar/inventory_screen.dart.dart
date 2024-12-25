import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:rent_and_return/controller/home_screen_controller.dart';
import 'package:rent_and_return/controller/item_detail_controller.dart';
import 'package:rent_and_return/ui/inventory/add_inventory_screen.dart';
import 'package:rent_and_return/ui/inventory/item_detail_screen.dart';
import 'package:rent_and_return/utils/strings.dart';
import 'package:rent_and_return/utils/theme.dart';
import 'package:rent_and_return/widgets/c_appbar.dart';
import 'package:rent_and_return/widgets/c_search_bar.dart';
import 'package:rent_and_return/widgets/c_sizedbox.dart';
import 'package:rent_and_return/widgets/stock_indicator.dart';

class InventoryScreen extends StatelessWidget {
  InventoryScreen({super.key});
  final ItemDetailController itemDetailController =
      Get.put(ItemDetailController());
  final InventoryController controller = Get.put(InventoryController());

  @override
  Widget build(BuildContext context) {
    double sW = MediaQuery.of(context).size.width;
    double sH = MediaQuery.of(context).size.height;
    Future<void> refreshData() async {
      await Future.delayed(const Duration(seconds: 1));
      await controller.fetchItems();
      // await itemDetailController.calculateMasterData();
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: CAppbar(
          labelColor: AppTheme.theme.primaryColor,
          bgColor: AppTheme.theme.scaffoldBackgroundColor,
          leadingIconColor: AppTheme.theme.primaryColor,
          title: homeAbtitle,
          action: [
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: IconButtonWithLabel(
                icon: Icons.add,
                label: "Add Item",
                onPressed: () {
                  Get.to(() => AddInventoryScreen());
                },
              ),
            )
          ],
          leading: false,
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          displacement: 40,
          color: AppTheme.theme.primaryColor,
          onRefresh: refreshData,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                cspacingHeight(sH * 0.02),
                csearchbar(sW, "Search Item"),
                cspacingHeight(sH * 0.02),
                stockIndicator(sW),
                cspacingHeight(sH * 0.015),
                Expanded(
                  child: Obx(() {
                    if (controller.items.isEmpty) {
                      return const Center(
                        child: Text(
                          "No items available",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      );
                    }
                    return GridView.builder(
                      itemCount: controller.items.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 20.0,
                        mainAxisSpacing: 20.0,
                        childAspectRatio: (sW * 0.4) / (sH * 0.18),
                      ),
                      itemBuilder: (context, index) {
                        final item = controller.items[index];

                        print("ITEM LENGTH IN UI ${controller.items.length}");
                        return GestureDetector(
                          onTap: () {},
                          child: GestureDetector(
                            onTap: () {
                              Get.to(() => ItemDetailScreen(
                                    item: item,
                                  ));
                            },
                            child: invContainer(
                                categoryName:
                                    item['category_name'] ?? 'Not available',
                                itemName: item['item_name'] ?? 'Unknown',
                                quantity: item['quantity'] ?? 0,
                                rentPrice: item['rent_price'] ?? 0.0,
                                size: item['size_name'] ?? "Unknown",
                                sku_id: item['sku_id'] ?? "Unknown",
                                category_id: item['category_id'] ?? "Unknown",
                                item_id: item['item_id'] ?? "Unknown",
                                size_id: item['size_id'] ?? "Unknown",
                                imagefile: item['image'],
                                context: context),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget invContainer({
    required String categoryName,
    required String itemName,
    required int quantity,
    required double rentPrice,
    required size,
    required sku_id,
    required category_id,
    required item_id,
    required size_id,
    required imagefile,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CircleAvatar(
                backgroundColor:
                    quantity == 0 ? Colors.red : AppTheme.theme.primaryColor,
                radius: 8,
              ),
            ],
          ),
          Text(
            categoryName,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          Text(
            itemName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Qty: $quantity",
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              Text(
                "Size: $size",
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  if (imagefile != null && imagefile is Uint8List) {
                    // Show large image in a dialog or fullscreen
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        child: Image.memory(imagefile, fit: BoxFit.contain),
                      ),
                    );
                  }
                },
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1.5,
                      color: Colors.grey.shade400,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: (imagefile != null && imagefile is Uint8List)
                      ? ClipOval(
                          child: Image.memory(
                          imagefile,
                          fit: BoxFit.fill,
                        )) // Display image
                      : Icon(
                          Icons.image_not_supported,
                          color: Colors.black54,
                        ), // Placeholder if no image
                ),
              ),
              Text(
                "₹${rentPrice.toStringAsFixed(0)}/- per piece",
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
