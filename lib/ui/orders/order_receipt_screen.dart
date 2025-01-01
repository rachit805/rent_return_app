import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:rent_and_return/controller/order_reciept_controller.dart';
import 'package:rent_and_return/helper/get_storage_helper.dart';
// import 'package:rent_and_return/controller/order_reciept_controller.dart';
// import 'package:rent_and_return/controller/payment_controller.dart';
import 'package:rent_and_return/utils/theme.dart';
import 'package:rent_and_return/widgets/c_sizedbox.dart';

class OrderReceiptScreen extends StatelessWidget {
  OrderReceiptScreen({super.key});
  final OrderReceiptController controller = Get.put(OrderReceiptController());
  final GetStorageHelper _storageHelper = GetStorageHelper();

  @override
  Widget build(BuildContext context) {
    final ownerName = _storageHelper.getData('ownerName');
    final businessName = _storageHelper.getData('ownerName');

    final mobNumber = _storageHelper.getData('phoneNumber');
    final gstNumber = _storageHelper.getData('gstNumber');
    final address = _storageHelper.getData('address');
    final image = _storageHelper.getData('imagePath');

    double sH = MediaQuery.of(context).size.height;
    controller.getCustomerData();
    controller.refresh();
    String getFormattedOrderDate(String orderId) {
      try {
        String datePart = orderId.split('_')[1];

        return (datePart.length == 8)
            ? "${datePart.substring(0, 2)}/${datePart.substring(2, 4)}/${datePart.substring(4, 8)}"
            : "Invalid Date";
      } catch (e) {
        return "Invalid Date";
      }
    }

    String orderId = controller.orderedData.first['order_id'] ?? '';
    String formattedDate = getFormattedOrderDate(orderId);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: const Text(''),
        centerTitle: false,
        title: Text(
          "Receipt",
          style: AppTheme.theme.textTheme.labelLarge,
        ),
        backgroundColor: Colors.white,
        bottom: const PreferredSize(
            preferredSize: Size.fromHeight(20), child: Divider()),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: sH * 0.02),
              child: Center(
                  child: Container(
                height: 60,
                width: 90,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black54),
                ),
                child: const Center(child: Text("LOGO")),
              )),
            ),
            Text(
              ownerName.isEmpty ? "Owner Name" : ownerName,
              style: AppTheme.theme.textTheme.labelLarge,
            ),
            Text(
              businessName.isEmpty ? "Business Name" : businessName,
              style: AppTheme.theme.textTheme.labelLarge,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: sH * 0.01),
              child: Text(
                ownerName.isEmpty ? "GST Number" : gstNumber,
              ),
            ),

            itemText(address.isEmpty ? "Address" : address),
            Padding(
              padding: EdgeInsets.symmetric(vertical: sH * 0.015),
              child: const Divider(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                itemText(
                  "Customer Name:  ",
                ),
                Text(
                  controller.cname.value.isEmpty
                      ? "Customer Name"
                      : controller.cname.value,
                  style: AppTheme.theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade700),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      itemText("Order ID:"),
                      Obx(() => Text(
                            controller.orderedData.isNotEmpty
                                ? controller.orderedData.first['order_id'] ??
                                    'N/A'
                                : 'N/A',
                            maxLines: 2,
                            style: AppTheme.theme.textTheme.bodyLarge
                                ?.copyWith(fontSize: 14),
                          )),
                    ],
                  ),
                  Column(
                    children: [
                      itemText("Mobile Number:"),
                      Text(
                        controller.mobnumber.value.isEmpty
                            ? "Mobile Number"
                            : controller.mobnumber.value,
                        style: AppTheme.theme.textTheme.bodyLarge
                            ?.copyWith(fontSize: 14),
                      )
                    ],
                  ),
                  Column(
                    children: [
                      itemText("Order Date:"),
                      Text(formattedDate,
                          style: AppTheme.theme.textTheme.bodyLarge
                              ?.copyWith(fontSize: 14))
                    ],
                  )
                ],
              ),
            ),
            const Divider(),
            cspacingHeight(sH * 0.03),
            Container(
              height: 60,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blueGrey.withOpacity(0.15),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  itemText("Item Name"),
                  itemText("QTY"),
                  itemText("Price"),
                  itemText("Amount")
                ],
              ),
            ),
            cspacingHeight(sH * 0.03),
            Expanded(
              child: Obx(() {
                final orderedData = controller.orderedData;
                if (orderedData.isEmpty) {
                  return const Center(child: Text("No items in the order"));
                }

                return ListView.builder(
                  itemCount: orderedData.length,
                  itemBuilder: (context, i) {
                    final item = orderedData[i];

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            itemText(item['sku_name'] ?? 'N/A'),
                            itemText(item['quantity']?.toString() ?? '0'),
                            itemText(item['rent_price']?.toString() ?? '0'),
                            itemText(item['total_price']?.toString() ?? '0')
                          ],
                        ),
                        const Divider(),
                      ],
                    );
                  },
                );
              }),
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     generatePdf(controller.orderedData);
            //   },
            //   child: const Text("Print Receipt"),
            // )
          ],
        ),
      ),
    );
  }

  Widget itemText(String label) {
    return Text(
      label,
      textAlign: TextAlign.center,
      style: AppTheme.theme.textTheme.bodyMedium?.copyWith(
          fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black54),
    );
  }

  // Future<void> generatePdf(List<dynamic> orderedData) async {
  //   final pdf = pw.Document();

  //   // Add content to the PDF
  //   pdf.addPage(
  //     pw.Page(
  //       build: (pw.Context context) {
  //         return pw.Column(
  //           crossAxisAlignment: pw.CrossAxisAlignment.center,
  //           children: [
  //             pw.Center(
  //                 child: pw.Container(
  //               height: 60,
  //               width: 100,
  //               decoration: pw.BoxDecoration(
  //                 border: pw.Border.all(color: PdfColors.black),
  //               ),
  //               child: pw.Center(child: pw.Text("LOGO")),
  //             )),
  //             pw.Text("Business Name"),
  //             pw.Text("GSTIN45687123"),
  //             pw.Text("70 near Ahmedabad City"),
  //             pw.Divider(),
  //             pw.Text("Customer Name: Rachit Gupta"),
  //             pw.Row(
  //                 mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   pw.Column(
  //                     children: [
  //                       pw.Text("Order ID:"),
  //                       pw.Text(orderedData.isNotEmpty
  //                           ? orderedData.first['order_id'] ?? 'N/A'
  //                           : 'N/A'),
  //                     ],
  //                   ),
  //                   pw.Column(children: [
  //                     pw.Text("Mobile Number:"),
  //                     pw.Text("12345689")
  //                   ]),
  //                   pw.Column(children: [
  //                     pw.Text("Order Date:"),
  //                     pw.Text("12345689")
  //                   ]),
  //                 ]),
  //             pw.Divider(),
  //             pw.Container(
  //               color: PdfColors.grey,
  //               padding: const pw.EdgeInsets.all(8),
  //               child: pw.Row(
  //                 mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   pw.Text("Item Name"),
  //                   pw.Text("QTY"),
  //                   pw.Text("Price"),
  //                   pw.Text("Amount"),
  //                 ],
  //               ),
  //             ),
  //             pw.SizedBox(height: 10),
  //             ...orderedData.map((item) {
  //               return pw.Column(
  //                 children: [
  //                   pw.Row(
  //                     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       pw.Text(item['sku_name'] ?? 'N/A'),
  //                       pw.Text(item['quantity']?.toString() ?? '0'),
  //                       pw.Text(item['rent_price']?.toString() ?? '0'),
  //                       pw.Text(item['total_price']?.toString() ?? '0'),
  //                     ],
  //                   ),
  //                   pw.Divider(),
  //                 ],
  //               );
  //             }).toList()
  //           ],
  //         );
  //       },
  //     ),
  //   );

  //   // Display the PDF preview or print
  //   await Printing.layoutPdf(
  //       onLayout: (PdfPageFormat format) async => pdf.save());
  // }
}
