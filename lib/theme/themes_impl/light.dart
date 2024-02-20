import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'my_theme_data.dart';

final lightAppTheme = MyThemeData(
  themeData: ThemeData(
    useMaterial3: false, // не делать true, а то всё сломается
    // platform: TargetPlatform.iOS,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(
      textTheme: CupertinoTextThemeData(), // This is required
    ),
    fontFamily: 'Cera Pro',
    brightness: Brightness.light
  ),
  brightness: Brightness.light,
  backgroundColor: const Color.fromARGB(255, 238, 238, 238),
  frontColor: const Color(0xFFFFFFFF),
  iconColor: const Color(0xFF212121),
  brandColor: const Color.fromARGB(255, 207, 166, 107),
  shadowColor: const Color(0xFFE8E8E8),
  textColor: Colors.black,
  textColorInverted: Colors.white,
  extraordinaryColors: ExtraordinaryColors(
    potokSignColor: const Color.fromARGB(255, 255, 229, 180),
    verifiedColor: const Color.fromARGB(255, 253, 197, 87),
    usualThingColor: const Color.fromARGB(255, 68, 99, 139),
    posterBigTextColor: const Color(0xffDBC8AA)
  ),
  textTheme: const TextTheme()
);