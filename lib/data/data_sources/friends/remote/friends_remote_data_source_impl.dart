part of 'friends_remote_data_source.dart';

class FriendsRemoteDataSourceImpl implements FriendsRemoteDataSource {
  final _apiService = Get.find<ApiService>();

  @override
  Future<BaseResponse<FriendStatus, ApiError>> checkFriendStatus({required int firendId}) async {
    try {
      var response = await _apiService.post(ApiConstants.checkFriendsStatus, data: firendId);
      if (response.statusCode == HttpStatus.ok && response.data != null) {
        var friendStatus = FriendStatus.values.firstWhereOrNull((element) => element.name.toLowerCase() == (response.data! as String).toLowerCase());
        return BaseResponse<FriendStatus, ApiError>.success(statusCode: response.statusCode!, data: friendStatus);
      } else if (response.data is Map && response.data['error'] != null) {
        var error = ApiError.fromMap(response.data);
        return BaseResponse<FriendStatus, ApiError>.error(statusCode: response.statusCode, error: error);
      } else if (response.data is String && response.data != null) {
        return BaseResponse<FriendStatus, ApiError>.error(statusCode: response.statusCode, error: ApiError(error: Error(errorMessage: response.data)));
      } else {
        return BaseResponse<FriendStatus, ApiError>.error(statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      return BaseResponse<FriendStatus, ApiError>.error(statusCode: e.response?.statusCode, error: ApiError(error: Error(errorMessage: e.message)));
    }
  }
}