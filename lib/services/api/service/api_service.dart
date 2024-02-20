
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide FormData, Response;

import '../../../utils/device_info.dart';
import '../../storage/index.dart';
import 'api.dart';
import 'app_interceptor.dart';

class ApiService {
  Future<ApiService> init() async {
    _dio = Dio(await _baseOptions);
    _dio.interceptors.addAll([
      AppInterceptor(
        dio: dio,
        onErrorStatusChanged: (httpStatus) => _httpStatusController.add(httpStatus),
        refreshToken: refreshToken
      ),
        
    ]);
    (_dio.transformer as BackgroundTransformer).jsonDecodeCallback = _parseJson;
    return this;
  }

  final StreamController<int> _httpStatusController =
      StreamController<int>.broadcast();

  late final Dio _dio;

  Dio get dio => _dio;

  Stream<int> get httpStatusStream => _httpStatusController.stream;

  Future<BaseOptions> get _baseOptions async => BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Client-Type': DeviceInfo().clientType,
          'Device-ID': await DeviceInfo().deviceId,
        },
        validateStatus: (int? status) =>
            status! >= HttpStatus.ok && status < HttpStatus.multipleChoices ||
            status == HttpStatus.badRequest ||
            status == HttpStatus.unprocessableEntity ||
            status == HttpStatus.internalServerError ||
            status == HttpStatus.notFound,
      );

  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters, Options? options}) async {
    var opt = (options ?? Options());
    return _dio
        .get(path, options: opt, queryParameters: queryParameters)
        .then((response) => response);
  }

  Future<Response> post(String path,
      {Map<String, dynamic>? queryParameters,
      Options? options,
      dynamic data}) async {
    var opt = (options ?? Options());
    return _dio.post(path,
        data: data, queryParameters: queryParameters, options: opt);
  }

  Future<Response> patch(String path,
      {Map<String, dynamic>? queryParameters,
      Options? options,
      dynamic data}) async {
    var opt = (options ?? Options());
    return _dio.patch(path,
        data: data, queryParameters: queryParameters, options: opt);
  }

  Future<Response> put(String path,
      {Map<String, dynamic>? queryParameters,
      Options? options,
      dynamic data}) async {
    var opt = (options ?? Options());
    return _dio.put(path,
        data: data, queryParameters: queryParameters, options: opt);
  }

  Future<Response> delete(String path,
      {Map<String, dynamic>? queryParameters,
      Options? options,
      dynamic data}) async {
    var opt = (options ?? Options());
    return _dio.delete(path,
        data: data, queryParameters: queryParameters, options: opt);
  }

  Future<Response> uploadMultipartForm(String path,
      {Map<String, dynamic>? queryParameters,
      Options? options,
      required FormData data}) async {
    var opt = (options ?? Options(
      contentType: 'multipart/form-data',
      responseType: ResponseType.json,
      headers: {
        HttpHeaders.contentTypeHeader: 'multipart/form-data',
        HttpHeaders.contentLengthHeader: utf8.encode(data.toString()).length
      }
    ));

    return _dio.post(path,
        data: data, queryParameters: queryParameters, options: opt);
  }

  Future<void> refreshToken() async {
    var storageService = Get.find<StorageDataService>();
    var refreshToken = storageService.getToken(kEncryptedRefreshTokenKey);
    var newTokenResponse = await dio.get('api/Users/GetNewToken', queryParameters: {'refreshToken': refreshToken});
    if (newTokenResponse.statusCode == HttpStatus.ok && newTokenResponse.data != null) {
      await storageService.saveToken(newTokenResponse.data, kEncryptedAuthorizationTokenKey);
    } else {
      throw Exception('[API Service] refreshToken method was completed with an error');
    }
  }
}

dynamic _parseJson(String text) {
  return compute(_parseAndDecode, text);
}

dynamic _parseAndDecode(String response) {
  try {
    return jsonDecode(response);
  } catch (e) {
    return null;
  }
}
