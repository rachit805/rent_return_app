import 'package:get/get.dart';
import 'package:rent_and_return/services/data_services.dart';
import 'package:intl/intl.dart'; // For date formatting and comparison

class DashboardController extends GetxController {
  var currentPage = 0.obs;
  final RxList<Map<String, dynamic>> returnedOrdersData =
      <Map<String, dynamic>>[].obs;
  final List<Map<String, dynamic>> data = [
    {
      "month": "October",
      "totalOrders": "100",
      "closedOrders": "80",
      "pendingOrders": "20",
      "revenue": "43200/-",
    },
    {
      "month": "November",
      "totalOrders": "120",
      "closedOrders": "100",
      "pendingOrders": "20",
      "revenue": "50000/-",
    },
    {
      "month": "December",
      "totalOrders": "90",
      "closedOrders": "70",
      "pendingOrders": "20",
      "revenue": "40000/-",
    },
  ];

  final DatabaseHelper dbHelper = DatabaseHelper();
  final RxList<Map<String, dynamic>> orderSummary =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> todaysReturns =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> thisWeeksReturns =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> thisMonthsReturns =
      <Map<String, dynamic>>[].obs;

  Future<void> fetchOrderSummary() async {
    try {
      final data = await dbHelper.getOrderSummary();
      if (data != null) {
        orderSummary.assignAll(data);

        // Clear previous lists
        todaysReturns.clear();
        thisWeeksReturns.clear();
        thisMonthsReturns.clear();

        // Get today's date, start of the week, and start of the month
        final now = DateTime.now();
        final today = DateFormat('yyyy-MM-dd').format(now);
        final startOfWeek =
            now.subtract(Duration(days: now.weekday - 1)); // Monday
        final startOfMonth = DateTime(now.year, now.month, 1);

        for (var osData in data) {
          final returnDate = osData["return_date"];
          if (returnDate != null) {
            // Parse the return_date into a DateTime object
            final parsedDate = DateFormat('dd/MM/yyyy').parse(returnDate);

            // Check if the return date matches today's date
            if (DateFormat('yyyy-MM-dd').format(parsedDate) == today) {
              todaysReturns.add(osData);
            }
            // Check if the return date falls within this week
            else if (parsedDate
                    .isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
                parsedDate.isBefore(startOfWeek.add(const Duration(days: 7)))) {
              thisWeeksReturns.add(osData);
            }
            // Check if the return date falls within this month
            else if (parsedDate
                    .isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
                parsedDate.month == now.month) {
              thisMonthsReturns.add(osData);
            }
          }
        }

        print("Order summary fetched: $orderSummary");
        print("Today's Returns: $todaysReturns");
        print("This Week's Returns: $thisWeeksReturns");
        print("This Month's Returns: $thisMonthsReturns");
      } else {
        print("No order summary data found.");
      }
    } catch (e) {
      print("Error fetching order summary: $e");
    }
  }
}