import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rent_and_return/utils/strings.dart';

void showErrorSnackbar(title, message) {
  Get.snackbar(
    title, message,
    backgroundColor: errorColor,
    colorText: Colors.white,
    snackPosition: SnackPosition.TOP , // Optional: Snack bar position
    duration: const Duration(
        seconds: 2), // Optional: Duration for snack bar to display
  );
}
