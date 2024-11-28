import 'package:flutter/material.dart';
import 'package:rent_and_return/utils/theme.dart';

Widget cbottomButton(String label, Function() onpressed) {
  return Expanded(
    child: Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
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
      ),
    ),
  );
}
