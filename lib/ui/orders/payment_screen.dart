import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rent_and_return/controller/payment_controller.dart';
import 'package:rent_and_return/ui/orders/payment_succes_screen.dart';
import 'package:rent_and_return/utils/theme.dart';
import 'package:rent_and_return/widgets/c_appbar2.dart';
import 'package:rent_and_return/widgets/c_btn.dart';
import 'package:rent_and_return/widgets/c_sizedbox.dart';

class PaymentScreen extends StatelessWidget {
  PaymentScreen({super.key, required this.cashAmount})
      : amountController = TextEditingController(text: cashAmount);

  final TextEditingController amountController;
  final String cashAmount;
  final PaymentController controller = Get.put(PaymentController());

  @override
  Widget build(BuildContext context) {
    double sH = MediaQuery.of(context).size.height;
    double sW = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: cAppbar2("Payment", () {
          Get.back();
        }),
      ),
      body: Stack(
        children: [
          // Main Content Area
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                cspacingHeight(sH * 0.01),
                Text(
                  "Select Payment mode",
                  style: AppTheme.theme.textTheme.labelMedium
                      ?.copyWith(fontSize: 20),
                ),
                cspacingHeight(sH * 0.03),
                Obx(
                  () => GestureDetector(
                    onTap: () {
                      // Toggle the QR code visibility
                      controller.showQRcode.value =
                          !controller.showQRcode.value;
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      width: double.infinity,
                      height: controller.showQRcode.value ? sH * 0.25 : 50,
                      child: Stack(
                        children: [
                          // Default "By QR Code" row
                          if (!controller.showQRcode.value)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "By QR code",
                                  style: AppTheme.theme.textTheme.labelMedium
                                      ?.copyWith(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.black87,
                                  size: 40,
                                ),
                              ],
                            ),
                          // Animated QR code area
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            child: controller.showQRcode.value
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Scan QR Code",
                                              style: AppTheme
                                                  .theme.textTheme.labelMedium
                                                  ?.copyWith(
                                                color: Colors.black87,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const Icon(
                                              Icons.arrow_drop_up,
                                              color: Colors.black87,
                                              size: 40,
                                            )
                                          ],
                                        ),
                                        cspacingHeight(sH * 0.01),
                                        Container(
                                          width: 100,
                                          height: 100,
                                          color: Colors.black12,
                                          child: const Center(
                                            child: Text("QR Code Here"),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                cspacingHeight(sH * 0.05),
                Text(
                  "By Cash",
                  style: AppTheme.theme.textTheme.labelMedium?.copyWith(
                      color: Colors.black87, fontWeight: FontWeight.w500),
                ),
                TextFormField(
                  controller: amountController,
                  readOnly: true,
                ),
                cspacingHeight(sH * 0.1), // Add extra space for padding
              ],
            ),
          ),
          // Bottom Button Area
          Padding(
            padding: EdgeInsets.only(
              top: sH * 0.8,
              left: 20,
              right: 20,
            ),
            child: cBtn(
              "Receive Payment",
              () {
                controller.insertOrderSummaryData();
              },
              Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
