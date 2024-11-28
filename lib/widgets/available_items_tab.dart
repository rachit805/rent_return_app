import 'package:flutter/material.dart';
import 'package:rent_and_return/utils/strings.dart';
import 'package:rent_and_return/utils/theme.dart';

final List<String> categories = [
  "All",
  "Jars",
  "Spoons",
  "Vessels",
  "Plates",
  "Glasses",
  "Fans",
  "Chairs"
];

class AvailableItemsTab extends StatefulWidget {
  @override
  _AvailableItemsTabState createState() => _AvailableItemsTabState();
}

class _AvailableItemsTabState extends State<AvailableItemsTab> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color:
                    selectedIndex == index ? primary2Color : Colors.transparent,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: selectedIndex == index
                      ? AppTheme.theme.primaryColor
                      : Colors.black,
                ),
              ),
              height: 40,
              width: 90,
              alignment: Alignment.center,
              child: Text(
                categories[index],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: selectedIndex == index ? Colors.white : Colors.black,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
