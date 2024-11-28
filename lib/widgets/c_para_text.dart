import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';

Widget cParaText(String text) {
  return Text(text,
      style: TextStyle(
          fontFamily: "Roboto",
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade600));
}

Widget cText(String text, double fontsize, FontWeight weight) {
  return Text(text,
      style: TextStyle(
          fontFamily: "Roboto",
          fontSize: fontsize,
          fontWeight: weight,
          color: Colors.black));
}
