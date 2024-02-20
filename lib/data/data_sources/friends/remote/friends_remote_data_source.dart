import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../../../services/api/index.dart';
import '../../../models/api_error.dart';
import '../../../models/base_response.dart';
import '../../../repositories/friend/repository/friend_status.dart';

part 'friends_remote_data_source_impl.dart';

abstract class FriendsRemoteDataSource {
  factory FriendsRemoteDataSource() = FriendsRemoteDataSourceImpl;

  Future<BaseResponse<FriendStatus, ApiError>> checkFriendStatus({required int firendId});
}