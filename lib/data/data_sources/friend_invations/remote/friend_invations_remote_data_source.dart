import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../../../services/api/index.dart';
import '../../../models/api_error.dart';
import '../../../models/base_response.dart';

part 'friend_invations_remote_data_source_impl.dart';

abstract class FriendInvationsRemoteDataSource {
  factory FriendInvationsRemoteDataSource() = FriendInvationsRemoteDataSourceImpl;

  Future<BaseResponse<int, ApiError>> getSubscriberAmount({required int userId});

  Future<BaseResponse<int, ApiError>> getSubscriptionAmount({required int userId});
}