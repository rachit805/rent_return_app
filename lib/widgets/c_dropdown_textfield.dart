import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rent_and_return/utils/theme.dart';

class CustomDropdownWithTextField extends StatelessWidget {
  final List<String> dataList;
  final RxString selectedItem;
  final Function(String)? onAddNewItem;
  final Function(String) onSelectItem;
  final String label;
  const CustomDropdownWithTextField({
    required this.dataList,
    required this.selectedItem,
    this.onAddNewItem,
    required this.onSelectItem,
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    String toCamelCase(String input) {
      return input
          .split(' ')
          .map((word) => word.isEmpty
              ? word
              : word[0].toUpperCase() + word.substring(1).toLowerCase())
          .join(' ');
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => PopupMenuButton<String>(
              color: AppTheme.theme.scaffoldBackgroundColor,
              onSelected: (value) {
                onSelectItem(value);
                selectedItem.value =
                    value; // Update selected item when an option is selected
              },
              itemBuilder: (BuildContext context) {
                return [
                  ...dataList.map((String item) {
                    return PopupMenuItem<String>(
                      value: item,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  PopupMenuItem<String>(
                    height: 100,
                    enabled: false,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: TextFormField(
                                autofocus: true,
                                keyboardType: TextInputType.text,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(3),
                                  labelText: "Add new item",
                                  labelStyle: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w300,
                                  ),
                                  border: OutlineInputBorder(),
                                ),
                                onFieldSubmitted: (value) {
                                  if (value.isNotEmpty) {
                                    // Convert input to camel case
                                    final camelCaseValue = toCamelCase(value);

                                    onAddNewItem!(camelCaseValue);
                                    selectedItem.value =
                                        camelCaseValue; // Set the camel case value as selected
                                    Navigator.pop(
                                        context); // Close the dropdown
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black54),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedItem.value.isEmpty
                          ? "Select $label"
                          : selectedItem.value,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.black,
                      size: 30,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
