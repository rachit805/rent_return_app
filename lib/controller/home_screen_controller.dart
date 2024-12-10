import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:rent_and_return/controller/item_detail_controller.dart';
import 'package:rent_and_return/services/data_services.dart';

class HomeController extends GetxController {
  final DatabaseHelper dbHelper = DatabaseHelper();

  RxList<Map<String, dynamic>> items = <Map<String, dynamic>>[].obs;
  final ItemDetailController itemDetailController =
      Get.put(ItemDetailController());
  @override
  void onInit() {
    super.onInit();
    fetchItems();
    items.refresh();
    itemDetailController.masterListData.refresh();
    

  }

  Future<void> fetchItems() async {
    try {
      final itemData = await dbHelper.getSKUs();
      if (itemData.isNotEmpty) {
        items.value = List<Map<String, dynamic>>.from(itemData);

        // Sort items by `create_date` in descending order
        items.sort((a, b) {
          DateTime dateA = DateTime.parse(a['added_date']);
          DateTime dateB = DateTime.parse(b['added_date']);
          return dateB.compareTo(dateA); // Descending order
        });

        print("Fetched SKU Items: $items");
        print("ITEMS LENGTH IN CONTROLLER: ${items.length}");
      } else {
        items.clear();
        print("No SKU items found.");
      }
    } catch (e) {
      print("Error fetching SKU items: $e");
    }
  }
}
