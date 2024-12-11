import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rent_and_return/controller/add_address_controller.dart';
import 'package:rent_and_return/controller/add_item_order_controller.dart';
import 'package:rent_and_return/services/data_services.dart';
import 'package:rent_and_return/ui/orders/payment_succes_screen.dart';

class PaymentController extends GetxController {
  RxBool showQRcode = false.obs;
  final RxList<Map<String, dynamic>> orderSummaryData =
      <Map<String, dynamic>>[].obs;

  // Retrieve instances of other controllers
  final AddItemOrderController itemController = Get.find();
  final AddAddressController addressController = Get.find();
  RxString transactionID = ''.obs;
  RxString advanceAmount = ''.obs;
  RxString remainingAmount = ''.obs;
  RxString transactionDateTime = ''.obs;
  RxString transactionMode = ''.obs;

  final DatabaseHelper dbHelper = DatabaseHelper();

  Future<void> insertOrderSummaryData() async {
    for (var cartItem in itemController.cartItems) {
      print("CART ITEM IN FETCHING:: $cartItem");
      final formattedDateTime =
          DateFormat('dd/MM/yyyy, hh:mm a').format(DateTime.now());

      // Prepare the order summary data
      final osdata = {
        'order_id': itemController.orderid.value,
        'cart_id': itemController.cartId.value,
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
        // Insert the order summary and retrieve the inserted data
        final insertedData = await dbHelper.insertOrderSummary(osdata);

        if (insertedData != null) {
          // Store the inserted data in the reactive list
          orderSummaryData.add(insertedData);

          // Print success and navigate to the next screen
          print('Order summary inserted successfully: $insertedData');
          Get.to(() => PaymentSuccessScreen(
                orderSummary: insertedData, // Pass the inserted data to the UI
              ));
        }
      } catch (e) {
        // Handle errors and stop navigation
        print('Error inserting order summary: $e');
      }
    }
  }
}
