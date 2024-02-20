
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'my_theme_data.dart';

final darkAppTheme = MyThemeData(
  themeData: ThemeData(
    useMaterial3: false, // не делать true, а то всё сломается
    // platform: TargetPlatform.iOS,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(
      textTheme: CupertinoTextThemeData(), // This is required
    ),
    fontFamily: 'Cera Pro',
    brightness: Brightness.dark
  ),
  brightness: Brightness.dark,
  backgroundColor: const Color.fromARGB(255, 36, 36, 37), //const Color(0xFF1f1f1f),
  frontColor: const Color.fromARGB(255, 47, 47, 47),
  iconColor: const Color(0xFF818181),
  brandColor: const Color.fromARGB(255, 207, 166, 107),
  shadowColor: const Color(0xFF1E1E1E),
  textColor: Colors.white,
  textColorInverted: Colors.black,
  extraordinaryColors: ExtraordinaryColors(
    potokSignColor: const Color.fromARGB(255, 255, 229, 180),
    verifiedColor: const Color.fromARGB(255, 253, 197, 87),
    usualThingColor: const Color.fromARGB(255, 68, 99, 139),
    posterBigTextColor: const Color(0xffDBC8AA)
  ),
  textTheme: const TextTheme()
);