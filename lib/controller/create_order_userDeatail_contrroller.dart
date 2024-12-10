import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:rent_and_return/controller/add_item_order_controller.dart';
import 'package:rent_and_return/services/data_services.dart';
import 'package:rent_and_return/ui/orders/add_items_order.dart';
import 'package:rent_and_return/widgets/error_snackbar.dart';

class CreateOrderController extends GetxController {
  final mobController = TextEditingController();
  final aMobController = TextEditingController();
  final cNameController = TextEditingController();
  final idNumController = TextEditingController();
  final addressController = TextEditingController();
  final refNameController = TextEditingController();
  final refMobController = TextEditingController();
  final deliveryDateController = TextEditingController();
  final returnDateController = TextEditingController();
  final newAddressController = TextEditingController();
  final advanceAmountController = TextEditingController();
  
  DatabaseHelper dbHelper = DatabaseHelper();
  // RxMap customerData = <String, dynamic>{}.obs;
  final idCard = [
    'ID Card',
    "Aadhar Card",
    "Pan Card",
    'Voter ID',
    "Driving Licence"
  ];

  var selectedCard = ''.obs;
  void addUserData() async {
    if (mobController.text.isEmpty ||
        cNameController.text.isEmpty ||
        addressController.text.isEmpty ||
        selectedCard == null ||
        idNumController.text.isEmpty) {
      showErrorSnackbar(
          "Error", "Please fill all required fields before selecting a date");
      return;
    }

    Map<String, dynamic> customerData = {
      'customer_name': cNameController.text,
      'mob_number': mobController.text,
      'alternative_mob_number': aMobController.text,
      'id_card': selectedCard.value,
      'id_number': idNumController.text,
      'address': addressController.text,
      'ref_name': refNameController.text,
      'ref_number': refMobController.text,
    };

    // Insert and get the result
    Map<String, dynamic> result =
        await dbHelper.insertCustomerAndReturnDetails(customerData);

    print(result);
    final AddItemOrderController addItemInOrderController =
        Get.put(AddItemOrderController());
    addItemInOrderController.setCustomerData(customerData);
    showSuccessSnackbar("Added", "Customer data saved succesfully!");
    Get.to(() => AddItemInOrderScreen(
        cname: cNameController.text, mob: mobController.text));
    dbHelper.getAllCustomersData();
  }

  void selectIdCard(String card) {
    selectedCard.value = card;
  }

  void pickDate(TextEditingController controller, BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      controller.text =
          "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      update(); // Notify listeners about the update
    }
  }
}
