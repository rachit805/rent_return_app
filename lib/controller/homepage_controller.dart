import 'package:get/get.dart';
import 'package:rent_and_return/controller/home_screen_controller.dart';

class HomePageController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    final HomeController homeController = Get.put(HomeController());
  }

  var selectedIndex = 0.obs;
  void onItemTapped(int index) {
    selectedIndex.value = index;
  }
}
