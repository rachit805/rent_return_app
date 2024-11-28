import 'package:flutter/material.dart';
import 'package:rent_and_return/widgets/c_para_text.dart';
import 'package:rent_and_return/widgets/c_sizedbox.dart';

class Cdropdown extends StatefulWidget {
  const Cdropdown({super.key});

  @override
  _CdropdownState createState() => _CdropdownState();
}

class _CdropdownState extends State<Cdropdown> {
  // Categories list (removed "All" and added "Select" as the default option)
  final List<String> categories = [
    "Select",
    "Jars",
    "Spoons",
    "Vessels",
    "Plates",
    "Glasses",
    "Fans",
    "Chairs",
  ];

  // Map of items for each category
  final Map<String, List<String>> itemsForCategory = {
    "Select": [],
    "Jars": ["Small Jar", "Medium Jar", "Large Jar"],
    "Spoons": [
      "Table Spoons",
      "Tea Spoons",
      "Soup Spoons",
      "Dessert Spoons",
      "Serving Spoons"
    ],
    "Vessels": ["Cooking Pot", "Pressure Cooker", "Frying Pan"],
    "Plates": ["Dinner Plate", "Dessert Plate", "Soup Plate"],
    "Glasses": ["Water Glass", "Wine Glass", "Juice Glass"],
    "Fans": ["Ceiling Fan", "Table Fan", "Pedestal Fan"],
    "Chairs": ["Dining Chair", "Office Chair", "Rocking Chair"],
  };

  // Sizes for the size dropdown
  List<String> sizes = [
    "Select Size",
    "12",
    "14",
    "16",
    "18",
    "20",
    "22",
  ];

  // Selected category, item, and size
  String? selectedCategory = "Select"; // Default selected category is "Select"
  String? selectedItem; // Default selected item (depends on category)
  String? selectedSize = "Select Size"; // Default size
  // void _printSelectedValues() {
  //   print("Selected Category: $selectedCategory");
  //   print("Selected Item: $selectedItem");
  //   print("Selected Size: $selectedSize");
  // }

  // @override
  // void initState() {
  //   // _printSelectedValues();
  //   // TODO: implement initState
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    // Get the items list based on selected category
    List<String> items = itemsForCategory[selectedCategory!] ?? [];
    double sH = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Dropdown
        cText("Category", 16, FontWeight.w500),
        DropdownButton<String>(
          underline: const SizedBox(
            height: 10,
            child: Divider(
              thickness: 1,
              color: Colors.black54,
            ),
          ),
          value: selectedCategory,
          icon: const Icon(
            Icons.arrow_drop_down,
            color: Colors.black,
            size: 40,
          ),
          isExpanded: true,
          onChanged: (String? newValue) {
            setState(() {
              selectedCategory = newValue;
              // Reset the selected item and size when the category changes
              selectedItem = null;
              selectedSize = "Select Size";
            });
          },
          items: categories.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w700),
              ),
            );
          }).toList(),
          dropdownColor: Colors.white,
        ),
        cspacingHeight(sH * 0.02),

        // Item Dropdown
        cText("Item Name", 16, FontWeight.w500),
        DropdownButton<String>(
          underline: const SizedBox(
            height: 10,
            child: Divider(
              thickness: 1,
              color: Colors.black54,
            ),
          ),
          value: selectedItem,
          icon: const Icon(
            Icons.arrow_drop_down,
            color: Colors.black,
            size: 40,
          ),
          isExpanded: true,
          onChanged: (String? newValue) {
            setState(() {
              selectedItem = newValue;
              // Reset the size when the item changes
              selectedSize = "Select Size";
            });
          },
          // Only show the second dropdown if there are items for the selected category
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w700),
              ),
            );
          }).toList(),
          dropdownColor: Colors.white,
          hint: Text(
            selectedCategory == "Select"
                ? "First Select Category"
                : "Select item",
            style: const TextStyle(fontSize: 16),
          ),
        ),
        cspacingHeight(sH * 0.02),

        // Size Dropdown
        cText("Size", 16, FontWeight.w500),
        DropdownButton<String>(
          underline: const SizedBox(
            height: 10,
            child: Divider(
              thickness: 1,
              color: Colors.black54,
            ),
          ),
          value: selectedSize,
          icon: const Icon(
            Icons.arrow_drop_down,
            color: Colors.black,
            size: 40,
          ),
          isExpanded: true,
          onChanged: (String? newValue) {
            setState(() {
              selectedSize = newValue;
            });
          },
          items: sizes.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w700),
              ),
            );
          }).toList(),
          dropdownColor: Colors.white,
        ),
      ],
    );
  }
}
