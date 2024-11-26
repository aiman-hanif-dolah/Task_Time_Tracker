import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String content;
  final List<Widget> actions;
  final Color? backgroundColor;
  final Widget? icon;
  final Color? iconColor;
  final TextAlign? textAlign;

  const CustomDialog({
    Key? key,
    required this.title,
    required this.content,
    this.actions = const [],
    this.backgroundColor,
    this.icon,
    this.iconColor,
    this.textAlign = TextAlign.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        textAlign: textAlign,
      ),
      backgroundColor: backgroundColor,
      icon: icon,
      iconColor: iconColor,
      content: Text(
        content,
        style: const TextStyle(fontSize: 15),
        textAlign: textAlign,
      ),
      actions: actions,
    );
  }
}
