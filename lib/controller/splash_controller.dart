import 'package:get/get.dart';
import 'package:rent_and_return/controller/otp_verification_controller.dart';
import 'package:rent_and_return/ui/bottom_nav_bar/homepage.dart';
import 'package:rent_and_return/ui/welcomeUI/onboarding_screen.dart';

class SplashController extends GetxController {
  final OtpVerificationController loginController =
      Get.put(OtpVerificationController());

  @override
  void onInit() {
    Future.delayed(const Duration(seconds: 2), () {
      loginController.checkLoginSession();
      if (loginController.storage.read('user_uid') != null) {
        Get.offAll(() => Homepage());
      } else {
        Get.to(() => OnBoardingScreen());
      }
    });
    super.onInit();
  }
}
