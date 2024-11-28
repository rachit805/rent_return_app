import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rent_and_return/data/onboarding_data.dart';
import 'package:rent_and_return/ui/auth/login_screen.dart';

class OnBoardingController extends GetxController {
  final RxInt currentIndex = 0.obs;
  final PageController pageController = PageController();

  void onPageChanged(int index) {
    currentIndex.value = index;
  }

  void nextPage() {
    if (currentIndex.value < onboardingData.length - 1) {
      currentIndex.value++;
      pageController.animateToPage(
        currentIndex.value,
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    } else {
      Get.to(() =>  LogInScreen());
    }
  }

  void skip() {
    Get.to(() =>  LogInScreen());
  }
}
