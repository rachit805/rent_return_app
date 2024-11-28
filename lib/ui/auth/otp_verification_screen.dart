import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rent_and_return/controller/otp_verification_controller.dart';
import 'package:rent_and_return/ui/inventory/empty_inventory_screen.dart';
import 'package:rent_and_return/utils/strings.dart';
import 'package:rent_and_return/utils/theme.dart';
import 'package:rent_and_return/widgets/c_btn.dart';
import 'package:rent_and_return/widgets/c_para_text.dart';
import 'package:rent_and_return/widgets/c_sizedbox.dart';
import 'package:rent_and_return/widgets/c_timer_container.dart';
import 'package:rent_and_return/widgets/otp_pin_field.dart';

class OtpVerificationScreen extends StatelessWidget {
  OtpVerificationScreen({super.key, required this.phone});

  final String phone;
  final OtpVerificationController controller =
      Get.put(OtpVerificationController()); // Instantiate the timer controller

  @override
  Widget build(BuildContext context) {
    double sH = MediaQuery.of(context).size.height;
    double sW = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(padding: EdgeInsets.only(top: sH * 0.08)),
                  Text(
                    otpVerifyTitle,
                    style: AppTheme.theme.textTheme.headlineLarge,
                    textAlign: TextAlign.left,
                  ),
                  Spacing.v10,
                  Row(children: [
                    cParaText(otpVerifySubtitle1),
                    cParaText(phone)
                  ]),
                  cParaText(otpVerifySubtitle2),
                  cspacingHeight(sH * 0.1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // 6 pins OTP Input
                      OtpInput(
                        controller.fieldOne,
                        true,
                      ),
                      OtpInput(controller.fieldTwo, false),
                      OtpInput(controller.fieldThree, false),
                      OtpInput(controller.fieldFour, false),
                      OtpInput(controller.fieldFive, false),
                      OtpInput(controller.fieldSix, false),
                    ],
                  ),
                  cspacingHeight(sH * 0.05),
                  Row(
                    children: [
                      Obx(() => timerContainer(cText(
                          "${controller.secondsRemaining.value}s",
                          12,
                          FontWeight.normal))),
                      Obx(() => TextButton(
                            onPressed: controller.canResend.value
                                ? () {
                                    controller.resendOTP();
                                  }
                                : null,
                            child: cText(
                              "Send Again",
                              12,
                              FontWeight.normal,
                              // color: timerController.canResend.value
                              //     ? Theme.of(context).primaryColor
                              //     : Colors.grey, // Change color based on the timer state
                            ),
                          )),
                    ],
                  ),
                  cspacingHeight(sH * 0.08),
                  // Submit button
                  cBtn(loginbtnLabel, () => controller.verifyOTP()),
                ],
              ),
            ),
          ),
          Obx(() => controller.isOTPSent.value
              ? Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.theme.primaryColor,
                    ),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}
