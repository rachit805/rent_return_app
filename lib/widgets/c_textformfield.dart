import 'package:flutter/material.dart';

class CTextformfield extends StatelessWidget {
  const CTextformfield(
      {super.key,
      this.maxlength,
      this.keyboardType,
      required this.controller,
      required this.label});
  final int? maxlength;
  final TextInputType? keyboardType;
  final TextEditingController controller;
  final String label;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: TextFormField(
        maxLength: maxlength,
        controller: controller,
        keyboardType: keyboardType,
        cursorColor: Colors.black.withOpacity(0.4),
        decoration: InputDecoration(
            counterText: "",
            contentPadding:
                const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.5),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.2),
              ),
            ),
            labelText: label,
            labelStyle: TextStyle(
              color: Colors.black.withOpacity(0.7),
              fontFamily: "Roboto",
              fontWeight: FontWeight.w300,
              fontSize: 16,
            )),
      ),
    );
    ();
  }
}
