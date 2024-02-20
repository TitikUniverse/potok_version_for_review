import 'dart:convert';

import '../user/user_info_model.dart';

class AuthInfoModel {
  AuthInfoModel({
        this.token,
        this.refreshToken,
        this.userInfoModel
    });

    final String? token;
    final String? refreshToken;
    final UserInfoModel? userInfoModel;

    factory AuthInfoModel.fromRawJson(String str) => AuthInfoModel.fromJson(json.decode(str));

    factory AuthInfoModel.fromJson(Map<String, dynamic> json) => AuthInfoModel(
        token: json["token"],
        refreshToken: json["refreshToken"],
        userInfoModel: UserInfoModel.fromJson(json["userInfo"])
    );
}