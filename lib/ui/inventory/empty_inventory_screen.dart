import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rent_and_return/ui/inventory/add_inventory_screen.dart';
import 'package:rent_and_return/utils/strings.dart';
import 'package:rent_and_return/utils/theme.dart';
import 'package:rent_and_return/widgets/c_bottom_button.dart';
import 'package:rent_and_return/widgets/c_sizedbox.dart';

class EmptyInventoryScreen extends StatelessWidget {
  const EmptyInventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double sW = MediaQuery.of(context).size.width;
    double sH = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            cspacingHeight(sH * 0.12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: sW * 0.05),
              child: Image.asset(
                "$imagepath/empty_invent.png",
                fit: BoxFit.fill,
                height: sH * 0.35,
              ),
            ),
            cspacingHeight(sH * 0.12),
            Text(
              emptyInventTitle,
              style: AppTheme.theme.textTheme.headlineLarge,
            ),
            Spacing.v15,
            Text(
              emptyInventSubTitle,
              textAlign: TextAlign.center,
              style: AppTheme.theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade500, fontWeight: FontWeight.w500),
            ),
            cbottomButton(emptyinventorybtnLabel,
                () => Get.to(() => AddInventoryScreen())),
            cspacingHeight(sH * 0.05),
          ],
        ),
      ),
    );
  }
}
