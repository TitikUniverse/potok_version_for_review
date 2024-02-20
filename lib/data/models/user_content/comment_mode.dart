import 'dart:convert';

import '../user/user_info_model.dart';

// List<UserPostCommentModel> UserPostCommentModelsFromRawJson(String str) {
//   return List<UserPostCommentModel>.from(json.decode(str).map((x) => UserPostCommentModel.fromRawJson(x)));
// }

class UserPostCommentModel {
    UserPostCommentModel({
        required this.id,
        required this.author,
        required this.dateTimeStamp,
        required this.text,
        required this.postId,
        required this.isLiked,
        required this.isDelete,
        required this.likeAmount,
    });

    final int id;
    final UserInfoModel author;
    final String? text;
    final DateTime dateTimeStamp;
    final int postId;
    bool isDelete;
    bool isLiked;
    int likeAmount;
    factory UserPostCommentModel.fromRawJson(String str) => UserPostCommentModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory UserPostCommentModel.fromJson(Map<String, dynamic> json) => UserPostCommentModel(
        id: json["id"],
        author: UserInfoModel.fromJson(json["author"]),
        dateTimeStamp: DateTime.parse(json["dateTimeStamp"]).add(DateTime.now().timeZoneOffset),
        text: json["text"],
        postId: json["postId"],
        isLiked: json["isLiked"],
        isDelete: json["isDelete"],
        likeAmount: json["likeAmount"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "author": UserInfoModel(id: author.id, nickname: author.nickname, name: author.name, email: author.email, description: author.description, linkInBio: author.linkInBio, medalsAmount: author.medalsAmount, isDeleted: author.isDeleted, avatarUrl: author.avatarUrl).toJson(),
        "dateTimeStamp": dateTimeStamp.toIso8601String(),
        "text": text,
        "postId": postId,
        "isLiked": isLiked,
        "isDelete": isDelete,
        "likeAmount": likeAmount,
    };

  static List<UserPostCommentModel> listPostCommentFromRawJson(String str) => List<UserPostCommentModel>.from(json.decode(str).map((x) => UserPostCommentModel.fromJson(x)));

  static List<UserPostCommentModel> listPostCommentFromJson(List<dynamic> data) => List<UserPostCommentModel>.from(data.map((e) => UserPostCommentModel.fromJson(e)));
}