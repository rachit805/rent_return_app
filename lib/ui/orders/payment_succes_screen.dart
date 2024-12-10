import 'package:flutter/material.dart';
import 'package:rent_and_return/utils/theme.dart';
import 'package:rent_and_return/widgets/c_appbar2.dart';
import 'package:rent_and_return/widgets/c_border_btn.dart';
import 'package:rent_and_return/widgets/c_btn.dart';
import 'package:rent_and_return/widgets/c_sizedbox.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double sH = MediaQuery.of(context).size.height;
    double sW = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: cAppbar2("Payment Successful")),
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
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text("Amount Paid in Advance"), Text("3000")],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(
                color: Colors.grey,
                thickness: 1.5,
              ),
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text("Remaining Amount"), Text("3000")],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(
                color: Colors.grey,
                thickness: 1.5,
              ),
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Transaction Date"),
                Text("22/10/2024, 03:30 PM")
              ],
            ),
            cspacingHeight(sH * 0.16),
            cBorderBtn("View Receipt"),
            Spacing.v15,
            Spacing.v10,
            cBtn("Print Receipt", () => null, Colors.white)
          ],
        ),
      ),
    );
  }
}
