import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rent_and_return/utils/theme.dart';

Widget cAppbar2(String label, Function() onTap) {
  return AppBar(
    centerTitle: false,
    backgroundColor: AppTheme.theme.scaffoldBackgroundColor,
    automaticallyImplyLeading: false,
    leading: InkWell(
      onTap: onTap,
      child: const Icon(Icons.close, size: 24, weight: 60, color: Colors.black),
    ),
    title: Text(
      label,
      style: const TextStyle(color: Colors.black),
    ),
    bottom: const PreferredSize(
      preferredSize: Size.fromHeight(15),
      child: Divider(),
    ),
  );
}
