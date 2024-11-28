import 'package:flutter/material.dart';
import 'package:rent_and_return/utils/theme.dart';

Widget cBtn(String label, Function() onpressed) {
  return SizedBox(
    width: double.infinity,
    height: 40,
    child: ElevatedButton(
      onPressed: onpressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.theme.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(label, style: AppTheme.theme.textTheme.labelMedium),
    ),
  );
}
