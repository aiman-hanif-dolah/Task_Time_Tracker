import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final OutlinedBorder? shape;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.fontWeight,
    this.width,
    this.height,
    this.margin,
    this.padding,
    this.shape,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSpecialButton = ['Login', 'Register', 'Reset'].contains(text);
    final buttonFontSize = isSpecialButton ? 22.0 : 17.0;
    final defaultWidth = isSpecialButton ? 120.0 : null;

    if (isSpecialButton) {
      // ElevatedButton for special buttons
      return Container(
        margin: margin ?? const EdgeInsets.only(top: 20),
        padding: padding ?? EdgeInsets.zero,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? const Color(0xFF1800e7),
            shape: shape ?? RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
            elevation: 2,
          ),
          child: Container(
            alignment: Alignment.center,
            width: width ?? defaultWidth,
            height: height ?? 50.0,
            child: Text(
              text,
              style: TextStyle(
                color: textColor ?? Colors.white,
                fontSize: fontSize ?? buttonFontSize,
                fontWeight: fontWeight ?? FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    } else {
      // TextButton for non-special buttons
      return Container(
        margin: margin ?? const EdgeInsets.only(top: 10),
        padding: padding ?? EdgeInsets.zero,
        child: TextButton(
          onPressed: onPressed,
          child: Text(
            text,
            style: TextStyle(
              color: textColor ?? Colors.black,
              fontSize: fontSize ?? buttonFontSize,
              fontWeight: fontWeight ?? FontWeight.bold,
            ),
          ),
        ),
      );
    }
  }
}
