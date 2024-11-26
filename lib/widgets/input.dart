import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  final String labelText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool obscureText;
  final Function(String)? onSaved;
  final Function(String)? validator;
  final VoidCallback? suffixIconPressed;
  final double widthFactor;
  final double heightFactor;

  const CustomInputField({
    super.key,
    required this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.onSaved,
    this.validator,
    this.suffixIconPressed,
    this.widthFactor = 0.8,
    this.heightFactor = 0.08,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth * widthFactor,
      height: screenHeight * heightFactor,
      margin: const EdgeInsets.only(top: 10.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: const TextStyle(
              fontSize: 15.0,
              color: Colors.grey,
            ),
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.black) : null,
            suffixIcon: suffixIcon != null
                ? IconButton(
              onPressed: suffixIconPressed,
              icon: Icon(suffixIcon, color: Colors.black),
            )
                : null,
            border: InputBorder.none,
            errorStyle: const TextStyle(
              fontSize: 15.0,
            ),
          ),
          style: const TextStyle(
            fontSize: 15.0,
          ),
          obscureText: obscureText,
          validator: (value) => validator?.call(value ?? ''),
          onSaved: (value) => onSaved?.call(value ?? ''),
        ),
      ),
    );
  }
}
