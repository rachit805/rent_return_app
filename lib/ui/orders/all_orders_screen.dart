import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:rent_and_return/controller/orders_controller/all_order_controller.dart';
import 'package:rent_and_return/ui/orders/new_orders_screen.dart';
import 'package:rent_and_return/ui/orders/ordered_items_screen.dart';
import 'package:rent_and_return/utils/theme.dart';
import 'package:rent_and_return/widgets/action_btn.dart';
import 'package:rent_and_return/widgets/c_appbar.dart';
import 'package:rent_and_return/widgets/c_sizedbox.dart';
import 'package:url_launcher/url_launcher.dart';

class AllOrdersScreen extends StatelessWidget {
  AllOrdersScreen({super.key});
  final AllOrderController controller = Get.put(AllOrderController());
  void onRefresh() {
    controller.fetchOrderSummary();
  }

  @override
  Widget build(BuildContext context) {
    double sW = MediaQuery.of(context).size.width;
    double sH = MediaQuery.of(context).size.height;
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
        body: RefreshIndicator(
          onRefresh: () async {
            onRefresh();
          },
          child: Column(
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
                  final customer = customerId != null
                      ? controller.customerData[customerId] ?? {}
                      : {};
                  final customerName =
                      customer['customer_name'] ?? 'Loading...';
                  final customerCity = customer['address'] ?? 'Loading...';
                  final customerPhone = customer['mob_number'] ?? 'Loading...';
                  final idType = customer['id_type'].toString();
                  final alternativeMob =
                      customer['alternative_mob_number'].toString();
                  final idNumber = customer['id_number'].toString();
                  final refName = customer['ref_name'].toString();
                  final refNumber = customer['ref_number'].toString();
                  // print(object);
                  return GestureDetector(
                    onTap: () {
                      Get.to(() => AllOrderedItemScreen(
                            orderId: order['order_id'].toString(),
                            customerName: customerName,
                            customerCity: customerCity,
                            customerPhone: customerPhone,
                            isReturn: false,
                          ));
                    },
                    child: card(
                        sW,
                        sH,
                        order,
                        customerName,
                        customerCity,
                        customerPhone,
                        alternativeMob,
                        idType,
                        idNumber,
                        refName,
                        refNumber,
                        context,
                        false),
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

Widget card(
  double sW,
  double sH,
  Map<String, dynamic> order,
  String name,
  String city,
  String phone,
  String alternativeMob,
  String idType,
  String idNumber,
  String refName,
  String refNumber,
  BuildContext context,
  bool isReturn,
) {
  return Card(
    color: AppTheme.theme.scaffoldBackgroundColor,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            // crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              RichText(
                text: TextSpan(
                  text: '₹',
                  style: AppTheme.theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                  children: [
                    TextSpan(
                      text: '${order['total_bill_amount'] ?? 0}',
                      style: AppTheme.theme.textTheme.labelMedium?.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              // Spacing.h20,
              IconButton(
                icon: Icon(
                  Icons.info_outline,
                  color: Colors.black,
                ),
                onPressed: () {
                  showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(25.0)),
                    ),
                    builder: (BuildContext context) {
                      Widget detailRow(String label, String value) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                label,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                value,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      Future<void> _makePhoneCall(String phoneNumber) async {
                        final Uri phoneUri =
                            Uri(scheme: 'tel', path: phoneNumber);
                        if (await canLaunchUrl(phoneUri)) {
                          await launchUrl(phoneUri);
                        } else {
                          // print('Could not launch $phoneUri');
                        }
                      }

                      return Container(
                        // height: sH * 0.7,
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(25.0)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                width: 50,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            Center(
                              child: Text(
                                'Order Details',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            detailRow('Customer Name:', name),
                            GestureDetector(
                              onTap: (() {
                                _makePhoneCall(phone);
                              }),
                              child: detailRow('Mobile number:', phone),
                            ),
                            detailRow('Alternative Number:',
                                alternativeMob.toString()),
                            detailRow(
                                "${idType.toString()}:", idNumber.toString()),
                            detailRow('Reference name:', refName.toString()),
                            detailRow(
                                'Reference number:', refNumber.toString()),
                            detailRow('Address:', city),
                            detailRow('Delivery Date:',
                                order['delivery_date'] ?? 'N/A'),
                            detailRow(
                                'Return Date:', order['return_date'] ?? 'N/A'),
                            detailRow('Booked Date:',
                                order['transcation_date_time'] ?? 'N/A'),
                            detailRow('Total Bill Amount:',
                                '₹ ${order['total_bill_amount']}'),
                            detailRow('Advance Paid Amount:',
                                '- ₹ ${order['advance_amount']}'),
                            isReturn == false ? Divider() : SizedBox(),
                            isReturn == false
                                ? detailRow('Remaining Amount:',
                                    '₹ ${order['pending_amount']}')
                                : SizedBox(),
                          ],
                        ),
                      );
                    },
                  );
                },
                tooltip: 'Order Details',
              )
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                "assets/images/user_image.png",
                height: sH * 0.16,
                width: sW * 0.22,
                fit: BoxFit.fill,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTheme.theme.textTheme.bodySmall
                          ?.copyWith(fontWeight: FontWeight.w600, fontSize: 20),
                    ),
                    const SizedBox(height: 10),
                    cardDetail1(Icons.pin_drop, city),
                    const SizedBox(height: 10),
                    cardDetail1(Icons.phone, phone),
                    const SizedBox(height: 10),
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        cardDetail2(
                            Icons.done, "${order['delivery_date'] ?? ''} | "),
                        SizedBox(width: sW * 0.005),
                        Flexible(
                          child: Text(
                            "${order['return_date'] ?? ''}",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w500),
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
  );
}

Widget cardDetail1(IconData icon, String text) {
  return Row(
    children: [
      Icon(
        icon,
        size: 16,
        color: Colors.grey[700],
      ),
      const SizedBox(width: 5),
      Flexible(
        child: Text(
          text,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
    ],
  );
}

Widget cardDetail2(IconData icon, String label) {
  return Row(
    children: [
      Icon(
        icon,
        color: Colors.grey[700],
        size: 15,
      ),
      Spacing.h10,
      Text(
        label,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
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
                  final idType = customer?['id_type'].toString();
                  final alternativeMob =
                      customer?['alternative_mob_number'].toString();
                  final idNumber = customer?['id_number'].toString();
                  final refName = customer?['ref_name'].toString();
                  final refNumber = customer?['ref_number'].toString();
                  // print(object);
                  return GestureDetector(
                    onTap: () {
                      Get.to(() => AllOrderedItemScreen(
                            orderId: order['order_id'].toString(),
                            customerName: customerName,
                            customerCity: customerCity,
                            customerPhone: customerPhone,
                            isReturn: true,
                          ));
                    },
                    child: card(
                        sW,
                        sH,
                        order,
                        customerName,
                        customerCity,
                        customerPhone,
                        alternativeMob!,
                        idType!,
                        idNumber!,
                        refName!,
                        refNumber!,
                        context,
                        true),
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
