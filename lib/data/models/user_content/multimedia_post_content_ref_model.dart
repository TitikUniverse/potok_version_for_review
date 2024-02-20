import 'dart:convert';


List<MultimediaPostContentRef> multimediaPostContentRefFromJson(String? str) {
  if (str == null || str.isEmpty) { throw ArgumentError('Список мультимедиа контента оказался пустым'); }
  return List<MultimediaPostContentRef>.from(json.decode(str).map((x) => MultimediaPostContentRef.fromJson(x)));
}

String multimediaPostContentRefToJson(List<MultimediaPostContentRef> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class MultimediaPostContentRef {
    MultimediaPostContentRef({
        required this.contentUrl,
    });

    final String contentUrl;

    factory MultimediaPostContentRef.fromRawJson(String str) => MultimediaPostContentRef.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory MultimediaPostContentRef.fromJson(Map<String, dynamic> json) => MultimediaPostContentRef(
        contentUrl: json["contentUrl"],
    );

    Map<String, dynamic> toJson() => {
        "contentUrl": contentUrl,
    };
}
