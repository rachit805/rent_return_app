import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:rent_and_return/controller/orders_controller/all_order_controller.dart';
import 'package:rent_and_return/ui/orders/new_orders_screen.dart';
import 'package:rent_and_return/ui/orders/ordered_items_screen.dart';
import 'package:rent_and_return/utils/theme.dart';
import 'package:rent_and_return/widgets/action_btn.dart';
import 'package:rent_and_return/widgets/c_appbar.dart';
import 'package:rent_and_return/widgets/c_search_bar.dart';
import 'package:rent_and_return/widgets/c_sizedbox.dart';

class AllOrdersScreen extends StatelessWidget {
  AllOrdersScreen({super.key});
  final AllOrderController controller = Get.put(AllOrderController());

  @override
  Widget build(BuildContext context) {
    double sW = MediaQuery.of(context).size.width;
    double sH = MediaQuery.of(context).size.height;
    controller.initializeBannerAd();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: CAppbar(
            title: "All Orders",
            leading: false,
            action: [
              actionBtn(() {
                Get.to(() => CreateOrderUserDetailScreen());
              }, "New Order")
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Padding(
                    padding:
                        EdgeInsets.only(top: sH * 0.025, bottom: sH * 0.01),
                    child: Obx(() {
                      final activeItems = controller.orderSummary
                          .where((item) => item['status'] != 'Closed Order')
                          .toList();
                      final returnItems = controller.orderSummary
                          .where((item) => item['status'] == 'Closed Order')
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
                              text: "Active (${activeItems.length})",
                            ),
                          ),
                          SizedBox(
                            width: sW * 0.4,
                            child: Tab(
                              text: "Closed (${returnItems.length})",
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                  Spacing.v20,
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ActiveOrderTab(),
                  ClosedOrderTab(),
                ],
              ),
            ),
            
          ],
        ),
      ),
    );
  }
}

class ActiveOrderTab extends StatelessWidget {
  ActiveOrderTab({Key? key}) : super(key: key);
  final AllOrderController controller = Get.put(AllOrderController());

  @override
  Widget build(BuildContext context) {
    double sW = MediaQuery.of(context).size.width;
    double sH = MediaQuery.of(context).size.height;

    controller.fetchOrderSummary();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // csearchbar(sW, "Search Item"),
          const SizedBox(height: 20),

          /// Order List
          Expanded(
            child: Obx(() {
              final activeItems = controller.orderSummary
                  .where((item) => item['status'] != 'Closed Order')
                  .toList();

              if (activeItems.isEmpty) {
                return const Center(child: Text("No orders found."));
              }

              return ListView.builder(
                itemCount: activeItems.length,
                itemBuilder: (context, index) {
                  final order = activeItems[index];
                  final customerId = order['customer_id'];
                  final customer = controller.customerData[customerId];
                  final customerName =
                      customer?['customer_name'] ?? 'Loading...';
                  final customerCity = customer?['address'] ?? 'Loading...';
                  final customerPhone = customer?['mob_number'] ?? 'Loading...';
                  // print(object);
                  return GestureDetector(
                    onTap: () {
                      Get.to(() => AllOrderedItemScreen(
                          orderId: order['order_id'].toString()));
                    },
                    child: card(sW, sH, order, customerName, customerCity,
                        customerPhone),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

Widget card(double sW, double sH, Map<String, dynamic> order, String name,
    String city, String phone) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: Card(
      color: AppTheme.theme.scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                RichText(
                  text: TextSpan(
                    text: '₹',
                    style: AppTheme.theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                    children: [
                      TextSpan(
                        text: '${order['total_bill_amount'] ?? 0}',
                        style: AppTheme.theme.textTheme.labelMedium?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  "assets/images/user_image.png",
                  height: sH * 0.15,
                  width: sW * 0.3,
                  fit: BoxFit.fill,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTheme.theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      cardDetail1(Icons.pin_drop, city),
                      const SizedBox(height: 10),
                      cardDetail1(Icons.phone, phone),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          cardDetail2(Icons.done, order['delivery_date'] ?? ''),
                          SizedBox(width: sW * 0.01),
                          Flexible(
                            child: Text(
                              "ID: ${order['order_id'] ?? ''}",
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget cardDetail1(IconData icon, String text) {
  return Row(
    children: [
      Icon(
        icon,
        size: 16,
        color: Colors.black,
      ),
      const SizedBox(width: 5),
      Text(text),
    ],
  );
}

Widget cardDetail2(IconData icon, String label) {
  return Row(
    children: [
      CircleAvatar(
        radius: 10,
        backgroundColor: AppTheme.theme.primaryColor,
        child: Icon(
          icon,
          color: Colors.white,
          size: 15,
        ),
      ),
      Spacing.h10,
      Text(
        label,
        style: AppTheme.theme.textTheme.labelMedium?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          // color: AppTheme.theme.primaryColor,
        ),
      ),
    ],
  );
}

class ClosedOrderTab extends StatelessWidget {
  ClosedOrderTab({super.key});
  final AllOrderController controller = Get.put(AllOrderController());

  @override
  Widget build(BuildContext context) {
    double sW = MediaQuery.of(context).size.width;
    double sH = MediaQuery.of(context).size.height;

    controller.fetchOrderSummary();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // csearchbar(sW, "Search Item"),
          const SizedBox(height: 20),

          /// Order List
          Expanded(
            child: Obx(() {
              final closedOrder = controller.orderSummary
                  .where((item) => item['status'] == 'Closed Order')
                  .toList();

              if (closedOrder.isEmpty) {
                return const Center(child: Text("No orders found."));
              }

              return ListView.builder(
                itemCount: closedOrder.length,
                itemBuilder: (context, index) {
                  final order = closedOrder[index];
                  final customerId = order['customer_id'];
                  final customer = controller.customerData[customerId];
                  final customerName =
                      customer?['customer_name'] ?? 'Loading...';
                  final customerCity = customer?['address'] ?? 'Loading...';
                  final customerPhone = customer?['mob_number'] ?? 'Loading...';
                  // print(object);
                  return GestureDetector(
                    onTap: () {
                      Get.to(() => AllOrderedItemScreen(
                          orderId: order['order_id'].toString()));
                    },
                    child: card(sW, sH, order, customerName, customerCity,
                        customerPhone),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
