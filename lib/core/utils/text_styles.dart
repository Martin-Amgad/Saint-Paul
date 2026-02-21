import 'package:flutter/widgets.dart';

class TextStyles {
  static TextStyle getSize30({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 30,
      color: color,
      fontWeight: fontWeight,
    );
  }

  static TextStyle getSize24({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 24,
      color: color,
      fontWeight: fontWeight,
    );
  }

  static TextStyle getSize18({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 18,
      color: color,
      fontWeight: fontWeight,
    );
  }

  static TextStyle getSize16({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 16,
      color: color,
      fontWeight: fontWeight,
    );
  }

  static TextStyle getSize12({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 12,
      color: color,
      fontWeight: fontWeight,
    );
  }
}
