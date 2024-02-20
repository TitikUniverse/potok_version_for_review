
import 'dart:convert';

import 'multimedia_post_content_ref_model.dart';
import 'post_content_type.dart';

class UserNewMultimediaPost {
    UserNewMultimediaPost({
        required this.authorId,
        required this.contentType,
        this.description,
        required this.isParticipateInBattle,
        required this.isLunaPost,
        this.objectFit,
        required this.fileView,
        this.folderId,
        this.multimediaPostContentRefs,
    });

    final int authorId;
    PostContentType contentType;
    final String? description;
    final bool isParticipateInBattle;
    final bool isLunaPost;
    final String? objectFit;
    final String fileView;
    final int? folderId;
    final List<MultimediaPostContentRef>? multimediaPostContentRefs;

    factory UserNewMultimediaPost.fromRawJson(String str) => UserNewMultimediaPost.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory UserNewMultimediaPost.fromJson(Map<String, dynamic> json) => UserNewMultimediaPost(
        authorId: json["authorId"],
        description: json["description"],
        contentType: postContentTypeFromJson(json['contentType']),
        isParticipateInBattle: json["isParticipateInBattle"],
        isLunaPost: json["isLunaPost"],
        objectFit: json["objectFit"],
        fileView: json["fileView"],
        folderId: json["folderId"],
        multimediaPostContentRefs: List<MultimediaPostContentRef>.from(json["multimediaPostContentRefs"].map((x) => MultimediaPostContentRef.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "authorId": authorId,
        "description": description,
        "contentType": contentType.asString(),
        "isParticipateInBattle": isParticipateInBattle,
        "isLunaPost": isLunaPost,
        "objectFit": objectFit,
        "fileView": fileView,
        "folderId": folderId,
        "multimediaPostContentRefs": multimediaPostContentRefs == null ? null : List<dynamic>.from(multimediaPostContentRefs!.map((x) => x.toJson())),
    };
}
