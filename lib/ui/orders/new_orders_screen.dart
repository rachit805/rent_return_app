import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rent_and_return/controller/create_order_userDeatail_contrroller.dart';
import 'package:rent_and_return/ui/orders/add_items_order.dart';
import 'package:rent_and_return/utils/theme.dart';
import 'package:rent_and_return/widgets/c_appbar.dart';
import 'package:rent_and_return/widgets/c_btn.dart';
import 'package:rent_and_return/widgets/c_sizedbox.dart';

class CreateOrderUserDetailScreen extends StatelessWidget {
  final CreateOrderController controller = Get.put(CreateOrderController());

  CreateOrderUserDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: CAppbar(
          title: "New Order",
          labelColor: Colors.black,
          leading: true,
          leadingIconColor: Colors.black,
          bgColor: AppTheme.theme.scaffoldBackgroundColor,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTextField(controller.mobController, "Mobile Number", ''),
              Spacing.v10,
              buildTextField(
                  controller.aMobController, "Alternative Mobile Number", ''),
              Spacing.v10,
              buildTextField(controller.cNameController, "Customer Name", ''),
              Spacing.v10,
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: DropdownButton<String>(
                      isExpanded: true,
                      isDense: true,
                      underline: const Divider(
                        thickness: 1,
                        color: Colors.black87,
                      ),
                      value: controller.selectedCard.value.isNotEmpty
                          ? controller.selectedCard.value
                          : null,
                      hint: Text(
                        'ID Card',
                        style: AppTheme.theme.textTheme.bodySmall
                            ?.copyWith(color: Colors.black87),
                      ),
                      items: controller.idCard.map((String card) {
                        return DropdownMenuItem<String>(
                          value: card,
                          child: Text(card),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          controller.selectIdCard(newValue);
                        }
                      },
                    ),
                  )),
              Spacing.v10,
              buildTextField(controller.idNumController, "Id Number", ""),
              Spacing.v10,
              buildTextField(controller.addressController, "Address", ''),
              Spacing.v10,
              buildTextField(
                  controller.refNameController, "Reference Name", ''),
              Spacing.v10,
              buildTextField(
                  controller.refMobController, "Reference Mobile Number", ''),
              Spacing.v10,
              buildDatePickerField(
                  controller.deliveryDateController, "Delivery Date", context),
              Spacing.v10,
              buildDatePickerField(
                  controller.returnDateController, "Return Date", context),
              Spacing.v20,
              cBtn("Create Order", () {
                controller.addUserData();
              }, Colors.white),
              Spacing.v20,
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
      TextEditingController controller, String label, String? hintText) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelStyle: AppTheme.theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w500, color: Colors.black, fontSize: 15),
        labelText: label,
        hintText: hintText,
        enabledBorder: const UnderlineInputBorder(),
      ),
    );
  }

  Widget buildDatePickerField(TextEditingController textController,
      String label, BuildContext context) {
    return TextFormField(
      controller: textController,
      readOnly: true,
      decoration: InputDecoration(
        suffix: const Icon(
          Icons.arrow_drop_down,
          color: Colors.black,
        ),
        labelStyle: AppTheme.theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w500, color: Colors.black, fontSize: 15),
        labelText: label,
        hintText: 'DD/MM/YYYY',
        enabledBorder: const UnderlineInputBorder(),
      ),
      onTap: () {
        controller.pickDate(textController, context); // Corrected usage
      },
    );
  }
}
