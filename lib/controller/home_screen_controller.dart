import 'package:get/get.dart';
import 'package:rent_and_return/services/data_services.dart';

class InventoryController extends GetxController {
  final DatabaseHelper dbHelper = DatabaseHelper();

  RxList<Map<String, dynamic>> items = <Map<String, dynamic>>[].obs;
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchItems();
  }

  Future<void> fetchItems() async {
    try {
      isLoading.value = true; // Set loading to true
      final itemData = await dbHelper.getSKUs();

      if (itemData.isNotEmpty) {
        items.value = List<Map<String, dynamic>>.from(itemData);

        // Sort items by `added_date` in descending order
        items.sort((a, b) {
          DateTime dateA = DateTime.parse(a['added_date']);
          DateTime dateB = DateTime.parse(b['added_date']);
          return dateB.compareTo(dateA);
        });

        print("Fetched SKU Items: $items");
      } else {
        // items.clear();
        print("No SKU items found.");
      }
    } catch (e) {
      print("Error fetching SKU items: $e");
    } finally {
      isLoading.value = false; // Set loading to false
    }
  }
}
