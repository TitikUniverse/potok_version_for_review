part of 'user_profile_remote_data_source.dart';

class UserProfileRemoteDataSourceImpl implements UserProfileRemoteDataSource {
  final _apiService = Get.find<ApiService>();

  @override
  Future<BaseResponse<UserInfoModel, ApiError>> getUserByNickname(String nickname) async {
    try {
      var response = await _apiService.post(ApiConstants.getUserByNickname, data: {'nickname': nickname});
      if (response.statusCode == HttpStatus.ok && response.data != null) {
        var registerResponse = UserInfoModel.fromJson(response.data);
        return BaseResponse<UserInfoModel, ApiError>.success(statusCode: response.statusCode!, data: registerResponse);
      } else if (response.data is Map && response.data['error'] != null) {
        var error = ApiError.fromMap(response.data);
        return BaseResponse<UserInfoModel, ApiError>.error(statusCode: response.statusCode, error: error);
      } else if (response.data is String && response.data != null) {
        return BaseResponse<UserInfoModel, ApiError>.error(statusCode: response.statusCode, error: ApiError(error: Error(errorMessage: response.data)));
      } else {
        return BaseResponse<UserInfoModel, ApiError>.error(statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      return BaseResponse<UserInfoModel, ApiError>.error(statusCode: e.response?.statusCode, error: ApiError(error: Error(errorMessage: e.message)));
    }
  }
}