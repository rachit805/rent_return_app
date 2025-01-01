import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:rent_and_return/controller/home_screen_controller.dart';
import 'package:rent_and_return/controller/homepage_controller.dart';
import 'package:rent_and_return/controller/orders_controller/all_order_controller.dart';
import 'package:rent_and_return/ui/bottom_nav_bar/dashboard_screen.dart';
import 'package:rent_and_return/ui/bottom_nav_bar/inventory_screen.dart.dart';
import 'package:rent_and_return/ui/bottom_nav_bar/profile_screen.dart';
import 'package:rent_and_return/ui/orders/all_orders_screen.dart';
import 'package:rent_and_return/utils/theme.dart';

class Homepage extends StatelessWidget {
  final int initialPage;

  Homepage({
    Key? key,
    required this.initialPage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Pass `initialPage` dynamically to the controller
    final HomePageController controller = Get.put(
      HomePageController(initialPage: initialPage),
    );

    List<Widget> screens = [
      DashboardScreen(),
      GetBuilder<AllOrderController>(
        init: AllOrderController(), // Lazy initialization
        builder: (_) => AllOrdersScreen(),
      ),
      GetBuilder<InventoryController>(
        init: InventoryController(), // Lazy initialization
        builder: (_) => InventoryScreen(),
      ),
      ProfileScreen(),
    ];

    return WillPopScope(
      onWillPop: () async {
        // Confirmation dialog for exiting the app
        final shouldClose = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Exit App"),
            content: const Text("Do you want to close the app?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("No"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Yes"),
              ),
            ],
          ),
        );

        return shouldClose ?? false;
      },
      child: Obx(
        () => Scaffold(
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: controller.selectedIndex.value,
            onTap: controller.onItemTapped,
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: true,
            backgroundColor: AppTheme.theme.primaryColor,
            showUnselectedLabels: true,
            selectedItemColor: Colors.black,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_bag),
                label: "Orders",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.inventory),
                label: "Inventory",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: "Profile",
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(child: screens[controller.selectedIndex.value]),
              Obx(() {
                if (controller.isBannerAdLoaded.value &&
                    controller.bannerAd != null) {
                  return Container(
                    alignment: Alignment.bottomCenter,
                    width: controller.bannerAd!.size.width.toDouble(),
                    height: controller.bannerAd!.size.height.toDouble(),
                    child: AdWidget(ad: controller.bannerAd!),
                  );
                } else {
                  return const SizedBox();
                }
              }),
            ],
          ),
        ),
      ),
    );
  }
}
