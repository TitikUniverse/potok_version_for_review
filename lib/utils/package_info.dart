import 'package:package_info_plus/package_info_plus.dart';

class ThisPackageInfo {
  static late final PackageInfo packageInfo;

  Future init() async {
    packageInfo = await PackageInfo.fromPlatform();
  }
}