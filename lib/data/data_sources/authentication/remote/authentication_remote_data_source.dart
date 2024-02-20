import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../../../services/api/index.dart';
import '../../../models/api_error.dart';
import '../../../models/auth/auth_info_model.dart';
import '../../../models/auth/user_identity_by_password_model.dart';
import '../../../models/auth/user_indentity_by_token_model.dart';
import '../../../models/base_response.dart';
import '../../../models/user/user_info_model.dart';

part 'authentication_remote_data_source_impl.dart';

abstract class AuthenticationRemoteDataSource {
  factory AuthenticationRemoteDataSource() = AuthenticationRemoteDataSourceImpl;

  Future<BaseResponse<UserInfoModel, ApiError>> register(String nickname, String password);

  Future<BaseResponse<UserInfoModel, ApiError>> startNewSession({required String token});

  Future<BaseResponse<AuthInfoModel, ApiError>> authenticate(String nickname, String password);

  Future<BaseResponse<bool, ApiError>> doesUserExist(String nickname);
}
