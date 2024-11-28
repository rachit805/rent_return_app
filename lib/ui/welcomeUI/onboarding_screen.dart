import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rent_and_return/controller/onboarding_controller.dart';
import 'package:rent_and_return/data/onboarding_data.dart';
import 'package:rent_and_return/utils/strings.dart';
import 'package:rent_and_return/utils/theme.dart';
import 'package:rent_and_return/widgets/c_indicator_dots.dart';
import 'package:rent_and_return/widgets/c_sizedbox.dart';

class OnBoardingScreen extends StatelessWidget {
  OnBoardingScreen({super.key});

  final OnBoardingController controller = Get.put(OnBoardingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              onPageChanged: controller.onPageChanged,
              controller: controller.pageController,
              scrollDirection: Axis.horizontal,
              itemCount: onboardingData.length,
              itemBuilder: (_, i) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      onboardingData[i].image,
                      fit: BoxFit.fill,
                      width: double.infinity,
                    ),
                    Spacing.v20,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        onboardingData[i].description,
                        style: AppTheme.theme.textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                    onPressed: () {
                      controller.skip();
                    },
                    child: Text("Skip",
                        style: AppTheme.theme.textTheme.bodySmall)),
                Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      onboardingData.length,
                      (index) => buildDot(context, index, controller),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    controller.nextPage();
                  },
                  icon: CircleAvatar(
                    backgroundColor: AppTheme.theme.primaryColor,
                    child: const Center(
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: iconColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Spacing.v15
        ],
      ),
    );
  }
}
