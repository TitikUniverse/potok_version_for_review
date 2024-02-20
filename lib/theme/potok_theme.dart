import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:potok/resources/resource_string.dart';

import '../services/storage/index.dart';
import 'inherited_my_theme.dart';
import 'themes_impl/my_theme_data.dart';

late final ValueNotifier<ThemeMode> _notifier;
ThemeMode activateNextTheme() {
  var dataService = Get.find<StorageDataService>();
  switch (_notifier.value) {
    case ThemeMode.light:
      _notifier.value = ThemeMode.dark;
      dataService.set<String>(kThemeModeKey, ThemeMode.dark.name);
      return _notifier.value;
    case ThemeMode.dark:
      _notifier.value = ThemeMode.system;
      dataService.set<String>(kThemeModeKey, ThemeMode.system.name);
      return _notifier.value;
    case ThemeMode.system:
      _notifier.value = ThemeMode.light;
      dataService.set<String>(kThemeModeKey, ThemeMode.light.name);
      return _notifier.value;
  }
}
void initTheme() {
  ThemeMode themeMode = _getInitThemeMode();
  _notifier = ValueNotifier(themeMode);
}
ThemeMode currentAppTheme(BuildContext context) {
  if (_notifier.value == ThemeMode.system) return MediaQuery.of(context).platformBrightness == Brightness.light ? ThemeMode.light : ThemeMode.dark;
  return _notifier.value;
}
String currentAppThemeAsString() {
  switch (_notifier.value) {
    case ThemeMode.dark:
      return ResourceString.themeDark;
    case ThemeMode.light:
      return ResourceString.themeLight;
    case ThemeMode.system:
      return ResourceString.themeSystem;
  }
}
IconData getCurrentThemeIcon() {
  switch (_notifier.value) {
    case ThemeMode.dark:
      return Icons.wb_sunny_rounded;
    case ThemeMode.light:
      return Icons.nights_stay_rounded;
    case ThemeMode.system:
      return Icons.phone_android_rounded;
  }
}
ThemeMode _getInitThemeMode() {
  var dataService = Get.find<StorageDataService>();
  String? themeMode = dataService.get<String?>(kThemeModeKey);
  if (themeMode == null) return ThemeMode.system;
  return ThemeMode.values.firstWhereOrNull((element) => element.name == themeMode) ?? ThemeMode.system;
}

class PotokTheme extends StatelessWidget {
  final MyThemeData light;
  final MyThemeData dark;
  final Widget child;

  const PotokTheme({super.key, required this.light, required this.dark, required this.child});

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final systemThemeData = brightness == Brightness.light ? light : dark;

    MyThemeData _getMyThemeData(ThemeMode themeMode) {
      if (themeMode == ThemeMode.system) return systemThemeData;
      return themeMode == ThemeMode.light ? light : dark;
    }

    return ValueListenableBuilder(
      valueListenable: _notifier,
      builder: (_, ThemeMode mode, __) {
        MyThemeData myThemeData = _getMyThemeData(mode);
        return InheritedMyTheme(
          data: myThemeData,
          child: Theme(
            data:myThemeData.themeData,
            child: child,
          ),
        );
      }
    );
  }
  static MyThemeData of(BuildContext context){
    final theme = Theme.of(context);
    return context
        .dependOnInheritedWidgetOfExactType<InheritedMyTheme>()!
        .data..themeData = theme;
  }
}