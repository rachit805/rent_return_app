import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rent_and_return/controller/item_detail_controller.dart';
import 'package:rent_and_return/utils/theme.dart';
import 'package:rent_and_return/widgets/action_btn.dart';
import 'package:rent_and_return/widgets/c_appbar.dart';
import 'package:rent_and_return/widgets/c_btn.dart';
import 'package:rent_and_return/widgets/c_sizedbox.dart';
import 'package:rent_and_return/widgets/master_card.dart';
import 'package:rent_and_return/widgets/stock_history_card.dart';

class ItemDetailScreen extends StatelessWidget {
  final Map<String, dynamic> item;
  final ItemDetailController controller = Get.put(ItemDetailController());

  ItemDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    double sW = MediaQuery.of(context).size.width;
    double sH = MediaQuery.of(context).size.height;

    final String itemName = item['item_name'] ?? '';
    final String qnty = item['quantity'].toString();
    final double rentPrice = item['rent_price'];
    final String categoryName = item['category_name'] ?? '';
    final String size = item['size_name'] ?? '';
    final double buyPrice = item['buy_price'] ?? 0;
    final String skuId = item['sku_uid'] ?? '';
    final int categoryId = item['category_id'] ?? '';
    final int itemId = item['item_id'] ?? '';
    final int sizeId = item['size_id'] ?? '';
    final String skuName =
        "${item['category_name']}_${item['item_name']}_${item['size_name']}";

    Future<void> refreshData() async {
      await Future.delayed(const Duration(seconds: 1));
      await controller.fetchItemsBySkuId(skuId, skuName);
      controller.calculateMasterData(skuName);
      controller.finalRemainingQuantity.value;
      controller.calculateFinalQuantity();
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: CAppbar(
            title: "Item Details",
            textcolor: AppTheme.theme.scaffoldBackgroundColor,
            action: [
              actionBtn(
                  () => showModalBottomSheet(
                      context: context,
                      builder: (builder) => bottomsheet(context, controller,
                          skuId, categoryId, itemId, sizeId)),
                  'Add Stock')
            ],
            leading: true,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() {
                if (controller.masterListData.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final masterData = controller.masterListData[0];
                print("MASTER CRAD UI>> $masterData");
                return masterCard(
                  categoryName: categoryName,
                  itemName: itemName,
                  quantity: masterData['total_quantity'],
                  rentPrice: masterData['avg_rent_price'] ?? 0.0,
                  sH: sH,
                  sW: sW,
                  size: size,
                  buyPrice: masterData['avg_buy_price'] ?? 0.0,
                );
              }),
              Spacing.v15,
              Obx(() {
                final activeItems = controller.placedOrdersData
                    .where((item) => item['status'] != 'Return')
                    .toList();

                return TabBar(
                  indicatorColor: AppTheme.theme.primaryColor,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  tabs: [
                    const Tab(text: "Stock History"),
                    Tab(text: "Current Orders (${activeItems.length})"),
                  ],
                );
              }),
              Spacing.v20,
              Expanded(
                child: TabBarView(
                  children: [
                    StockHistoryTab(
                      skuId: skuId,
                      refreshData: refreshData,
                      skuName: skuName,
                    ),
                    OrderHistoryTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget bottomsheet(BuildContext context, ItemDetailController controller,
      skuId, categoryID, itemId, sizeId) {
    double sW = MediaQuery.of(context).size.width;
    double sH = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        // height: sH * 0.55,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            cspacingHeight(sH * 0.03),
            // Quantity
            buildLabel("Quantity"),
            buildTextField(controller.quantityController),
            cspacingHeight(sH * 0.02),

            // Purchase Price
            buildLabel("Purchase Price (per item)"),
            buildTextField(controller.buypriceController),
            cspacingHeight(sH * 0.02),

            // Rent Price
            buildLabel("Rent Price (per item)"),
            buildTextField(controller.rentpriceController),
            cspacingHeight(sH * 0.05),

            cBtn("Add Stock", () async {
              await controller.addmoreStock(skuId, categoryID, itemId, sizeId);
              Get.back();
            }, Colors.white),
          ],
        ),
      ),
    );
  }

  Widget buildLabel(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget buildTextField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.all(8),
        border: OutlineInputBorder(),
      ),
    );
  }
}

class StockHistoryTab extends StatelessWidget {
  final String skuId;
  final String skuName;

  final Future<void> Function() refreshData; // Accept the function type
  StockHistoryTab(
      {super.key,
      required this.skuId,
      required this.refreshData,
      required this.skuName});
  final ItemDetailController controller = Get.put(ItemDetailController());

  @override
  Widget build(BuildContext context) {
    double sW = MediaQuery.of(context).size.width;
    double sH = MediaQuery.of(context).size.height;

    controller.fetchItemsBySkuId(skuId, skuName);

    return Obx(() {
      if (controller.slaveCardList.isEmpty) {
        return const Center(
          child: Text(
            "No data available",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: refreshData,
        child: ListView.builder(
          itemCount: controller.slaveCardList.length,
          itemBuilder: (context, index) {
            final item = controller.slaveCardList[index];

            print("Filtered SLAVE IN UI $item");
            final String itemName = item['item_name'] ?? 'Unknown Item';
            final int qnty =
                int.tryParse(item['latest_quantity']?.toString() ?? '') ?? 0;
            final double rentPrice =
                double.tryParse(item['latest_rent_price']?.toString() ?? '') ??
                    0;
            final String categoryName =
                item['category_name'] ?? 'Unknown Category';
            final String size = item['size_name'] ?? 'Unknown Category';
            final double buyPrice =
                double.tryParse(item['latest_buy_price']?.toString() ?? '') ??
                    0.0;
            final String createdDate = item['added_date'] ?? '';
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: stockHistoryCard(
                categoryName: categoryName,
                itemName: itemName,
                quantity: qnty,
                rentPrice: rentPrice,
                sH: sH,
                sW: sW,
                size: size,
                buyPrice: buyPrice,
                createdDate: createdDate,
              ),
            );
          },
        ),
      );
    });
  }
}

// Mock Order History Tab
class OrderHistoryTab extends StatelessWidget {
  @override
  OrderHistoryTab({super.key});
  final ItemDetailController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    // controller.fetchPlacedOrders();
    return Obx(() {
      final activeItems = controller.placedOrdersData
          .where((item) => item['status'] != 'Return')
          .toList();
      print("ACTIVE ITEMS IN UI>>> ${activeItems}");
      print("Placed ITEMS IN UI>>> ${controller.placedOrdersData}");
      return ListView.builder(
          itemCount: activeItems.length,
          itemBuilder: (context, i) {
            final data = activeItems[i];
            return cartItemCard(
              data,
              i,
              context,
            );
          });
    });
  }

  Widget cartItemCard(
    Map<String, dynamic> item,
    int index,
    BuildContext context,
  ) {
    double sW = MediaQuery.of(context).size.width;
    final imageFile = item['image'] ?? null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Card(
        elevation: 0.5,
        color: AppTheme.theme.scaffoldBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              // Container(
              //   width: 80,
              //   height: 80,
              //   decoration: BoxDecoration(
              //     border: Border.all(
              //       width: 1.5,
              //       color: Colors.grey.shade400,
              //     ),
              //     borderRadius: BorderRadius.circular(20),
              //   ),
              //   child: (imageFile != null && imageFile is Uint8List)
              //       ? ClipOval(
              //           child: Image.memory(
              //           imageFile,
              //           fit: BoxFit.fill,
              //         )) // Display image
              //       : Icon(
              //           Icons.image_not_supported,
              //           color: Colors.black54,
              //         ), // Placeholder if no image
              // ),

              // const SizedBox(width: 15),
              Column(
                // mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Booked Date: ${item['booked_date']}",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700)),
                      // Expanded(child: SizedBox()),
                      SizedBox(
                        width: 20,
                      ),
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
                              text: item["total_price"].toString(),
                              style: AppTheme.theme.textTheme.labelMedium
                                  ?.copyWith(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.theme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.black26,
                        child: Text(
                          "i",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        Text(
                          "Delivery Date: ${item['delivery_date'] ?? 'N/A'}",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text("Return Date: ${item['return_date'] ?? 'N/A'}",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700)),
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
                        " x Rs ${item['rent_price'] ?? 0}",
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
              // const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
