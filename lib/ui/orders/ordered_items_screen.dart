import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rent_and_return/controller/ordered_item_controller.dart';
import 'package:rent_and_return/controller/orders_controller/return_order_controller.dart';
import 'package:rent_and_return/utils/theme.dart';
import 'package:rent_and_return/widgets/c_appbar.dart';
import 'package:rent_and_return/widgets/c_btn.dart';
import 'package:rent_and_return/widgets/c_sizedbox.dart';

class AllOrderedItemScreen extends StatelessWidget {
  const AllOrderedItemScreen({super.key, required this.orderId});

  final String orderId;
  @override
  Widget build(BuildContext context) {
    final OrderedItemController controller = Get.put(OrderedItemController());

    double sW = MediaQuery.of(context).size.width;

    double sH = MediaQuery.of(context).size.height;
    controller.setOrderId(orderId); // Set orderId in the controller
    controller.getOrderedItems(); // Fetch ordered items

    print("OrderId>>> $orderId");
    final activeItems = controller.orderedItems
        .where((item) => item['status'] == 'Active')
        .toList();
    final returnItems = controller.orderedItems
        .where((item) => item['status'] == 'Return')
        .toList();
    print("ACTIVE ITEMS IN UI>> ${activeItems.length}");
    print("Ordered ITEMS IN UI>> ${controller.orderedItems.length}");
    print("Returned ITEMS IN UI>> ${controller.returnedOrdersData.length}");

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(75),
          child: Column(
            children: [
              CAppbar(
                title: "All Items",
                leading: true,
                leadingIconColor: Colors.black,
                labelColor: Colors.black,
                bgColor: AppTheme.theme.scaffoldBackgroundColor,
              ),
              const Divider()
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: sH * 0.025, bottom: sH * 0.01),
                child: Obx(() {
                  final activeItems = controller.orderedItems
                      .where((item) => item['status'] == 'Active')
                      .toList();
                  final returnItems = controller.orderedItems
                      .where((item) => item['status'] == 'Return')
                      .toList();

                  return TabBar(
                    dividerColor: Colors.transparent,
                    indicatorColor: AppTheme.theme.primaryColor,
                    labelColor: AppTheme.theme.primaryColor,
                    labelStyle: AppTheme.theme.textTheme.labelMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                    unselectedLabelColor: Colors.black,
                    tabs: [
                      SizedBox(
                        width: sW * 0.4,
                        child: Tab(
                          text: "All(${activeItems.length})",
                        ),
                      ),
                      SizedBox(
                        width: sW * 0.4,
                        child: Tab(
                          text: "Returned(${returnItems.length})",
                        ),
                      ),
                    ],
                  );
                }),
              ),
              Spacing.v20,
              Expanded(
                child: TabBarView(
                  children: [
                    OrderedItemsScreen(controller: controller, sW: sW),
                    ReturnOrdersTab(controller: controller, sW: sW),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderedItemsScreen extends StatelessWidget {
  const OrderedItemsScreen(
      {super.key, required this.controller, required this.sW});
  final OrderedItemController controller;
  final double sW;
  @override
  Widget build(BuildContext context) {
    double sH = MediaQuery.of(context).size.height;
    return Obx(() {
      // Filter only 'Active' status items
      final activeItems = controller.orderedItems
          .where((item) => item['status'] == 'Active')
          .toList();

      if (activeItems.isEmpty) {
        return const Center(
          child: Text(
            "No Active Orders, All orders returned!",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        );
      }

      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: activeItems.length,
              itemBuilder: (context, index) {
                final item = activeItems[index];
                debugPrint("ACTIVE ITEM >>> $item");
                return cartItemCard(item, index, context, controller);
              },
            ),
          ),
          cBtn("Close Order", () {
            showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (builder) {
                  return bottomSheet(sH, context);
                });
          }, Colors.white)
        ],
      );
    });
  }

  Widget bottomSheet(double sH, BuildContext context) {
    // Populate controllers with item data
    return Obx(() {
      controller.populateControllersWithCurrentItem();

      return SizedBox(
        height: sH * 0.64,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTextField(
                  controller.skuNameController, "Item Name", "Item Name"),
              buildTextField(controller.totalQtyController, "Total Quantity",
                  "Total Quantity"),
              buildTextField(controller.missingQtyController,
                  "Missing Quantity", "Missing Quantity"),
              buildTextField(controller.rentPriceController, "Rent Price",
                  "Rent Price (Each Item)"),
              buildTextField(controller.missingPriceController, "Missing Price",
                  "Missing Price per Item"),
              const Text(
                "Amount will be reflected in final billing amount",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              cspacingHeight(sH * 0.05),
              Obx(
                () => cBtn(
                    controller.lastItem.value == false
                        ? "Return Item"
                        : "View Summary", () {
                  controller.moveToNextItem();
                }, Colors.white),
              )
            ],
          ),
        ),
      );
    });
  }

  Widget buildTextField(
      TextEditingController controller, String label, String? hintText) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelStyle: AppTheme.theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w500, color: Colors.black, fontSize: 15),
        labelText: label,
        hintText: hintText,
        enabledBorder: const UnderlineInputBorder(),
      ),
    );
  }
}

Widget cartItemCard(Map<String, dynamic> item, int index, BuildContext context,
    OrderedItemController controller) {
  double sW = MediaQuery.of(context).size.width;

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
              "assets/images/chair.png",
              width: 80,
              height: 80,
              fit: BoxFit.fill,
            ),
            const SizedBox(width: 15),
            Column(
              // mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      item['sku_name'] ?? "Item Name",
                      style: AppTheme.theme.textTheme.labelMedium,
                    ),
                    // Expanded(child: SizedBox()),
                    SizedBox(
                      width: sW * 0.07,
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
                            style:
                                AppTheme.theme.textTheme.labelMedium?.copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.theme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      Text(
                        "Delivery: ${item['delivery_date'] ?? 'N/A'} - ${item['return_date'] ?? 'N/A'}",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
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

class ReturnOrdersTab extends StatelessWidget {
  final OrderedItemController controller;
  final double sW;

  const ReturnOrdersTab(
      {super.key, required this.controller, required this.sW});
  @override
  Widget build(BuildContext context) {
    // double sH = MediaQuery.of(context).size.height;
    return Obx(() {
      // // Filter only 'Active' status items
      final activeItems = controller.orderedItems
          .where((item) => item['status'] == 'Return')
          .toList();
      // activeItems.assignAll(controller.returnedOrdersData);
      if (activeItems.isEmpty) {
        return const Center(
          child: Text(
            "No Return Orders",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        );
      }

      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: activeItems.length,
              itemBuilder: (context, index) {
                final item = activeItems[index];
                debugPrint("Return ITEM >>> $item");
                return cartItemCard(item, index, context, controller);
              },
            ),
          ),
        ],
      );
    });
  }
}
