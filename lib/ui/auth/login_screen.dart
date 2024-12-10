import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rent_and_return/controller/login_controller.dart';
import 'package:rent_and_return/utils/strings.dart';
import 'package:rent_and_return/utils/theme.dart';
import 'package:rent_and_return/widgets/c_bottom_button.dart';
import 'package:rent_and_return/widgets/c_sizedbox.dart';
import 'package:rent_and_return/widgets/c_textformfield.dart';

class LogInScreen extends StatelessWidget {
  LogInScreen({super.key});
  final LoginController controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    double sH = MediaQuery.of(context).size.height;
    double sW = MediaQuery.of(context).size.width;

    // Detect the height of the keyboard
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    bool isKeyboardOpen = keyboardHeight > 0;

    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: sW * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(padding: EdgeInsets.only(top: sH * 0.08)),
                  Text(
                    loginTitle,
                    style: AppTheme.theme.textTheme.headlineLarge,
                    textAlign: TextAlign.left,
                  ),
                  Spacing.v20,

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: sW * 0.05),
                    child: AnimatedContainer(
                      height: isKeyboardOpen
                          ? sH * 0.2
                          : sH *
                              0.35, // Change the image height when keyboard is open
                      duration: Duration.zero,
                      child: Image.asset(
                        "$imagepath/auth.png",
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  SizedBox(
                      height: isKeyboardOpen
                          ? sH * 0.05
                          : sH * 0.1), // Adjust spacing when keyboard is open

                  // Company name form field
                  CTextformfield(
                    controller: controller.cnameController,
                    label: cnameTxtformfieldLabel,
                    keyboardType: TextInputType.name,
                    maxlength: 20,
                  ),
                  Spacing.v15,

                  // Phone number form field
                  CTextformfield(
                    controller: controller.phoneController,
                    label: phoneTxtformfieldLabel,
                    keyboardType: TextInputType.phone,
                    maxlength: 10,
                  ),

                  // Login button
                  cbottomButton(loginbtnLabel, () => controller.sendOTP(), AppTheme.theme.scaffoldBackgroundColor),
                  Spacing.v20,
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
