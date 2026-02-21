import 'package:flutter/material.dart';
import 'package:saint_paul/core/utils/colors.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.validator,
    this.isPassword = false,
    this.suffixIcon,
    this.prefixIcon,
    this.onChanged,
    this.isEmail = false,
  });

  final TextEditingController controller;
  final String? hintText;
  final String? Function(String?)? validator;
  final bool isPassword;
  final bool isEmail;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final Function(String)? onChanged;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool isobscure = true;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      obscureText: widget.isPassword && isobscure,
      onChanged: widget.onChanged,
      keyboardType: widget.isEmail
          ? TextInputType.emailAddress
          : TextInputType.text,
      decoration: InputDecoration(
        hintText: widget.hintText,
        suffixIcon: widget.isPassword
            ? Padding(
                padding: EdgeInsetsGeometry.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isobscure = !isobscure;
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      isobscure
                          ? Icon(
                              Icons.visibility_outlined,
                              color: AppColors.darkColor,
                            )
                          : Icon(
                              Icons.visibility_off_outlined,
                              color: AppColors.darkColor,
                            ),
                    ],
                  ),
                ),
              )
            : widget.suffixIcon,
        prefixIcon: widget.prefixIcon,
      ),
    );
  }
}
