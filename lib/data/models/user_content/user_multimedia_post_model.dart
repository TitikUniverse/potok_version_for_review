import 'dart:convert';

import '../user/user_info_model.dart';
import 'multimedia_post_content_ref_model.dart';
import 'post_content_type.dart';

class UserMultimediaPostModel {
    UserMultimediaPostModel({
        required this.id,
        required this.author,
        required this.dateTimeStamp,
        required this.isDelete,
        required this.contentType,
        this.isParticipateInBattle,
        required this.isLunaPost,
        this.description,
        required this.likeAmount,
        this.savedAmount = -1,
        required this.commentAmount,
        required this.isLiked,
        required this.isSaved,
        this.isArchivated,
        this.objectFit,
        required this.fileView,
        required this.folderId,
        required this.multimediaPostContentRefs,
    });

    final int id;
    final UserInfoModel author;
    final DateTime dateTimeStamp;
    final bool isDelete;
    final PostContentType contentType;
    bool? isParticipateInBattle;
    bool isLunaPost;
    final String? description;
    int likeAmount;
    int savedAmount;
    int commentAmount;
    bool isLiked;
    bool isSaved;
    bool? isArchivated;
    String? objectFit;
    final String fileView;
    int folderId;
    final List<MultimediaPostContentRef> multimediaPostContentRefs;

    factory UserMultimediaPostModel.fromRawJson(String str) => UserMultimediaPostModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory UserMultimediaPostModel.fromJson(Map<String, dynamic> json) {
      return UserMultimediaPostModel(
        id: json["id"],
        author: json["author"] == null ? UserInfoModel(id: -1, nickname: 'null', isDeleted: false) : UserInfoModel.fromJson(json["author"]), // Пользователь с id -1 – это просто заглушка. Это нужно потому что lastPost (в модели юзера) и не всегда имеет автора (в целях оптимизации)
        dateTimeStamp: DateTime.parse(json["dateTimeStamp"]).add(DateTime.now().timeZoneOffset),
        isDelete: json["isDelete"],
        contentType: json.containsKey('contentType') ? postContentTypeFromJson(json['contentType']) : PostContentType.undefined,
        isLunaPost: json["isLunaPost"],
        isParticipateInBattle: json["isParticipateInBattle"],
        description: json["description"],
        likeAmount: json["likeAmount"],
        savedAmount: json["savedAmount"],
        commentAmount: json["commentAmount"],
        isLiked: json["isLiked"],
        isSaved: json["isSaved"],
        isArchivated: json["isArchivated"],
        objectFit: json["objectFit"],
        fileView: json["fileView"],
        folderId: json["folderId"] ?? -1,
        multimediaPostContentRefs: List<MultimediaPostContentRef>.from(json["multimediaPostContentRefs"].map((x) => MultimediaPostContentRef.fromJson(x))),
    );
    }

    Map<String, dynamic> toJson() => {
        "id": id,
        // "author": UserInfoModel(nickname: author.nickname, name: author.name, email: author.email, description: author.description, linkInBio: author.linkInBio, medalsAmount: author.medalsAmount, avatarUrl: author.avatarUrl).toJson(),
        "dateTimeStamp": dateTimeStamp.toIso8601String(),
        "isDelete": isDelete,
        "contentType": contentType.asString(),
        "isParticipateInBattle": isParticipateInBattle,
        "isLunaPost": isLunaPost,
        "description": description,
        "likeAmount": likeAmount,
        "savedAmount": savedAmount,
        "commentAmount": commentAmount,
        "isLiked": isLiked,
        "isSaved": isSaved,
        "isArchivated": isArchivated,
        "objectFit": objectFit,
        "fileView": fileView,
        "folderId": folderId,
        "multimediaPostContentRefs": List<dynamic>.from(multimediaPostContentRefs.map((x) => x.toJson())),
    };

    static List<UserMultimediaPostModel> listMultimediaPostFromRawJson(String str) => List<UserMultimediaPostModel>.from(json.decode(str).map((x) => UserMultimediaPostModel.fromJson(x)));

    static List<UserMultimediaPostModel> listMultimediaPostFromJson(List<dynamic> data) => List<UserMultimediaPostModel>.from(data.map((e) => UserMultimediaPostModel.fromJson(e)));
}