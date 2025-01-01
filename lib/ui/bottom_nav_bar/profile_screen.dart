import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rent_and_return/controller/profile_controller.dart';
import 'package:rent_and_return/utils/theme.dart';
import 'package:rent_and_return/widgets/c_btn.dart';
import 'package:rent_and_return/widgets/c_sizedbox.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});
  final ProfileController controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    double sW = MediaQuery.of(context).size.width;
    double sH = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            "assets/images/profilebgimage.jpg",
            height: sH * 0.25,
            width: double.infinity,
            fit: BoxFit.fill,
          ),
          Padding(
            padding: EdgeInsets.only(top: sH * 0.05),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white70,
                child: Icon(Icons.arrow_back),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: sH * 0.2),
            child: Obx(
              () => InkWell(
                onTap: () {
                  print("Tap ... "); // Debug print
                  controller.pickImage(); // Call the pickImage function
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.black,
                    backgroundImage: controller.imagePath.value.isNotEmpty
                        ? FileImage(File(controller.imagePath.value))
                        : null,
                    child: controller.imagePath.value.isEmpty
                        ? const Icon(
                            Icons.camera,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(top: sH * 0.3),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Company Name",
                      style: AppTheme.theme.textTheme.labelLarge
                          ?.copyWith(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    cspacingHeight(sH * 0.05),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 15,
                          backgroundColor:
                              AppTheme.theme.primaryColor.withOpacity(0.6),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                          ),
                        ),
                        Spacing.h15,
                        SizedBox(
                          height: 20,
                          width: sW * 0.75,
                          child: TextFormField(
                            readOnly: true,
                            controller: controller.ownerNameController,
                            decoration: const InputDecoration(
                                // labelText: "Company Name",
                                hintText: "Company Name",
                                suffixIcon: Padding(
                                  padding: EdgeInsets.only(left: 25),
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.black,
                                    size: 22,
                                  ),
                                )),
                          ),
                        ),
                      ],
                    ),
                    cspacingHeight(sH * 0.04),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 15,
                          backgroundColor:
                              AppTheme.theme.primaryColor.withOpacity(0.6),
                          child: const Icon(
                            Icons.phone,
                            color: Colors.white,
                          ),
                        ),
                        Spacing.h15,
                        SizedBox(
                          height: 20,
                          width: sW * 0.75,
                          child: TextFormField(
                            readOnly: true,
                            controller: controller.phoneNumberController,
                            decoration: const InputDecoration(
                                hintText: "Mobile Number",
                                // labelText: "Mobile Number",
                                suffixIcon: Padding(
                                  padding: EdgeInsets.only(left: 25),
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.black,
                                    size: 22,
                                  ),
                                )),
                          ),
                        ),
                      ],
                    ),
                    Spacing.v20,
                    Text(
                      "Business Identity",
                      style: AppTheme.theme.textTheme.labelLarge
                          ?.copyWith(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    cspacingHeight(sH * 0.04),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 15,
                          backgroundColor:
                              AppTheme.theme.primaryColor.withOpacity(0.6),
                          child: const Icon(
                            Icons.edit_document,
                            color: Colors.white,
                          ),
                        ),
                        Spacing.h15,
                        SizedBox(
                          height: 20,
                          width: sW * 0.75,
                          child: TextFormField(
                            controller: controller.gstNumberController,
                            decoration: const InputDecoration(
                                hintText: "GST Number",
                                suffixIcon: Padding(
                                  padding: EdgeInsets.only(left: 25),
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.black,
                                    size: 22,
                                  ),
                                )),
                          ),
                        ),
                      ],
                    ),
                    cspacingHeight(sH * 0.04),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 15,
                          backgroundColor:
                              AppTheme.theme.primaryColor.withOpacity(0.6),
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.white,
                          ),
                        ),
                        Spacing.h15,
                        SizedBox(
                          height: 20,
                          width: sW * 0.75,
                          child: TextFormField(
                            controller: controller.addressController,
                            decoration: const InputDecoration(
                                hintText: "Address",
                                suffixIcon: Padding(
                                  padding: EdgeInsets.only(left: 25),
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.black,
                                    size: 22,
                                  ),
                                )),
                          ),
                        ),
                      ],
                    ),
                    cspacingHeight(sH * 0.03),
                    Text(
                      "Terms & Conditions",
                      style: AppTheme.theme.textTheme.labelLarge
                          ?.copyWith(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    TextFormField(
                      controller: controller.termsController,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(8.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade700),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade700),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                      ),
                      style: const TextStyle(fontSize: 16.0),
                    ),
                    cspacingHeight(sH * 0.04),
                    cBtn("Save", () => controller.saveData(), Colors.white),
                    Spacing.v20,
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
