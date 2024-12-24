import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rent_and_return/controller/add_address_controller.dart';
import 'package:rent_and_return/controller/add_item_order_controller.dart';
import 'package:rent_and_return/controller/order_reciept_controller.dart';
import 'package:rent_and_return/services/data_services.dart';
import 'package:rent_and_return/ui/orders/order_receipt_screen.dart';
import 'package:rent_and_return/ui/orders/payment_succes_screen.dart';

class PaymentController extends GetxController {
  RxBool showQRcode = false.obs;
  final RxList<Map<String, dynamic>> orderSummaryData =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> orderedData = <Map<String, dynamic>>[].obs;

  // Retrieve instances of other controllers
  final AddItemOrderController itemController = Get.find();
  final AddAddressController addressController = Get.find();
  RxString transactionID = ''.obs;
  RxString advanceAmount = ''.obs;
  RxString remainingAmount = ''.obs;
  RxString transactionDateTime = ''.obs;
  RxString transactionMode = ''.obs;
  final Rxn<Map<String, dynamic>> customerData = Rxn<Map<String, dynamic>>();
  final DatabaseHelper dbHelper = DatabaseHelper();

  Future<void> insertOrderSummaryData() async {
    final formattedDateTime =
        DateFormat('dd/MM/yyyy, hh:mm a').format(DateTime.now());

    // Prepare the order summary data
    final osdata = {
      'order_id': itemController.orderid.value,
      'customer_id': itemController.customerId.value,
      'transcation_mode': transactionMode.value,
      'transcation_id': transactionID.value,
      'total_bill_amount': addressController.totalAmount.value,
      'delivery_date': itemController.deliveryDate.value,
      'return_date': itemController.returnDate.value,
      'advance_amount':
          addressController.advanceAmountController.text.toString(),
      'pending_amount': addressController.remainingAmount.value.toString(),
      'transcation_date_time': formattedDateTime,
    };

    try {
      // Insert the order summary data
      final insertedData = await dbHelper.insertOrderSummary(osdata);

      if (insertedData != null) {
        for (var osListData in insertedData) {
          orderSummaryData.add(osListData);

          print('Order summary inserted successfully: $osListData');

          // Fetch customer data using customer_id
    

          // Fetch cart data using order_id
          final cartData =
              await dbHelper.getCartDataByOrderId(itemController.orderid.value);
          orderedData.value = cartData;

          print("Ordered Data: $orderedData");

          // Update OrderReceiptController
          final OrderReceiptController receiptController =
              Get.put(OrderReceiptController());
          receiptController.setOrderedItems(orderedData);

          // Navigate to PaymentSuccessScreen
          Get.to(() => PaymentSuccessScreen(
                orderSummary: osListData,
              ));
        }
      }
    } catch (e) {
      print('Error inserting order summary: $e');
    }
  }

  void viewReciept() {
    Get.to(() => OrderReceiptScreen());
  }

  void printReciept() {}
}
