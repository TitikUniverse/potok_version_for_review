import 'dart:async';
import 'dart:io';

import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'services/locator.dart';
import 'theme/potok_theme.dart';
import 'ui/app/app.dart';
import 'utils/package_info.dart';

void main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await EasyLocalization.ensureInitialized();
      await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      if (!kIsWeb) {
        if (Platform.isAndroid || Platform.isIOS) {
          AppMetrica.activate(const AppMetricaConfig('36eaa062-b1fc-40e0-912d-2b2bb0d0ca94'));
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
          // SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          //   systemNavigationBarColor: Constant.frontColor,
          // ));
          if (!kIsWeb) {
            if (Platform.isIOS) {
              OneSignal.shared.setAppId("58da0980-c399-441f-aedc-2fd6e59a6ed0");
            } else if (Platform.isAndroid) {
              OneSignal.shared.setAppId("269c226e-1090-436a-b37b-60720954f467");
            }
            OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
              if (kDebugMode) {
                print("Accepted permission: $accepted");
              }
            });
          }
          await ThisPackageInfo().init();
        }
      }
      else {
        usePathUrlStrategy();
      }
      await setupLocator();
      initTheme();
      runApp(locale(child: App()));
    },
    (Object error, StackTrace stack) { }
  );
}

Widget locale({required Widget child}) {
  return EasyLocalization(
    supportedLocales: const [
      Locale('ru', 'RU'),
      Locale('en', 'US'),
    ],
    startLocale: const Locale('ru', 'RU'),
    fallbackLocale: const Locale('ru', 'RU'),
    path: 'assets/translations',
    child: child,
  );
}