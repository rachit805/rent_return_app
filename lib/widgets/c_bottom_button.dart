import 'package:flutter/material.dart';
import 'package:rent_and_return/utils/theme.dart';
// import 'package:rent_and_return/widgets/c_sizedbox.dart';

Widget cbottomButton(String label, Function() onpressed, Color labelColor) {
  return Expanded(
    child: Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
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
            child: Text(label,
                style: AppTheme.theme.textTheme.labelMedium
                    ?.copyWith(color: labelColor)),
          ),
        ),
      ),
    ),
  );
}
