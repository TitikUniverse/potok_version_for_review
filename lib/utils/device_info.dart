import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfo {
  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  String get clientType => Platform.isIOS ? 'ios' : 'android';

  Future<String> get deviceId async {
    try {
      if (Platform.isIOS) {
        return (await deviceInfoPlugin.iosInfo).identifierForVendor ??
            'ios_unknown';
      } else if (Platform.isAndroid) {
        return (await deviceInfoPlugin.androidInfo).id;
      }
      return 'unknown';
    } catch (e) {
      return 'unknown';
    }
  }
}
