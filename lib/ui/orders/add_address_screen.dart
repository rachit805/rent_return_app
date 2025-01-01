import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rent_and_return/controller/add_address_controller.dart';
import 'package:rent_and_return/controller/create_order_userDeatail_contrroller.dart';
import 'package:rent_and_return/ui/orders/payment_screen.dart';
import 'package:rent_and_return/utils/theme.dart';
import 'package:rent_and_return/widgets/c_appbar2.dart';
import 'package:rent_and_return/widgets/c_border_btn.dart';
import 'package:rent_and_return/widgets/c_btn.dart';
import 'package:rent_and_return/widgets/c_sizedbox.dart';

class AddAddressScreen extends StatelessWidget {
  AddAddressScreen({super.key, required this.totalAmount});
  final CreateOrderController userdatacontroller = Get.find();
// final AddAddressController controller = Get.find();
  // final AddAddressController controller = Get.put(AddAddressController());
  final totalAmount;

  @override
  Widget build(BuildContext context) {
    // controller.remainingAmount.value = totalAmount.value;
    final AddAddressController controller = Get.put(
      AddAddressController(totalAmountValue: totalAmount.value),
    );
    double sH = MediaQuery.of(context).size.height;
    double sW = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: cAppbar2("Place Order", () {})),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userdatacontroller.cNameController.text,
                style: AppTheme.theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.black, fontWeight: FontWeight.w600),
              ),
              Obx(
                () => Text(
                  userdatacontroller.selectedAddress.isEmpty
                      ? userdatacontroller.addressController.text
                      : userdatacontroller.selectedAddress.value,
                  style: AppTheme.theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.black, fontWeight: FontWeight.w500),
                ),
              ),
              cspacingHeight(sH * 0.05),
              cBtn("Place to this address", () {
                showModalBottomSheet(
                    context: context,
                    builder: (builder) => Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 10),
                          height: sH * 0.45,
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Rent Summary",
                                            style: AppTheme
                                                .theme.textTheme.labelMedium,
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Total",
                                              style: AppTheme
                                                  .theme.textTheme.labelMedium
                                                  ?.copyWith(
                                                      color: Colors.grey,
                                                      fontSize: 15),
                                            ),
                                            Text(
                                                "${totalAmount.value.toStringAsFixed(0)}/-")
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Amount Paid in Advance",
                                              style: AppTheme
                                                  .theme.textTheme.labelMedium
                                                  ?.copyWith(
                                                      color: Colors.grey,
                                                      fontSize: 15),
                                            ),
                                            SizedBox(
                                              width: sW * 0.2,
                                              height: 40,
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.number,
                                                controller: controller
                                                    .advanceAmountController,
                                                focusNode: controller
                                                    .advanceAmountFocusNode,
                                                decoration:
                                                    const InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.all(2),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Divider(),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Remaining Amount",
                                              style: AppTheme
                                                  .theme.textTheme.labelMedium
                                                  ?.copyWith(
                                                fontSize: 15,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Obx(() => Text(
                                                  "${controller.remainingAmount.value.toStringAsFixed(0)}/-",
                                                  style: const TextStyle(
                                                      fontSize: 15),
                                                )),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                cspacingHeight(sH * 0.05),
                                cBtn("Procced to pay", () {
                                  // print(controller.remainingAmount.value);
                                  Get.to(() => PaymentScreen(
                                        cashAmount: controller
                                            .advanceAmountController.text
                                            .toString(),
                                      ));
                                }, Colors.white)
                              ],
                            ),
                          ),
                        ));
              }, Colors.white),
              cspacingHeight(sH * 0.05),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 2),
                ),
                // height: sH * 0.15,
                width: double.infinity,
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        showModalBottomSheet(
                            isScrollControlled: true,
                            context: context,
                            builder: (builder) => SizedBox(
                                  height: sH * 0.6,
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextFormField(
                                            controller: userdatacontroller
                                                .newAddressController,
                                            keyboardType:
                                                TextInputType.streetAddress,
                                            decoration: InputDecoration(
                                              hintText: "Add New Address",
                                              labelText: "New Address",
                                              labelStyle:
                                                  TextStyle(color: Colors.grey),
                                              focusColor:
                                                  AppTheme.theme.primaryColor,
                                              focusedBorder:
                                                  UnderlineInputBorder(),
                                            )),
                                        cspacingHeight(sH * 0.05),
                                        cBtn("Add Address", () {
                                          userdatacontroller.addNewAddress();
                                        }, Colors.white),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          child: Text(
                                            "Select Address",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 18,
                                                color: Colors.grey),
                                          ),
                                        ),
                                        Expanded(
                                          child: Obx(
                                            () => ListView.builder(
                                              itemCount: userdatacontroller
                                                  .addressList.length,
                                              reverse: true,
                                              itemBuilder: (context, index) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      InkWell(
                                                        onTap: () {
                                                          userdatacontroller
                                                                  .selectedAddress
                                                                  .value =
                                                              userdatacontroller
                                                                      .addressList[
                                                                  index];
                                                          Get.back();
                                                        },
                                                        child: Text(
                                                          userdatacontroller
                                                                  .addressList[
                                                              index],
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize: 17),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Add New Address",
                              style: AppTheme.theme.textTheme.labelLarge
                                  ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade600),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.black,
                              size: 15,
                            )
                          ],
                        ),
                      ),
                    ),
                    const Divider(
                      thickness: 2,
                      color: Colors.grey,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Call in Difficulties",
                            style: AppTheme.theme.textTheme.labelLarge
                                ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade600),
                          ),
                          Text(
                            userdatacontroller.mobController.text,
                            style: AppTheme.theme.textTheme.bodyLarge,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              cspacingHeight(sH * 0.1),
              Row(
                children: [
                  const Expanded(
                    child: Divider(
                      thickness: 2,
                      color: Colors.grey,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Text(
                      "Or",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Divider(
                      thickness: 2,
                      color: Colors.grey,
                    ),
                  )
                ],
              ),
              cspacingHeight(sH * 0.1),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: cBorderBtn("Preview Items", () {
                    Get.back();
                  })),
            ],
          ),
        ),
      ),
    );
  }
}
