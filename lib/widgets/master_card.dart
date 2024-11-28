import 'package:flutter/material.dart';

Widget masterCard({
  required String categoryName,
  required String itemName,
  required int quantity,
  required double rentPrice,
  required double sH,
  required double sW,
  required String size,
  required double buyPrice,
}) {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade400, width: 1.5),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoryName,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: sH * 0.01),
                Text(
                  itemName,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: sH * 0.01),
                Text(
                  "Size: $size",
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // Spacer
          SizedBox(width: sW * 0.04),

          // Right Column
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Buy Price: ₹${buyPrice.toStringAsFixed(1)}/-",
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: sH * 0.01),
                Text(
                  "Rent Price: ${rentPrice.toStringAsFixed(1)}/-",
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: sH * 0.01),
                Text(
                  "Total Qty: ${quantity.toStringAsFixed(0)} pieces",
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
