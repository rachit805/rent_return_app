import 'dart:ffi';

import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:rent_and_return/helper/get_storage_helper.dart';
import 'package:rent_and_return/services/data_services.dart';
import 'package:rent_and_return/ui/orders/order_receipt_screen.dart';
// import 'package:rent_and_return/controller/order_reciept_controller.dart';
// import 'package:rent_and_return/controller/payment_controller.dart';

class OrderReceiptController extends GetxController {
  @override
  void onInit() {
    loadRewardedAd();
    super.onInit();
    getCustomerData();
  }

  final GetStorageHelper _storageHelper = GetStorageHelper();

  RewardedAd? rewardedAd;
  RxBool isLoaded = false.obs;

  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: "ca-app-pub-2514113084570130/8516935256",
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          rewardedAd = ad;
          isLoaded.value = true;

          rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              Get.to(() => OrderReceiptScreen());
              // Get.offAll(() => Homepage());
              ad.dispose();
              isLoaded.value = false; // Reset ad load state
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              // Navigate to HomePage if the ad fails to show

              Get.to(() => OrderReceiptScreen());
              ad.dispose();
              isLoaded.value = false; // Reset ad load state
            },
          );
        },
        onAdFailedToLoad: (error) {
          print("Failed to load rewarded ad: ${error.message}");
          isLoaded.value = false; // Reset ad load state
        },
      ),
    );
  }

  void showRewardedAd() {
    print('hi');
    if (isLoaded.value && rewardedAd != null) {
      print('hello');
      rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          // You can perform any reward-related actions here
          print("User earned reward: ${reward.amount} ${reward.type}");
        },
      );
    } else {
      print("Ad not ready, navigating directly.");

      Get.to(() => OrderReceiptScreen());
    }
  }

  final DatabaseHelper dbHelper = DatabaseHelper();
  final RxList<Map<String, dynamic>> orderedData = <Map<String, dynamic>>[].obs;

  final Rxn<Map<String, dynamic>> customerData = Rxn<Map<String, dynamic>>();

  void setOrderedItems(List<Map<String, dynamic>> items) {
    orderedData.assignAll(items);
  }

  final RxString cname = "".obs;
  final RxString mobnumber = "".obs;

  Future<void> getCustomerData() async {
    try {
      if (orderedData.isEmpty) {
        print('No ordered data available.');
        return;
      }

      final customerId = orderedData.first['customer_id'];
      if (customerId == null) {
        print('Customer ID is null in ordered data.');
        return;
      }

      final cdata = await dbHelper.getCustomerDataById(customerId.toString());
      if (cdata != null) {
        customerData.value = cdata;
        print('Customer Data Fetched: $cdata');

        cname.value = customerData.value?["customer_name"];
        mobnumber.value = customerData.value?["mob_number"];

        print("Customer Name: ${cname.value}");
      } else {
        print('No customer data found for ID: $customerId');
      }
    } catch (e) {
      print('Error fetching customer data: $e');
    }
  }

  Future<void> generatePdf(List<dynamic> orderedData) async {
    final pdf = pw.Document();
    final ownerName = _storageHelper.getData('ownerName');
    final businessName = _storageHelper.getData('ownerName');

    final mobNumber = _storageHelper.getData('phoneNumber');
    final gstNumber = _storageHelper.getData('gstNumber');
    final address = _storageHelper.getData('address');
    final image = _storageHelper.getData('imagePath');

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
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
              pw.Text(ownerName),
              pw.Text(gstNumber),
              pw.Text(address),
              pw.Divider(),
              pw.Text("Customer Name: ${cname.value}"),
              pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      children: [
                        pw.Text("Order ID:"),
                        pw.Text(orderedData.isNotEmpty
                            ? orderedData.first['order_id'] ?? 'N/A'
                            : 'N/A'),
                      ],
                    ),
                    pw.Column(children: [
                      pw.Text("Mobile Number:"),
                      pw.Text(mobnumber.value)
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
              ...orderedData.map((item) {
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
