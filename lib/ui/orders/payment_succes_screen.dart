import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rent_and_return/controller/order_reciept_controller.dart';
import 'package:rent_and_return/ui/bottom_nav_bar/homepage.dart';
import 'package:rent_and_return/ui/bottom_nav_bar/inventory_screen.dart.dart';
import 'package:rent_and_return/ui/orders/order_receipt_screen.dart';
import 'package:rent_and_return/utils/theme.dart';
import 'package:rent_and_return/widgets/c_appbar2.dart';
import 'package:rent_and_return/widgets/c_border_btn.dart';
import 'package:rent_and_return/widgets/c_btn.dart';
import 'package:rent_and_return/widgets/c_sizedbox.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final Map<String, dynamic> orderSummary;

  PaymentSuccessScreen({Key? key, required this.orderSummary})
      : super(key: key);
  final OrderReceiptController controller = Get.put(OrderReceiptController());

  @override
  Widget build(BuildContext context) {
    controller.loadRewardedAd();
    double sH = MediaQuery.of(context).size.height;
    double sW = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        Get.offAll(
            () => Homepage(
                  initialPage: 1,
                ),
            arguments: {"initialPage": 1});
        return false; // Prevent default back navigation
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: cAppbar2("Payment Successful", () {
            // Same behavior as the back button
            Get.offAll(
              () => Homepage(
                initialPage: 1,
              ),
            );
          }),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              cspacingHeight(sH * 0.1),
              CircleAvatar(
                backgroundColor: Colors.green.shade700,
                radius: 30,
                child: const Icon(
                  Icons.done,
                  weight: 30,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              Center(
                child: Text(
                  "Payment Successful",
                  style: AppTheme.theme.textTheme.labelMedium,
                ),
              ),
              const Text("Transcation ID: 12345678"),
              cspacingHeight(sH * 0.05),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(
                  color: Colors.grey,
                  thickness: 1.5,
                ),
              ),
              cspacingHeight(sH * 0.05),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Amount Paid in Advance"),
                  Text(
                      orderSummary['advance_amount'] is double
                          ? '₹ ${orderSummary['advance_amount']!.toInt()}/-'
                          : '₹ ${orderSummary['advance_amount']?.toString() ?? 'N/A'}/-',
                      style: AppTheme.theme.textTheme.bodySmall),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(
                  color: Colors.grey,
                  thickness: 1.5,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Remaining Amount"),
                  Text(
                    orderSummary['pending_amount'] is double
                        ? '₹ ${orderSummary['pending_amount']!.toInt()}/-'
                        : '₹ ${orderSummary['pending_amount']?.toString() ?? 'N/A'}/-',
                    style: AppTheme.theme.textTheme.bodySmall,
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(
                  color: Colors.grey,
                  thickness: 1.5,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Transaction Date"),
                  Text(orderSummary['transcation_date_time'] ?? '',
                      style: AppTheme.theme.textTheme.bodySmall)
                ],
              ),
              cspacingHeight(sH * 0.16),
              cBorderBtn("View Receipt", () {
                controller.showRewardedAd();
              }),
              Spacing.v15,
              Spacing.v10,
              cBtn("Print Receipt", () {
                controller.generatePdf(controller.orderedData);
              }, Colors.white)
            ],
          ),
        ),
      ),
    );
  }
}
