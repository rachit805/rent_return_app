import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rent_and_return/helper/get_storage_helper.dart';
import 'dart:io';

import 'package:rent_and_return/widgets/error_snackbar.dart';

class ProfileController extends GetxController {
  final ownerNameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final gstNumberController = TextEditingController();
  final addressController = TextEditingController();
  final termsController = TextEditingController();

  final GetStorageHelper _storageHelper = GetStorageHelper();

  // Observable for image path
  final RxString imagePath = ''.obs;

  @override
  void onInit() {
    super.onInit();
    ownerNameController.text = _storageHelper.getData('ownerName');
    phoneNumberController.text = _storageHelper.getData('phoneNumber');
    gstNumberController.text = _storageHelper.getData('gstNumber');
    addressController.text = _storageHelper.getData('address');
    termsController.text = _storageHelper.getData('terms');

    // Load saved image path
    imagePath.value = _storageHelper.getData('imagePath');
  }

  // Save data to GetStorage
  void saveData() {
    if (ownerNameController.text.isEmpty &&
        phoneNumberController.text.isEmpty &&
        gstNumberController.text.isEmpty &&
        addressController.text.isEmpty &&
        termsController.text.isEmpty &&
        imagePath.isEmpty) {
      showErrorSnackbar("Error", "Fill all the required fields!");

      return;
    }
    _storageHelper.saveData('ownerName', ownerNameController.text);
    _storageHelper.saveData('phoneNumber', phoneNumberController.text);
    _storageHelper.saveData('gstNumber', gstNumberController.text);
    _storageHelper.saveData('address', addressController.text);
    _storageHelper.saveData('terms', termsController.text);
    _storageHelper.saveData('imagePath', imagePath.value);

    showSuccessSnackbar("Saved", "Successfully data saved!");
    print(imagePath.value);
  }

  Future<void> pickImage() async {
    print('tap'); // Debug print
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        print("Image picked: ${image.path}"); // Debug print
        imagePath.value = image.path;
        _storageHelper.saveData('imagePath', image.path);
      } else {
        print("No image selected"); // Debug print
      }
    } catch (e) {
      print("Error picking image: $e"); // Debug print for errors
    }
  }
}
