import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rent_and_return/ui/auth/otp_verification_screen.dart';
import 'package:rent_and_return/widgets/error_snackbar.dart';

class LoginController extends GetxController {
  final TextEditingController cnameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  var phoneNumber = ''.obs;
  var otp = ''.obs;
  var isOTPSent = false.obs;
  var verificationId = ''.obs;

  FirebaseAuth auth = FirebaseAuth.instance;
  
  void sendOTP() async {
    if (cnameController.text.isEmpty) {
      showErrorSnackbar("Error", "Please enter company name");
      return;
    }
    if (phoneController.text.length < 10) {
      showErrorSnackbar("Error", "Please enter a 10-digit mobile number");
      return;
    }

    isOTPSent.value = true;
    try {
      await auth.verifyPhoneNumber(
        phoneNumber: "+91${phoneController.text}",
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          showErrorSnackbar("Error", e.message ?? "Verification failed");
          isOTPSent.value = false;
        },
        codeSent: (String verificationId, int? resendToken) {
          this.verificationId.value = verificationId;
          Get.to(() => OtpVerificationScreen(phone: phoneController.text));
          isOTPSent.value = false;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          this.verificationId.value = verificationId;
        },
      );
    } catch (e) {
      showErrorSnackbar("Error", e.toString());
      isOTPSent.value = false;
    }
  }

  Future<void> verifyOTP(String otp) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value,
        smsCode: otp,
      );
      await auth.signInWithCredential(credential);
    } catch (e) {
      showErrorSnackbar("Error", "Invalid OTP. Please try again.");
    }
  }

  
}
