import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rent_and_return/controller/home_screen_controller.dart';
import 'package:rent_and_return/controller/item_detail_controller.dart';
import 'package:rent_and_return/ui/inventory/add_inventory_screen.dart';
import 'package:rent_and_return/utils/theme.dart';
import 'package:rent_and_return/widgets/c_appbar.dart';
import 'package:rent_and_return/widgets/c_btn.dart';
import 'package:rent_and_return/widgets/c_sizedbox.dart';
import 'package:rent_and_return/widgets/master_card.dart';
import 'package:rent_and_return/widgets/stock_history_card.dart';

class ItemDetailScreen extends StatelessWidget {
  final Map<String, dynamic> item;
  final HomeController homeController = Get.put(HomeController());
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

    Future<void> refreshData() async {
      await Future.delayed(const Duration(seconds: 1));
      await controller.fetchItemsBySkuId(skuId);
      controller.calculateMasterData();
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
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: IconButtonWithLabel(
                  icon: Icons.add,
                  label: "Add Stock",
                  textColor: AppTheme.theme.scaffoldBackgroundColor,
                  onPressed: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (builder) => bottomsheet(context, controller,
                            skuId, categoryId, itemId, sizeId));
                  },
                ),
              ),
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

                return masterCard(
                  categoryName: categoryName,
                  itemName: itemName,
                  quantity: masterData['total_quantity'],
                  rentPrice: masterData['avg_rent_price'],
                  sH: sH,
                  sW: sW,
                  size: size,
                  buyPrice: masterData['avg_buy_price'],
                );
              }),
              Spacing.v15,
              TabBar(
                indicatorColor: AppTheme.theme.primaryColor,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: "Stock History"),
                  Tab(text: "Current Orders"),
                ],
              ),
              Spacing.v20,
              Expanded(
                child: TabBarView(
                  children: [
                    StockHistoryTab(
                      skuId: skuId,
                      refreshData: refreshData,
                    ),
                    const OrderHistoryTab(),
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
            }),
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
  final Future<void> Function() refreshData; // Accept the function type
  StockHistoryTab({super.key, required this.skuId, required this.refreshData});
  final ItemDetailController controller = Get.put(ItemDetailController());

  @override
  Widget build(BuildContext context) {
    double sW = MediaQuery.of(context).size.width;
    double sH = MediaQuery.of(context).size.height;

    // Fetch items filtered by skuId when the widget is built
    controller.fetchItemsBySkuId(skuId);

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
  const OrderHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("No Order Here!!"),
    );
  }
}
