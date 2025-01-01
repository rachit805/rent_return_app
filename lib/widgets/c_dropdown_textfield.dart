import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rent_and_return/utils/theme.dart';

class CustomDropdownWithTextField extends StatefulWidget {
  final dataList; // Use RxList for real-time updates
  final selectedItem;
  final Function(String)? onAddNewItem;
  final Function(String) onSelectItem;
  final String label;
  final String hint;

  const CustomDropdownWithTextField({
    required this.dataList,
    required this.selectedItem,
    this.onAddNewItem,
    required this.onSelectItem,
    super.key,
    required this.label,
    required this.hint,
  });

  @override
  _CustomDropdownWithTextFieldState createState() =>
      _CustomDropdownWithTextFieldState();
}

class _CustomDropdownWithTextFieldState
    extends State<CustomDropdownWithTextField> {
  String toCamelCase(String input) {
    return input
        .split(' ')
        .map((word) => word.isEmpty
            ? word
            : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join('');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PopupMenuButton<String>(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width,
          ),
          elevation: 2,
          color: AppTheme.theme.scaffoldBackgroundColor,
          onSelected: (value) {
            widget.onSelectItem(value);
            widget.selectedItem.value = value;
          },
          itemBuilder: (BuildContext context) {
            return [
              ...widget.dataList.map((String item) {
                return PopupMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }).toList(),
              PopupMenuItem<String>(
                height: 100,
                enabled: false,
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: TextFormField(
                          autofocus: true,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 2),
                            labelText: "Add New ${widget.label}",
                            labelStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.theme.primaryColor,
                            ),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: AppTheme.theme.primaryColor,
                              ),
                            ),
                          ),
                          onFieldSubmitted: (value) {
                            if (value.isNotEmpty) {
                              final camelCaseValue = toCamelCase(value);

                              widget.onAddNewItem!(camelCaseValue);
                              widget.selectedItem.value = camelCaseValue;
                              Navigator.pop(context); // Close the dropdown
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ];
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black54),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.selectedItem.value.isEmpty
                      ? "Select ${widget.hint}"
                      : widget.selectedItem.value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
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
      ],
    );
  }
}
