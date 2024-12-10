// lib/theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      scaffoldBackgroundColor: Colors.white,
      primaryColor: const Color.fromARGB(255, 65, 149, 204),
      secondaryHeaderColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.white),

// rgb(118, 159, 187)
// AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Color.fromARGB(255, 65, 149, 204),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontFamily: 'Roboto',
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),

      // ElevatedButton theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              const Color.fromARGB(255, 65, 149, 204), // Button color
          textStyle: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Text theme for consistent typography
      textTheme: TextTheme(
        //
        headlineLarge: TextStyle(
            fontFamily: "Roboto",
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600),
        //
        bodyLarge: const TextStyle(
          color: Color.fromARGB(255, 65, 149, 204),
          fontSize: 20,
          fontFamily: "Roboto",
          fontWeight: FontWeight.w500,
        ),
        //
        bodySmall: const TextStyle(
            color: Color.fromARGB(255, 65, 149, 204),
            fontSize: 16,
            fontFamily: "Roboto"),
        //
        labelMedium: const TextStyle(
          fontFamily: "Roboto",
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        labelSmall: const TextStyle(fontSize: 10, fontWeight: FontWeight.w200),
      ),
    );
  }
}
