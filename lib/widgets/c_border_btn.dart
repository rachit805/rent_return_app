import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rent_and_return/utils/theme.dart';

Widget cBorderBtn(String label, Function() onTap) {
  return InkWell(
    onTap: onTap,
    child: Container(
      height: 45,
      decoration: BoxDecoration(
          border: Border.all(
            color: AppTheme.theme.primaryColor,
          ),
          borderRadius: BorderRadius.circular(8)),
      child: Center(
          child: Text(
        label,
        style: AppTheme.theme.textTheme.bodySmall
            ?.copyWith(fontWeight: FontWeight.w600),
      )),
    ),
  );
}
