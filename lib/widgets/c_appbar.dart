import 'package:flutter/material.dart';
import 'package:rent_and_return/utils/theme.dart';

class CAppbar extends StatelessWidget {
  const CAppbar(
      {super.key,
      required this.title,
      this.action,
      this.bgColor,
      this.textcolor,
      this.leadingIconColor,
      this.labelColor, required this.leading});
  final String title;
  final List<Widget>? action;
  final Color? bgColor;
  final Color? textcolor;
  final Color? leadingIconColor;
  final Color? labelColor;
  final bool leading;
  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: IconThemeData(color: leadingIconColor, size: 30),
      actions: action,
      automaticallyImplyLeading:leading,
      centerTitle: true,
      backgroundColor: bgColor,
      title: Text(
        title,
        style: TextStyle(
                fontFamily: "Roboto",
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: labelColor)
            .copyWith(color: textcolor),
      ),
    );
  }
}

class IconButtonWithLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? textColor;
  final Color? iconColor;
  const IconButtonWithLabel({
    Key? key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.textColor,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            weight: 50,
            size: 28,
            color: iconColor,
          ),
          const SizedBox(height: 2), // Space between icon and label
          Text(
            label,
            style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontFamily: "Roboto",
                    fontSize: 12,
                    color: AppTheme.theme.primaryColor)
                .copyWith(color: textColor), // Small label text
          ),
        ],
      ),
    );
  }
}
