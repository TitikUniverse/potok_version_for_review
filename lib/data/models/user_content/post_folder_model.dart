// To parse this JSON data, do
//
//     final postFolderModel = postFolderModelFromJson(jsonString);

import 'dart:convert';

List<PostFolderModel> postFolderModelFromJson(String str) {
  List<PostFolderModel> result = List<PostFolderModel>.from(json.decode(str).map((x) => PostFolderModel.fromJson(x)));
  result.sort((a, b) => a.position.compareTo(b.position));
  return result;
}

String postFolderModelToJson(List<PostFolderModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PostFolderModel {
    PostFolderModel({
        required this.id,
        required this.name,
        this.position = 0,
        required this.postCount
    });

    final int id;
    String name;
    int position;
    int postCount;

    factory PostFolderModel.fromJson(Map<String, dynamic> json) => PostFolderModel(
        id: json["id"] ?? -1,
        name: json["name"] ?? "Главная",
        position: json["id"] == null ? -1 : json["position"] ?? 0,
        postCount: json["postCount"]
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "position": position,
        "postCount": postCount
    };
}
