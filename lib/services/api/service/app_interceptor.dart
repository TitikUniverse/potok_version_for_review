import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/instance_manager.dart';

import '../../../utils/logger.dart';
import '../../storage/index.dart';
import 'api.dart';

class AppInterceptor extends QueuedInterceptorsWrapper {
  AppInterceptor({required this.dio, required this.onErrorStatusChanged, required this.refreshToken});

  final Dio dio;
  final StorageDataService _storageDataService = Get.find<StorageDataService>();
  final Function(int httpStatus) onErrorStatusChanged;
  final Future<void> Function() refreshToken;

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    var authToken =
        _storageDataService.getToken(kEncryptedAuthorizationTokenKey);
    if (authToken != null && authToken.isNotEmpty) {
      options.headers['token'] = authToken;
    }
    options.headers[HttpHeaders.dateHeader] = DateTime.timestamp().toIso8601String();
    if (options.headers.containsKey(HttpHeaders.contentTypeHeader) == false) {
      options.headers[HttpHeaders.contentTypeHeader] = 'application/json';
    }
    options.headers[ApiConstants.microserviceApiKeyHeader] = ApiConstants.microserviceApiKey;
    _logRequest(options);
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logResponse(response);
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    _logError(err);
    onErrorStatusChanged(err.response?.statusCode ?? -1);
    if (err.response?.statusCode == HttpStatus.unauthorized || err.response?.statusCode == HttpStatus.forbidden) {
      await refreshToken();
      var newAuthToken = _storageDataService.getToken(kEncryptedAuthorizationTokenKey);
      err.requestOptions.headers['token'] = newAuthToken;
      if (err.requestOptions.data is Map<String, dynamic>) {
        if ((err.requestOptions.data as Map<String, dynamic>).containsKey('token')) {
          err.requestOptions.data['token'] = newAuthToken;
        }
      }
      return handler.resolve(await dio.fetch(err.requestOptions));
    }
    super.onError(err, handler);
  }

  void _logRequest(RequestOptions options) {
    logger.t('---> ${options.method} ${options.baseUrl}${options.path}'
        '${options.headers.isNotEmpty == true ? const JsonEncoder.withIndent("     ").convert(options.headers) : ''}'
        '${options.queryParameters.isNotEmpty == true ? '\n${options.queryParameters}' : ''}'
        '${options.data != null ? '\n${options.data is FormData ? options.data?.fields : const JsonEncoder.withIndent("     ").convert(options.data)}' : ''}');
  }

  void _logResponse(Response response) {
    logger.t(
        '<--- ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.baseUrl}${response.requestOptions.path}');
    if (response.statusCode != HttpStatus.notModified &&
        response.headers.toString().isNotEmpty == true) {
      logger.t(response.headers);
    }
    if (response.statusCode != HttpStatus.notModified &&
        response.data?.toString().isNotEmpty == true) {
      logger.t(response.data);
    }
  }

  void _logError(DioException err) {
    logger.e(
        '<--- ${err.response?.statusCode == null ? '' : '${err.response?.statusCode}'} ERROR ${err.requestOptions.method} ${err.requestOptions.baseUrl}${err.requestOptions.path} ${err.error}');
    if (err.requestOptions.data != null) {
      logger.e('REQUEST');
      logger.e('${err.requestOptions.data}');
    }
    if (err.response?.data?.toString().trim().isNotEmpty == true) {
      logger.e('RESPONSE');
      logger.e('${err.response?.data}');
    }
  }
}
