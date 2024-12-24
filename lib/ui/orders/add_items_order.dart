import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rent_and_return/controller/add_item_order_controller.dart';
import 'package:rent_and_return/ui/orders/preview_order_screen.dart';
import 'package:rent_and_return/utils/theme.dart';
import 'package:rent_and_return/widgets/c_bottom_button.dart';
// import 'package:rent_and_return/widgets/c_search_bar.dart';
import 'package:rent_and_return/widgets/c_sizedbox.dart';

class AddItemInOrderScreen extends StatelessWidget {
  AddItemInOrderScreen({super.key, required this.cname, required this.mob});
  final AddItemOrderController controller = Get.put(AddItemOrderController());
  final String cname;
  final String mob;
  Future<void> refreshData() async {
    // Clear selected data
    controller.selectedCategory.value = '';
    controller.selectedItem.value = '';
    controller.selectedSize.value = '';

    // Clear input fields
    controller.quantityController.clear();
    controller.priceController.clear();
    controller.rentpriceController.clear();
    controller.deliverydateController.clear();

    // Reset current item index
    // controller.currentItemIndex.value = 0;

    // Clear dropdown lists
    // controller.categories.clear();
    // controller.items.clear();
    // controller.sizes.clear();

    // Re-fetch categories
    await controller.fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    print("CATEGORIES IN UI:${controller.categories}");
    double sH = MediaQuery.of(context).size.height;
    double sW = MediaQuery.of(context).size.width;
    final String selectedSKUName =
        "${controller.selectedCategory}_${controller.selectedItem}_${controller.selectedSize}";
    print("SLECTEDSKUNAME:::: $selectedSKUName");
    controller.fetchSKUData();
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        automaticallyImplyLeading: true,
        backgroundColor: AppTheme.theme.scaffoldBackgroundColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              cname,
              style: AppTheme.theme.textTheme.bodySmall
                  ?.copyWith(color: Colors.black),
            ),
            Text(
              mob,
              style: AppTheme.theme.textTheme.bodySmall
                  ?.copyWith(color: Colors.black),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(10),
          child: Divider(
            thickness: 2,
            color: Colors.grey.shade300,
          ),
        ),
      ),
      body: RefreshIndicator(
        displacement: 40,
        color: AppTheme.theme.primaryColor,
        onRefresh: refreshData,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // Padding(
              //   padding: const EdgeInsets.symmetric(vertical: 15),
              //   child: csearchbar(sW, "Search item"),
              // ),
              cspacingHeight(sH * 0.03),
              Expanded(
                flex: 7,
                child: ListView(
                  children: [
                    // Category Dropdown
                    Obx(() => CDropDown(
                          selectedValue: controller.selectedCategory.value,
                          hintText: 'Select category',
                          list: controller.categories,
                          onChanged: (String? value) {
                            if (value != null) {
                              controller.selectedCategory.value = value;
                              controller.fetchItems(value);
                            }
                          },
                          textStyle:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.black,
                                  ),
                          underlineColor: Colors.black87,
                        )),

                    cspacingHeight(sH * 0.02),

                    // Item Dropdown
                    Obx(() => CDropDown(
                          selectedValue: controller.selectedItem.value,
                          hintText: 'Select item',
                          list: controller.items,
                          onChanged: (String? value) {
                            if (value != null) {
                              controller.selectedItem.value = value;
                              controller.fetchSizes(
                                  value); // Fetch sizes for selected item
                            }
                          },
                          textStyle:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.black,
                                  ),
                          underlineColor: Colors.black87,
                        )),

                    cspacingHeight(sH * 0.02),

                    // Size Dropdown
                    Obx(() => CDropDown(
                          selectedValue: controller.selectedSize.value,
                          hintText: 'Select size',
                          list: controller.sizes,
                          onChanged: (String? value) {
                            if (value != null) {
                              controller.selectedSize.value =
                                  value; // Update selected size
                              controller
                                  .fetchSKUData(); // Fetch SKU data dynamically
                            }
                          },
                          textStyle:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.black,
                                  ),
                          underlineColor: Colors.black87,
                        )),

                    buildQtyTextField(
                      controller.quantityController,
                      "Quantity",
                      'Enter Quantity',
                      false,
                      (input) {
                        final enteredQty = int.tryParse(input) ?? 0;

                        final remainingQty =
                            controller.availableQty.value - enteredQty;

                        controller.remainingQty.value = remainingQty;
                        return "Remaining Qty: ${controller.remainingQty.value}";
                      },
                    ),

                    buildTextField(controller.priceController,
                        "Price (per item)", '', true, ''),
                    const Text(
                      "In-Case if items are Lost Consumers are Solely Responsible for refunds.",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 10,
                      ),
                    ),
                    buildTextField(controller.rentpriceController, "Rent Price",
                        '', true, ''),
                    buildDatePickerField(controller.deliverydateController,
                        "Delivery date", context),
                    cspacingHeight(sH * 0.05),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              controller.previousItem();
                            },
                            child: Obx(
                              () => Container(
                                width: sW * 0.35,
                                height: 50,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color:
                                          controller.currentItemIndex.value == 0
                                              ? AppTheme.theme.primaryColor
                                                  .withOpacity(0.3)
                                              : AppTheme.theme.primaryColor),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    "Previous Item",
                                    style: AppTheme.theme.textTheme.bodySmall
                                        ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                            color: controller.currentItemIndex
                                                        .value ==
                                                    0
                                                ? AppTheme.theme.primaryColor
                                                    .withOpacity(0.3)
                                                : AppTheme.theme.primaryColor),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              controller.nextItem();
                            },
                            child: Container(
                              width: sW * 0.35,
                              height: 50,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: AppTheme.theme.primaryColor),
                                  borderRadius: BorderRadius.circular(10),
                                  color: AppTheme.theme.primaryColor),
                              child: Center(
                                child: Text(
                                  "Next Item",
                                  style: AppTheme.theme.textTheme.bodySmall
                                      ?.copyWith(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              cbottomButton("Preview Order", () {
                controller.previewOrder();
              }, AppTheme.theme.scaffoldBackgroundColor),
            ],
          ),
        ),
      ),

      // bottomNavigationBar: cbottomButton("Preview Order", () {
      //   Get.to(() => PreviewOrderScreen());
      // }, AppTheme.theme.scaffoldBackgroundColor),
    );
  }

  Widget buildTextField(TextEditingController controller, String label,
      String? hintText, bool readOnly, String? aQty) {
    return TextFormField(
      controller: controller,
      autofocus: false,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelStyle: AppTheme.theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w500, color: Colors.black, fontSize: 15),
        labelText: label,
        hintText: hintText,
        suffix: Text(aQty ?? ''),
        enabledBorder: const UnderlineInputBorder(),
      ),
    );
  }

  ///
  Widget buildQtyTextField(
    TextEditingController controller,
    String label,
    String? hintText,
    bool readOnly,
    String? Function(String)
        getSuffixText, // A function to dynamically generate the suffix
  ) {
    return TextFormField(
      controller: controller,
      autofocus: false,
      readOnly: readOnly,
      onChanged: (value) {
        // Trigger the state update on change
        getSuffixText(value);
      },
      decoration: InputDecoration(
        labelStyle: AppTheme.theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w500, color: Colors.black, fontSize: 15),
        labelText: label,
        hintText: hintText,
        suffix: Obx(() => Text("${getSuffixText(controller.text)}")),
        enabledBorder: const UnderlineInputBorder(),
      ),
    );
  }

  Widget buildDatePickerField(
      TextEditingController controller, String label, BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true, // Prevents manual input
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTheme.theme.textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: Colors.black,
          fontSize: 15,
        ),
        hintText: 'DD/MM/YYYY',
        hintStyle: AppTheme.theme.textTheme.bodySmall
            ?.copyWith(color: Colors.grey), // Added a hint style for clarity
        suffixIcon: const Icon(
          Icons.calendar_today, // More intuitive icon
          color: Colors.black,
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey), // Styled underline
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black), // Styled focus state
        ),
      ),
      onTap: () async {
        FocusScope.of(context).unfocus(); // Ensures the keyboard is dismissed
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          builder: (BuildContext context, Widget? child) {
            return Theme(
              data: AppTheme.theme.copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Colors.black, // Header background color
                  onPrimary: Colors.white, // Header text color
                  onSurface: Colors.black, // Body text color
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black, // Button text color
                  ),
                ),
              ),
              child: child ?? const SizedBox(),
            );
          },
        );
        if (pickedDate != null) {
          controller.text = "${pickedDate.day.toString().padLeft(2, '0')}/"
              "${pickedDate.month.toString().padLeft(2, '0')}/"
              "${pickedDate.year}";
        }
      },
    );
  }
}

class CDropDown extends StatefulWidget {
  const CDropDown({
    super.key,
    required this.selectedValue,
    required this.hintText,
    required this.list,
    required this.onChanged,
    this.textStyle,
    this.underlineColor = Colors.black87,
  });

  final String? selectedValue;
  final String hintText;
  final List<String> list;
  final ValueChanged<String?> onChanged;
  final TextStyle? textStyle;
  final Color underlineColor;

  @override
  State<CDropDown> createState() => _CDropDownState();
}

class _CDropDownState extends State<CDropDown> {
  @override
  Widget build(BuildContext context) {
    final String? selectedValue = widget.selectedValue;
    final TextStyle? textStyle =
        widget.textStyle ?? Theme.of(context).textTheme.bodyMedium;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: DropdownButton<String>(
        isExpanded: true,
        isDense: true,
        underline: Divider(
          thickness: 1,
          color: widget.underlineColor,
        ),
        value: widget.list.contains(selectedValue) ? selectedValue : null,
        hint: Text(
          widget.hintText,
          style: textStyle?.copyWith(color: Colors.grey),
        ),
        items: widget.list.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: textStyle,
            ),
          );
        }).toList(),
        onChanged: widget.onChanged,
      ),
    );
  }
}
