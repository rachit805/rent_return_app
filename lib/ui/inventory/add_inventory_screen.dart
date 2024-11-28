import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rent_and_return/controller/add_item_controller.dart';
import 'package:rent_and_return/ui/inventory/home_screen.dart';
import 'package:rent_and_return/utils/theme.dart';
import 'package:rent_and_return/widgets/c_appbar.dart';
import 'package:rent_and_return/widgets/c_btn.dart';
import 'package:rent_and_return/widgets/c_dropdown_textfield.dart';
import 'package:rent_and_return/widgets/c_sizedbox.dart';

class AddInventoryScreen extends StatelessWidget {
  final AddItemController controller = Get.put(AddItemController());

  AddInventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double sH = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: const PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: CAppbar(
            title: "Add Inventory",
            leading: true,
          )),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  cspacingHeight(sH * 0.04),

                  // Category Dropdown
                  buildLabel("Category"),
                  CustomDropdownWithTextField(
                    dataList: controller.categories,
                    selectedItem: controller.selectedCategory,
                    onAddNewItem: controller.addCategory,
                    onSelectItem: controller.selectedCategory,
                  ),
                  cspacingHeight(sH * 0.02),

                  // Item Name Dropdown
                  buildLabel("Item Name"),
                  CustomDropdownWithTextField(
                    dataList: controller.items,
                    selectedItem: controller.selectedItem,
                    onAddNewItem: controller.addItem,
                    onSelectItem: controller.selectedItem,
                  ),
                  cspacingHeight(sH * 0.02),

                  // Size Dropdown
                  buildLabel("Size"),
                  CustomDropdownWithTextField(
                    dataList: controller.sizes,
                    selectedItem: controller.selectedSize,
                    onAddNewItem: controller.addSize,
                    onSelectItem: controller.selectedSize,
                  ),
                  cspacingHeight(sH * 0.02),

                  // Quantity
                  buildLabel("Quantity"),
                  buildTextField(controller.quantityController),
                  cspacingHeight(sH * 0.02),

                  // Purchase Price
                  buildLabel("Purchase Price (per item)"),
                  buildTextField(controller.purchasePriceController),
                  cspacingHeight(sH * 0.02),

                  // Rent Price
                  buildLabel("Rent Price (per item)"),
                  buildTextField(controller.rentPriceController),
                  cspacingHeight(sH * 0.05),

                  cBtn("Add Item", () async {
                    await controller.addItemToInventory();
                    controller.debugPrintDatabase();
                    // Get.to(() =>  HomeScreen());
                  }),
                  Spacing.v20,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildLabel(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget buildTextField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.all(8),
        border: OutlineInputBorder(),
      ),
    );
  }
}
