import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rent_and_return/controller/add_item_controller.dart';
import 'package:rent_and_return/ui/bottom_nav_bar/inventory_screen.dart.dart';
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
                    label: "Category",
                    hint: "Category",
                    onSelectItem: (value) async {
                      controller.selectedCategory.value = value;

                      // Fetch items based on selected category
                      if (value != "Select Category") {
                        await controller.fetchItems(value);
                      }
                    },
                    onAddNewItem: (newCategory) async {
                      await controller.addCategory(newCategory);
                    },
                  ),

                  cspacingHeight(sH * 0.02),

                  // Item Name Dropdown
                  buildLabel("Item Name"),

                  // Item Dropdown
                  CustomDropdownWithTextField(
                    dataList: controller.items,
                    selectedItem: controller.selectedItem,
                    label: "Item",
                    hint: "Item",
                    onSelectItem: (value) async {
                      controller.selectedItem.value = value;

                      // Fetch sizes based on selected item
                      if (value != "Select Item") {
                        await controller.fetchSizes(value);
                      }
                    },
                    onAddNewItem: (newItem) async {
                      await controller.addItem(newItem);
                    },
                  ),
                  cspacingHeight(sH * 0.02),
                  buildLabel("Size"),

                  // Size Dropdown
                  CustomDropdownWithTextField(
                    dataList: controller.sizes,
                    selectedItem: controller.selectedSize,
                    label: "Size",
                    hint: "Size",
                    onSelectItem: (value) {
                      controller.selectedSize.value = value;
                    },
                    onAddNewItem: (newSize) async {
                      await controller.addSize(newSize);
                    },
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
                  cspacingHeight(sH * 0.02),
                  ImagePickerWidget(),
                  cspacingHeight(sH * 0.05),
                  cBtn("Add Item", () async {
                    await controller.addItemToInventory();
                    controller.debugPrintDatabase();
                    // Get.to(() =>  HomeScreen());
                  }, Colors.white),
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
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        // const SizedBox(height: 8),
      ],
    );
  }

  Widget buildTextField(TextEditingController controller) {
    return TextFormField(
      style: const TextStyle(
          fontSize: 17, fontWeight: FontWeight.w500, color: Colors.black),
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(8),
        focusedBorder: OutlineInputBorder(),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        labelStyle: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
      ),
    );
  }
}

class ImagePickerWidget extends StatelessWidget {
  final AddItemController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    double sH = MediaQuery.of(context).size.height;

    return Obx(
      () => GestureDetector(
        onTap: () => _showImageSourceDialog(context, controller),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade300,
            image: controller.pickedImage.value != null
                ? DecorationImage(
                    image: FileImage(controller.pickedImage.value!),
                    fit: BoxFit.fitHeight,
                  )
                : null,
          ),
          width: double.infinity,
          height: sH * 0.2,
          child: controller.isLoading.value
              ? Center(
                  child: CircularProgressIndicator(
                    color: Colors.black54,
                  ),
                )
              : controller.pickedImage.value == null
                  ? Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.black54,
                      size: 30,
                    )
                  : null,
        ),
      ),
    );
  }

  void _showImageSourceDialog(
      BuildContext context, AddItemController controller) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera),
              title: Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                controller.pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo),
              title: Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                controller.pickImage(ImageSource.gallery);
              },
            ),
          ],
        );
      },
    );
  }
}
