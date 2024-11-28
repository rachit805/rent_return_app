import 'package:flutter/material.dart';

Widget timerContainer(Widget child) {
  return Container(
    height: 25,
    width: 50,
    decoration: BoxDecoration(
      color: Colors.grey[100],
      border: Border.all(
        color: Colors.grey.withOpacity(0.5),
      ),
    ),
    child: Center(child: child),
  );
}
