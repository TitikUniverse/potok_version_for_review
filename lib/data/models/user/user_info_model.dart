import 'dart:convert';

import '../user_content/user_multimedia_post_model.dart';

class UserInfoModel {
    UserInfoModel({
        required this.id,
        required this.nickname,
        this.name,
        this.email,
        this.description,
        this.linkInBio,
        this.medalsAmount,
        this.accountHeaderUrl,
        required this.isDeleted,
        this.isVerifiedAccount,
        this.isAuthorOfQualityContent,
        this.isFriend,
        this.avatarUrl,
        this.lastPost
    });

    final int id;
    final String nickname;
    final String? name;
    final String? email;
    final String? description;
    final String? linkInBio;
    final int? medalsAmount;
    String? accountHeaderUrl;
    final bool isDeleted;
    final bool? isVerifiedAccount;
    final bool? isAuthorOfQualityContent;
    final bool? isFriend;
    String? avatarUrl;
    UserMultimediaPostModel? lastPost;

    factory UserInfoModel.fromRawJson(String str) => UserInfoModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory UserInfoModel.fromJson(Map<String, dynamic> json) {
        String? _trimProperty(dynamic value) {
          return (value as String?)?.trim().replaceAll('\u3164', '') == '' ? null : value;
        }
      
        return UserInfoModel(
          id: json["id"],
          nickname: json["nickname"],
          email: _trimProperty(json["email"]),
          name: _trimProperty(json["name"]),
          description: _trimProperty(json["description"]),
          linkInBio:_trimProperty(json["linkInBio"]),
          medalsAmount: json["medalsAmount"],
          accountHeaderUrl: json["accountHeaderUrl"],
          isDeleted: json["isDeleted"],
          isVerifiedAccount: json["isVerifiedProfile"] ?? false,
          isAuthorOfQualityContent: json["isAuthorOfQualityContent"] ?? false,
          isFriend: json["isFriend"],
          avatarUrl: json["avatarUrl"],
          lastPost: json['lastPost'] == null ? null : UserMultimediaPostModel.fromJson(json['lastPost'])
      );
    }

    Map<String, dynamic> toJson() => {
        "id": id,
        "nickname": nickname,
        "email": email,
        "name": name,
        "description": description,
        "linkInBio": linkInBio,
        "medalsAmount": medalsAmount,
        "accountHeaderUrl": accountHeaderUrl,
        "isDeleted": isDeleted,
        "isVerifiedProfile": isVerifiedAccount,
        "isAuthorOfQualityContent": isAuthorOfQualityContent,
        "avatarUrl": avatarUrl,
        "lastPost": lastPost?.toJson()
    };

    bool get hasBioInfo {
      if (linkInBio == null && description == null) return false;
      if (linkInBio == '' && description == '') return false;
      return true;
    }

    bool get hasLinkInBio => linkInBio != null && linkInBio != '';

    static List<UserInfoModel> fromRawJsonList(String str) => List<UserInfoModel>.from(json.decode(str).map((x) => UserInfoModel.fromJson(x)));
    static String toJsonList(List<UserInfoModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
    static List<UserInfoModel> fromJsonList(List<dynamic> data) => List<UserInfoModel>.from(data.map((e) => UserInfoModel.fromJson(e)));
}