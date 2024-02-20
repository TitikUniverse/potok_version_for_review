import 'dart:convert';

class UserBlockCheckModel {
    UserBlockCheckModel({
        required this.isCurrentUserBlocked,
        required this.isUserBlocked,
    });

    final bool isCurrentUserBlocked;
    final bool isUserBlocked;

    factory UserBlockCheckModel.fromRawJson(String str) => UserBlockCheckModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory UserBlockCheckModel.fromJson(Map<String, dynamic> json) => UserBlockCheckModel(
        isCurrentUserBlocked: json["isCurrentUserBlocked"],
        isUserBlocked: json["isUserBlocked"],
    );

    Map<String, dynamic> toJson() => {
        "isCurrentUserBlocked": isCurrentUserBlocked,
        "isUserBlocked": isUserBlocked,
    };
}