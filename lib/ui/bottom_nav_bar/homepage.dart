import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rent_and_return/controller/home_screen_controller.dart';
import 'package:rent_and_return/controller/homepage_controller.dart';
import 'package:rent_and_return/ui/inventory/home_screen.dart';
import 'package:rent_and_return/ui/bottom_nav_bar/orders_screen.dart';
import 'package:rent_and_return/ui/bottom_nav_bar/profile_screen.dart';
import 'package:rent_and_return/ui/inventory/add_inventory_screen.dart';
import 'package:rent_and_return/ui/orders/all_orders_screen.dart';
import 'package:rent_and_return/utils/strings.dart';

class Homepage extends StatelessWidget {
  Homepage({super.key});
  List<Widget> screens = [
    const HomeScreen(),
    const AllOrdersScreen(),
    AddInventoryScreen(),
    const ProfileScreen(),
  ];
  final HomeController homeController =
      Get.put(HomeController(), permanent: true);
  final HomePageController controller = Get.put(HomePageController());

  @override
  Widget build(BuildContext context) {                          
    return WillPopScope(
      onWillPop: () async {
        // Show the confirmation dialog
        final shouldClose = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Exit App"),
              content: const Text("Do you want to close the app?"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // Close dialog, no exit
                  },
                  child: const Text("No"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // Close dialog, exit app
                  },
                  child: const Text("Yes"),
                ),
              ],
            );
          },
        );

        return shouldClose ?? false; // If null (dialog dismissed), don't exit
      },
      child: Obx(
        () => Scaffold(
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: primary2Color,
            currentIndex: controller.selectedIndex.value,
            iconSize: 25,
            onTap: controller.onItemTapped,
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: true,
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
          body: screens[controller.selectedIndex.value],
        ),
      ),
    );
  }
}
