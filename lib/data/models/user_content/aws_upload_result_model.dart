import 'dart:convert';

class AwsUploadResultModel {
  AwsUploadResultModel({
    this.status,
    this.statusCode,
    this.data,
  });

  final bool? status;
  final int? statusCode;
  final String? data;

  factory AwsUploadResultModel.fromRawJson(String str) =>
      AwsUploadResultModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AwsUploadResultModel.fromJson(Map<String, dynamic> json) =>
      AwsUploadResultModel(
        status: json["status"],
        statusCode: json["statusCode"],
        data: json["data"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "statusCode": statusCode,
        "data": data,
      };
}