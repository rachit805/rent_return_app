import 'package:flutter/material.dart';
import 'package:rent_and_return/utils/theme.dart';
import 'package:rent_and_return/widgets/c_appbar.dart';

Widget actionBtn(Function() onPressed, String label) {
  return Padding(
    padding: const EdgeInsets.only(right: 15),
    child: IconButtonWithLabel(
        icon: Icons.add,
        label: label,
        textColor: AppTheme.theme.scaffoldBackgroundColor,
        onPressed: onPressed),
  );
}
