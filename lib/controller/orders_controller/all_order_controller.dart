import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:rent_and_return/controller/orders_controller/return_summary_controller.dart';
import 'package:rent_and_return/helper/ad_Helper.dart';
import 'package:rent_and_return/services/data_services.dart';

class AllOrderController extends GetxController {
  BannerAd? bannerAd;
  RxBool isBannerAdLoaded = true.obs;

  @override
  void onInit() {
    super.onInit();
    initializeBannerAd();
  }

  final DatabaseHelper dbHelper = DatabaseHelper();
  final RxList<Map<String, dynamic>> orderSummary =
      <Map<String, dynamic>>[].obs;
  final RxMap<int, Map<String, dynamic>> customerData =
      <int, Map<String, dynamic>>{}.obs;

  // Initialize Banner Ad
  void initializeBannerAd() {
    bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: AdHelper.bannerAdUnitId,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print("Banner Ad Loaded");
          isBannerAdLoaded.value = true;
          update();
        },
        onAdFailedToLoad: (ad, error) {
          print("Failed to load Banner Ad: ${error.message}");
          ad.dispose();
        },
      ),
      request: const AdRequest(),
    )..load();
  }

  Future<void> fetchOrderSummary() async {
    try {
      final data = await dbHelper.getOrderSummary();
      if (data != null) {
        orderSummary.assignAll(data);
        final ReturnSummaryController returnSummaryController =
            Get.put(ReturnSummaryController());
        returnSummaryController.setOrderedSummaryData(data);
        print("Order summary fetched: $orderSummary");
        for (var order in data) {
          int customerId = order['customer_id'];
          if (!customerData.containsKey(customerId)) {
            await fetchCustomerData(customerId);
          }
        }
      } else {
        print("No order summary data found.");
      }
    } catch (e) {
      print("Error fetching order summary: $e");
    }
  }

  Future<void> fetchCustomerData(int customerId) async {
    try {
      final data = await dbHelper.getCustomerDataById(customerId.toString());
      if (data != null) {
        customerData[customerId] = data;
        print("Customer data fetched for ID $customerId: $data");
      } else {
        print("No customer data found for ID $customerId.");
      }
    } catch (e) {
      print("Error fetching customer data for ID $customerId: $e");
    }
  }
}
