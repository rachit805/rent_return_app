import 'dart:ffi' as ffi;

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rent_and_return/controller/dashboard_controller.dart';
import 'package:rent_and_return/ui/auth/drawer/about_screen.dart';
import 'package:rent_and_return/ui/auth/drawer/contactus.dart';
import 'package:rent_and_return/ui/auth/drawer/setting_screen.dart';
import 'package:rent_and_return/ui/bottom_nav_bar/profile_screen.dart';
import 'package:rent_and_return/ui/orders/all_orders_screen.dart';
import 'package:rent_and_return/ui/orders/new_orders_screen.dart';
import 'package:rent_and_return/ui/orders/ordered_items_screen.dart';
import 'package:rent_and_return/utils/theme.dart';
import 'package:rent_and_return/widgets/c_appbar.dart';
import 'package:rent_and_return/widgets/c_sizedbox.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    double sW = MediaQuery.of(context).size.width;
    double sH = MediaQuery.of(context).size.height;
    final DashboardController controller = Get.put(DashboardController());
    controller.fetchOrderSummary();

    return Scaffold(
      key: scaffoldKey,
      drawer: drawer(),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: HAppBar(
          label: "Home",
          scaffoldKey: scaffoldKey, // Pass the scaffoldKey here
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSectionTitle(context, "Monthly Stats"),
            cspacingHeight(sH * 0.015),
            CarouselSlider(
              options: CarouselOptions(
                height: sH * 0.25,
                autoPlay: false,
                enlargeCenterPage: true,
                aspectRatio: 16 / 9,
                autoPlayInterval: const Duration(seconds: 3),
                onPageChanged: (index, reason) {
                  controller.currentPage.value = index;
                },
              ),
              items: controller.data.map((item) {
                return _buildCarouselCard(context, item);
              }).toList(),
            ),
            Obx(() => _buildCarouselIndicators(context, controller)),
            cspacingHeight(sH * 0.01),
            _buildExpandableList(context, sW, sH, "Today's Returns",
                controller.todaysReturns, controller.customerdata),
            _buildExpandableList(context, sW, sH, "This week's Returns",
                controller.thisWeeksReturns, controller.customerdata),
            _buildExpandableList(context, sW, sH, "This month's Returns",
                controller.thisMonthsReturns, controller.customerdata),
          ],
        ),
      ),
    );
  }
}

Widget drawer() {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(color: AppTheme.theme.primaryColor),
          child: Text(
            'Menu',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
        ListTile(
          leading: Icon(Icons.person),
          title: Text('Profile'),
          onTap: () {
            Get.to(() => ProfileScreen());
          },
        ),
        ListTile(
          leading: Icon(Icons.person),
          title: Text('Setting'),
          onTap: () {
            Get.to(() => SettingsScreen());
          },
        ),
        ListTile(
          leading: Icon(Icons.person),
          title: Text('About Us'),
          onTap: () {
            Get.to(() => AboutUsScreen());
          },
        ),
        ListTile(
          leading: Icon(Icons.person),
          title: Text('Contact Us'),
          onTap: () {
            Get.to(() => ContactUsScreen());
          },
        ),
      ],
    ),
  );
}

Widget _buildSectionTitle(BuildContext context, String title) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.theme.textTheme.labelMedium
              ?.copyWith(color: AppTheme.theme.primaryColor),
        ),
      ],
    ),
  );
}

Widget _buildCarouselCard(BuildContext context, Map<String, dynamic> item) {
  return Card(
    color: Theme.of(context).primaryColor,
    child: Row(
      children: [
        const SizedBox(width: 8),
        Center(
          child: Image.asset(
            "assets/images/calender.png",
            height: 60,
            width: 60,
          ),
        ),
        const SizedBox(width: 16),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              cardTile(item["month"], 15, FontWeight.w600),
              cardTile(
                  "Total Orders: ${item["totalOrders"]}", 13, FontWeight.w400),
              cardTile(
                  "Closed Order: ${item["closedOrders"]}", 13, FontWeight.w400),
              cardTile("Pending Order: ${item["pendingOrders"]}", 13,
                  FontWeight.w400),
            ],
          ),
        ),
        const Expanded(child: SizedBox()),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: cardTile(item["revenue"], 14, FontWeight.w500),
            ),
            cspacingHeight(30),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                  child: Text(
                    "Details",
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    ),
  );
}

Widget _buildCarouselIndicators(
    BuildContext context, DashboardController controller) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(
      controller.data.length,
      (index) => Container(
        width: 6,
        height: controller.currentPage.value == index ? 10 : 6,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: controller.currentPage.value == index
              ? Theme.of(context).primaryColor
              : Colors.grey,
        ),
      ),
    ),
  );
}

Widget _buildExpandableList(BuildContext context, double sW, double sH,
    String title, RxList<dynamic> orders, var customer) {
  final isExpanded = (orders.isNotEmpty).obs;

  return Obx(() => Column(
        children: [
          GestureDetector(
            onTap: () => isExpanded.value = !isExpanded.value,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: AppTheme.theme.textTheme.labelMedium
                        ?.copyWith(color: AppTheme.theme.primaryColor),
                  ),
                  Icon(
                    isExpanded.value
                        ? Icons.arrow_drop_up
                        : Icons.arrow_drop_down,
                    color: AppTheme.theme.primaryColor,
                  ),
                ],
              ),
            ),
          ),
          cspacingHeight(sH * 0.01),
          if (isExpanded.value)
            orders.isEmpty
                ? const Center(child: Text("No return orders."))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      final customerId = order['customer_id'];
                      final customerData = customer[customerId];

                      print("Customer Data in List>> $customerData");
                      print(customerData?['customer_name']);
                      final customerName =
                          customerData?['customer_name'] ?? 'Loading...';
                      print(customerName);
                      final customerCity =
                          customerData?['address'] ?? 'Loading...';
                      final customerPhone =
                          customerData?['mob_number']?.toString() ?? '0';

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
                        child: card(sW, sH, order, customerName, customerPhone,
                            customerCity, '', '', '', '', '', context, false),
                      );
                    },
                  ),
        ],
      ));
}

Widget cardTile(String label, double fontsize, FontWeight fontWeight) {
  return Padding(
    padding: const EdgeInsets.all(4),
    child: Text(
      label,
      style: TextStyle(
        fontFamily: "Roboto",
        fontSize: fontsize,
        fontWeight: fontWeight,
        color: Colors.white,
      ),
    ),
  );
}

class HAppBar extends StatelessWidget {
  const HAppBar({super.key, required this.label, required this.scaffoldKey});
  final String label;
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.theme.scaffoldBackgroundColor,
      title: Text(
        label,
        style: const TextStyle(
          fontFamily: "Roboto",
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      centerTitle: false,
      automaticallyImplyLeading: false,
      leading: IconButton(
        onPressed: () {
          scaffoldKey.currentState?.openDrawer();
        },
        icon: const Icon(
          Icons.menu,
          color: Colors.black,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 15),
          child: IconButtonWithLabel(
            icon: Icons.add,
            label: "New Order",
            iconColor: AppTheme.theme.primaryColor,
            textColor: AppTheme.theme.primaryColor,
            onPressed: () {
              Get.to(() => CreateOrderUserDetailScreen());
            },
          ),
        ),
      ],
    );
  }
}
