import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    this.isPhone = false,
    this.isLandline = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.isDense = false,
    this.onTap,
    this.errorStyle,
    this.onFieldSubmitted,
    this.focusNode,
  });

  final TextEditingController controller;
  final String? hintText;
  final String? Function(String?)? validator;
  final bool isPassword;
  final bool isEmail;
  final bool isPhone;
  final bool isLandline;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final Function(String)? onChanged;
  final bool readOnly;
  final int? maxLines;
  final bool? isDense;
  final VoidCallback? onTap;
  final TextStyle? errorStyle;
  final Function(String)? onFieldSubmitted;
  final FocusNode? focusNode;

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
      readOnly: widget.readOnly,
      maxLines: widget.maxLines,
      onTap: widget.onTap,
      onFieldSubmitted: widget.onFieldSubmitted,
      focusNode: widget.focusNode,
      inputFormatters: widget.isPhone || widget.isLandline
          ? [
              FilteringTextInputFormatter.digitsOnly,
              widget.isLandline
                  ? LengthLimitingTextInputFormatter(10)
                  : LengthLimitingTextInputFormatter(11),
            ]
          : null,
      keyboardType: widget.isEmail
          ? TextInputType.emailAddress
          : widget.isPhone || widget.isLandline
          ? TextInputType.phone
          : TextInputType.text,
      decoration: InputDecoration(
        isDense: widget.isDense,
        hintText: widget.hintText,
        errorStyle: widget.errorStyle,
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
