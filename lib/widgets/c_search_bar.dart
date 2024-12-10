import 'package:flutter/material.dart';
import 'package:rent_and_return/utils/strings.dart';
import 'package:rent_and_return/utils/theme.dart';

Widget csearchbar(double sW, String hintText) {
  return Row(
    children: [
      SizedBox(
        width: sW * 0.75,
        height: 50,
        child: Center(
          child: TextFormField(
            textAlignVertical: TextAlignVertical.center,
            cursorColor: Colors.black.withOpacity(0.4),
            decoration: InputDecoration(
                labelText: hintText,
                labelStyle: const TextStyle(
                    fontFamily: "Roboto",
                    fontSize: 13,
                    fontWeight: FontWeight.w400),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 30),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40),
                  borderSide: BorderSide(
                    color: liteBorderColor,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide:
                        BorderSide(color: AppTheme.theme.primaryColor))),
          ),
        ),
      ),
      const Expanded(child: SizedBox()),
      // cspacingWidth(sW * 0.03),
      CircleAvatar(
        backgroundColor: AppTheme.theme.primaryColor,
        radius: sW * 0.05,
        child: Center(
          child: Icon(Icons.search, color: Colors.white, size: sW * 0.065),
        ),
      )
    ],
  );
}
