import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rent_and_return/controller/orders_controller/return_summary_controller.dart';
import 'package:rent_and_return/ui/bottom_nav_bar/homepage.dart';
import 'package:rent_and_return/utils/theme.dart';
import 'package:rent_and_return/widgets/c_appbar2.dart';
import 'package:rent_and_return/widgets/c_btn.dart';
import 'package:rent_and_return/widgets/c_sizedbox.dart';

class ViewReturnSummaryScreen extends StatelessWidget {
  ViewReturnSummaryScreen({super.key, required this.orderId});
  final String orderId;
  final ReturnSummaryController controller = Get.put(ReturnSummaryController());

  @override
  Widget build(BuildContext context) {
    double sH = MediaQuery.of(context).size.height;
    controller.refresh();
    controller.setOrderID(orderId);
    controller.fetchOrderSummary();

    return WillPopScope(
      onWillPop: () async {
        final shouldClose = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Order Closing"),
            content: const Text("Do you want to close the order?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("No"),
              ),
              TextButton(
                onPressed: () async {
                  print("OrderId in view returen Ui >> $orderId");
                  controller.closeOrder();  
                },
                child: const Text("Yes"),
              ),
            ],
          ),
        );

        return shouldClose ?? false;
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: cAppbar2("Return Summary & Payment", () => Get.back()),
        ),
        body: Stack(
          children: [
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
                  // QR Code Payment Section
                  Obx(
                    () => GestureDetector(
                      onTap: () {
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
                            if (!controller.showQRcode.value)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                              ),
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
                    controller: controller.cashAmountController,
                    // readOnly: true,
                  ),
                  cspacingHeight(sH * 0.02),
                  // Payment Summary Section
                  Text(
                    "Payment Summary",
                    style: AppTheme.theme.textTheme.labelMedium,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total",
                          style: AppTheme.theme.textTheme.labelMedium
                              ?.copyWith(color: Colors.grey, fontSize: 15),
                        ),
                        Obx(() {
                          final osdata = controller.orderSummaryData[0];
                          return Text(
                              "${osdata['total_bill_amount'].toString()}/-");
                        })
                      ],
                    ),
                  ),
                  // Missing Items Section
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Missing Items' Value",
                          style: AppTheme.theme.textTheme.labelMedium
                              ?.copyWith(color: Colors.grey, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  Obx(() {
                    final missingItems = controller.missingItemData;
                    double missingItemsTotal = 0.0;

                    return Column(
                      children: missingItems.map((msD) {
                        double itemTotal =
                            (msD['missing_qty'] * msD['buy_price']).toDouble();
                        missingItemsTotal += itemTotal;

                        return Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(msD['sku_name'] ?? ''),
                              Text(
                                  "${msD['missing_qty']} × ${msD['buy_price']} = ${itemTotal.toStringAsFixed(0)}/-"),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  }),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Advance Paid Amount",
                          style: AppTheme.theme.textTheme.labelMedium
                              ?.copyWith(color: Colors.grey, fontSize: 15),
                        ),
                        Obx(() {
                          final osdata = controller.orderSummaryData[0];
                          return Text(
                              "- ${osdata['advance_amount'].toString()}/-");
                        })
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Divider(),
                  ),
                  // Grand Total
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Grand Final Bill =",
                          style: AppTheme.theme.textTheme.labelMedium?.copyWith(
                            fontSize: 15,
                            color: Colors.grey,
                          ),
                        ),
                        Obx(() {
                          final osdata = controller.orderSummaryData[0];
                          final totalBill = osdata['total_bill_amount'];
                          final advancePaid = osdata['advance_amount'];
                          final missingItemsTotal = controller.missingItemData
                              .fold<double>(
                                  0.0,
                                  (sum, item) =>
                                      sum +
                                      (item['missing_qty'] *
                                          item['buy_price']));

                          final grandTotal =
                              totalBill - advancePaid + missingItemsTotal;

                          return Text(
                            "${grandTotal.toStringAsFixed(2)}/-",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.theme.primaryColor),
                          );
                        })
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Bottom Button
            Padding(
              padding: EdgeInsets.only(
                top: sH * 0.8,
                left: 20,
                right: 20,
              ),
              child: cBtn(
                "Close Order",
                () {
                  controller.closeOrder();
                },
                Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
