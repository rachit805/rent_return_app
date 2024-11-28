import 'package:flutter/material.dart';
import 'package:rent_and_return/utils/theme.dart';
import 'package:rent_and_return/widgets/c_para_text.dart';
import 'package:rent_and_return/widgets/c_sizedbox.dart';

Widget stockIndicator(double sW) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Row(
      children: [
        const CircleAvatar(
          backgroundColor: Color.fromARGB(255, 197, 17, 4),
          radius: 10,
        ),
        Spacing.h10,
        cText("Out of Stock", 12, FontWeight.w600),
        cspacingWidth(sW * 0.05),
        CircleAvatar(
          backgroundColor: AppTheme.theme.primaryColor,
          radius: 10,
        ),
        Spacing.h10,
        cText("In Stock", 12, FontWeight.w600),
      ],
    ),
  );
}
