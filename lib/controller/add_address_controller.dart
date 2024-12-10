import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddAddressController extends GetxController {
  final advanceAmountController = TextEditingController();
  final RxDouble remainingAmount = 0.0.obs;
  final RxDouble totalAmount;
  final FocusNode advanceAmountFocusNode = FocusNode();

  AddAddressController({required double totalAmountValue})
      : totalAmount = totalAmountValue.obs;

  void calculateRemainingAmount() {
    final advanceAmount = double.tryParse(advanceAmountController.text) ?? 0.0;
    remainingAmount.value = totalAmount.value - advanceAmount;
  }

  @override
  void onInit() {
    super.onInit();

    advanceAmountController.addListener(() {
      calculateRemainingAmount();
    });

    advanceAmountFocusNode.addListener(() {
      if (!advanceAmountFocusNode.hasFocus) {
        calculateRemainingAmount();
      }
    });
  }

  @override
  void onClose() {
    advanceAmountController.dispose();
    advanceAmountFocusNode.dispose();
    super.onClose();
  }
}
