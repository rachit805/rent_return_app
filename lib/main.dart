import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:rent_and_return/ui/auth/login_screen.dart';
import 'package:rent_and_return/ui/auth/otp_verification_screen.dart';
import 'package:rent_and_return/ui/inventory/home_screen.dart';
import 'package:rent_and_return/ui/bottom_nav_bar/homepage.dart';
import 'package:rent_and_return/ui/inventory/add_inventory_screen.dart';
import 'package:rent_and_return/ui/inventory/empty_inventory_screen.dart';
import 'package:rent_and_return/ui/inventory/item_detail_screen.dart';
import 'package:rent_and_return/ui/welcomeUI/onboarding_screen.dart';
import 'package:rent_and_return/ui/welcomeUI/splash_screen.dart';
import 'package:rent_and_return/utils/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sqflite/sqflite.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    await GetStorage.init(); // Initialize GetStorage

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Rent & Return',
      theme: AppTheme.theme,
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
