  import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:rent_and_return/utils/theme.dart';

import '../controller/onboarding_controller.dart';

GestureDetector buildDot(BuildContext context, int index,OnBoardingController controller ) {
    // final OnBoardingController controller = Get.find();
    return GestureDetector(
      onTap: () {
        controller.pageController.jumpToPage(index);
      },
      child: Container(
        height: 10,
        width: controller.currentIndex.value == index ? 20 : 10,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: controller.currentIndex.value == index
              ? AppTheme.theme.primaryColor
              : const Color.fromRGBO(223, 223, 223, 1),
        ),
      ),
    );
  }
