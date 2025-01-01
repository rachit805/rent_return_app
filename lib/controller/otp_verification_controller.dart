import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:rent_and_return/controller/login_controller.dart';
import 'package:rent_and_return/ui/bottom_nav_bar/homepage.dart';
import 'package:rent_and_return/ui/inventory/empty_inventory_screen.dart';
import 'package:rent_and_return/widgets/error_snackbar.dart';
import 'package:uuid/uuid.dart';

class OtpVerificationController extends GetxController {
  var secondsRemaining = 60.obs;
  var canResend = false.obs;
  var phoneNumber = ''.obs;
  var isOTPSent = false.obs;
  var verificationId = ''.obs;
  FirebaseAuth auth = FirebaseAuth.instance;

  final TextEditingController fieldOne = TextEditingController();
  final TextEditingController fieldTwo = TextEditingController();
  final TextEditingController fieldThree = TextEditingController();
  final TextEditingController fieldFour = TextEditingController();
  final TextEditingController fieldFive = TextEditingController();
  final TextEditingController fieldSix = TextEditingController();

  final LoginController _loginController = Get.put(LoginController());

  @override
  void onInit() {
    super.onInit();
    startTimer();
    verificationId = _loginController.verificationId;
    // print(verificationId.value);
  }
final storage = GetStorage(); // GetStorage instance
  final uuid = Uuid();

  // Starts the timer
  void startTimer() {
    canResend.value = false;
    secondsRemaining.value = 60;

    Future.delayed(const Duration(seconds: 1), _decreaseTime);
  }

  void _decreaseTime() {
    if (secondsRemaining.value > 0) {
      secondsRemaining.value--;
      Future.delayed(const Duration(seconds: 1), _decreaseTime);
    } else {
      canResend.value = true;
    }
  }

  void verifyOTP() async {
    final String otp =
        "${fieldOne.text}${fieldTwo.text}${fieldThree.text}${fieldFour.text}${fieldFive.text}${fieldSix.text}";

    // Check if all OTP fields are filled
    if (otp.length < 6) {
      showErrorSnackbar("Wrong OTP", "Please fill all digit OTP");
      return;
    }

    isOTPSent.value = true; // Set to true before verification starts
    try {
      // Verify the OTP
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value,
        smsCode: otp,
      );
      await auth.signInWithCredential(credential);
        _handleSuccessfulLogin();
  
      // Navigate to the desired screen on successful verification
      Get.offAll(() => const EmptyInventoryScreen());
      isOTPSent.value = false; // Reset the flag after successful verification  
    } catch (e) {
      // Show error message for invalid OTP or other issues
      showErrorSnackbar("Error", e.toString());
      isOTPSent.value = false; // Reset the flag on failure as well
    }
  }

  void resendOTP() {
    startTimer();
    if (phoneNumber.value.isNotEmpty) {
      _loginController.sendOTP();
    } else {
      showErrorSnackbar("Error", "Please enter a valid phone number first");
    }
  }
  // Handle successful login
  void _handleSuccessfulLogin() {
    // Generate and store user UID
    String userUID = uuid.v4();
    storage.write('user_uid', userUID);

    // Navigate to the main screen
    Get.offAll(() => Homepage(initialPage: 2,));
  }

  // Check login session
  void checkLoginSession() {
    String? userUID = storage.read('user_uid');
    if (userUID != null) {
      Get.offAll(() => Homepage(initialPage: 2,));
    }
  }
}
