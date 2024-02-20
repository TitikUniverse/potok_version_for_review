import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../../../services/api/service/api.dart';
import '../../../../services/api/service/api_service.dart';
import '../../../models/api_error.dart';
import '../../../models/base_response.dart';
import '../../../models/user/user_info_model.dart';

part 'user_profile_remote_data_source_impl.dart';

abstract class UserProfileRemoteDataSource {
  factory UserProfileRemoteDataSource() = UserProfileRemoteDataSourceImpl;

  Future<BaseResponse<UserInfoModel, ApiError>> getUserByNickname(String nickname);
}