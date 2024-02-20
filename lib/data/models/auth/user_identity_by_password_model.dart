import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../utils/package_info.dart';

class UserIdentityByPasswordModel {
  UserIdentityByPasswordModel({
    required this.nickname,
    required this.password
  });

  String nickname;
  String password;
  final String os = kIsWeb ? 'Web' : Platform.operatingSystem;
  final String osVer = kIsWeb ? 'Web' : Platform.operatingSystemVersion;
  final String appVer = '${ThisPackageInfo.packageInfo.version} (${ThisPackageInfo.packageInfo.buildNumber})';

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
    "nickname": nickname,
    "password": password,
    "os": os,
    "osVer": osVer,
    "appVer": appVer
  };
}