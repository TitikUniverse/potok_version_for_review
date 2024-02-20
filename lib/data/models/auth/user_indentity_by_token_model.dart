import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../utils/package_info.dart';

class UserIdentityByTokenModel {
  UserIdentityByTokenModel({
    required this.token
  });

  String token;
  final String os = kIsWeb ? 'Web' : Platform.operatingSystem;
  final String osVer = kIsWeb ? 'Web' : Platform.operatingSystemVersion;
  final String appVer = '${ThisPackageInfo.packageInfo.version} (${ThisPackageInfo.packageInfo.buildNumber})';

  factory UserIdentityByTokenModel.fromRawJson(String str) =>
      UserIdentityByTokenModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserIdentityByTokenModel.fromJson(Map<String, dynamic> json) =>
      UserIdentityByTokenModel(
        token: json["token"]
      );

  Map<String, dynamic> toJson() => {
    "token": token,
    "os": os,
    "osVer": osVer,
    "appVer": appVer
  };
}