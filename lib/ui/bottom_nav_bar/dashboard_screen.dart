import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rent_and_return/controller/dashboard_controller.dart';
import 'package:rent_and_return/ui/orders/all_orders_screen.dart';
import 'package:rent_and_return/ui/orders/new_orders_screen.dart';
import 'package:rent_and_return/ui/orders/ordered_items_screen.dart';
import 'package:rent_and_return/utils/theme.dart';
import 'package:rent_and_return/widgets/action_btn.dart';
import 'package:rent_and_return/widgets/c_appbar.dart';
import 'package:rent_and_return/widgets/c_sizedbox.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double sW = MediaQuery.of(context).size.width;
    double sH = MediaQuery.of(context).size.height;
    final DashboardController controller = Get.put(DashboardController());
    controller.fetchOrderSummary();

    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: HAppBar(
          label: "Home",
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
            _buildExpandableList(
                context, sW, sH, "Today's Returns", controller.todaysReturns),
            _buildExpandableList(context, sW, sH, "This week's Returns",
                controller.thisWeeksReturns),
            _buildExpandableList(context, sW, sH, "This month's Returns",
                controller.thisMonthsReturns),
          ],
        ),
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
                cardTile("Total Orders: ${item["totalOrders"]}", 13,
                    FontWeight.w400),
                cardTile("Closed Order: ${item["closedOrders"]}", 13,
                    FontWeight.w400),
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
      String title, RxList<dynamic> orders) {
    final isExpanded = false.obs;

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

                        return GestureDetector(
                          onTap: () {
                            Get.to(() => AllOrderedItemScreen(
                                orderId: order['order_id'].toString()));
                          },
                          child: card(
                            sW,
                            sH,
                            order,
                            "customerName",
                            "customerCity",
                            "customerPhone",
                          ),
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
}

class HAppBar extends StatelessWidget {
  const HAppBar({super.key, required this.label});
  final String label;

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
        onPressed: () {},
        icon: const Icon(Icons.menu),
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
              }),
        ),
      ],
    );
  }
}
