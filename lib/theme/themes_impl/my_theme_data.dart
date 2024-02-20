import 'package:flutter/material.dart';

class MyThemeData {
  late ThemeData themeData; // important!
  final Brightness brightness;
  final Color backgroundColor;
  final Color frontColor;
  final Color iconColor;
  final Color brandColor;
  final Color shadowColor;
  final TextTheme textTheme;
  final Color textColor;
  final Color textColorInverted;
  final ExtraordinaryColors extraordinaryColors;

  MyThemeData({
    required this.themeData,
    required this.brightness,
    required this.backgroundColor,
    required this.frontColor,
    required this.iconColor,
    required this.brandColor,
    required this.shadowColor,
    required this.textTheme,
    required this.textColor, 
    required this.textColorInverted,
    required this.extraordinaryColors
  });
}

class ExtraordinaryColors {
  final Color verifiedColor;
  final Color potokSignColor;
  final Color usualThingColor;
  final Color posterBigTextColor;

  ExtraordinaryColors({
    required this.verifiedColor,
    required this.potokSignColor,
    required this.usualThingColor,
    required this.posterBigTextColor
  });
}