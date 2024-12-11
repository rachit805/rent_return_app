import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:rent_and_return/controller/add_item_order_controller.dart';
import 'package:rent_and_return/utils/theme.dart';
import 'package:rent_and_return/widgets/c_sizedbox.dart';

class OrderReceiptScreen extends StatelessWidget {
  OrderReceiptScreen({super.key});
  final AddItemOrderController itemController = Get.find();

  @override
  Widget build(BuildContext context) {
    double sH = MediaQuery.of(context).size.height;
    double sW = MediaQuery.of(context).size.width;

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
            Center(
                child: Container(
              height: 60,
              width: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black54),
              ),
              child: const Center(child: Text("LOGO")),
            )),
            const Text("Business Name"),
            const Text("GSTIN45687123"),
            const Text("70 near Ahmedabad City"),
            const Divider(),
            const Text("Customer Name: Rachit Gupta"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text("Order ID:"),
                    Text(itemController.cartItems.isNotEmpty
                        ? itemController.cartItems.first['order_id'] ?? 'N/A'
                        : 'N/A'),
                  ],
                ),
                Column(
                  children: const [Text("Mobile Number:"), Text("12345689")],
                ),
                Column(
                  children: const [Text("Order Date:"), Text("12345689")],
                )
              ],
            ),
            const Divider(),
            Container(
              height: 50,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text("Item Name"),
                  Text("QTY"),
                  Text("Price"),
                  Text("Amount")
                ],
              ),
            ),
            cspacingHeight(sH * 0.02),
            Expanded(
              child: Obx(() {
                final cartItems = itemController.cartItems;
                if (cartItems.isEmpty) {
                  return const Center(child: Text("No items in the cart"));
                }

                return ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, i) {
                    final item = cartItems[i];
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: Text(item['sku_name'] ?? 'N/A',
                                  textAlign: TextAlign.center),
                            ),
                            Expanded(
                              child: Text(item['quantity']?.toString() ?? '0',
                                  textAlign: TextAlign.center),
                            ),
                            Expanded(
                              child: Text(item['rent_price']?.toString() ?? '0',
                                  textAlign: TextAlign.center),
                            ),
                            Expanded(
                              child: Text(
                                  item['total_price']?.toString() ?? '0',
                                  textAlign: TextAlign.center),
                            ),
                          ],
                        ),
                        const Divider(),
                      ],
                    );
                  },
                );
              }),
            ),
            ElevatedButton(
              onPressed: () {
                generatePdf();
              },
              child: const Text("Print Receipt"),
            )
          ],
        ),
      ),
    );
  }

  Future<void> generatePdf() async {
    final pdf = pw.Document();

    // Add content to the PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                  child: pw.Container(
                height: 60,
                width: 100,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black),
                ),
                child: pw.Center(child: pw.Text("LOGO")),
              )),
              pw.Text("Business Name"),
              pw.Text("GSTIN45687123"),
              pw.Text("70 near Ahmedabad City"),
              pw.Divider(),
              pw.Text("Customer Name: Rachit Gupta"),
              pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      children: [
                        pw.Text("Order ID:"),
                        pw.Text(itemController.cartItems.isNotEmpty
                            ? itemController.cartItems.first['order_id'] ??
                                'N/A'
                            : 'N/A'),
                      ],
                    ),
                    pw.Column(children: [
                      pw.Text("Mobile Number:"),
                      pw.Text("12345689")
                    ]),
                    pw.Column(children: [
                      pw.Text("Order Date:"),
                      pw.Text("12345689")
                    ]),
                  ]),
              pw.Divider(),
              pw.Container(
                color: PdfColors.grey,
                padding: const pw.EdgeInsets.all(8),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Item Name"),
                    pw.Text("QTY"),
                    pw.Text("Price"),
                    pw.Text("Amount"),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),
              ...itemController.cartItems.map((item) {
                return pw.Column(
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(item['sku_name'] ?? 'N/A'),
                        pw.Text(item['quantity']?.toString() ?? '0'),
                        pw.Text(item['rent_price']?.toString() ?? '0'),
                        pw.Text(item['total_price']?.toString() ?? '0'),
                      ],
                    ),
                    pw.Divider(),
                  ],
                );
              }).toList()
            ],
          );
        },
      ),
    );

    // Display the PDF preview or print
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }
}
