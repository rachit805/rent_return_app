import 'package:flutter/widgets.dart';

class Spacing {
  static const Widget v10 = SizedBox(height: 10);
  static const Widget v15 = SizedBox(height: 15);
  static const Widget v20 = SizedBox(height: 20);
  // Horizontal

  static const Widget h10 = SizedBox(width: 10);
  static const Widget h15 = SizedBox(width: 15);
  static const Widget h20 = SizedBox(width: 20);
}

Widget cspacingHeight(double value) {
  return SizedBox(
    height: value,
  );
}

Widget cspacingWidth(double value) {
  return SizedBox(
    width: value,
  );
}
