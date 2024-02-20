part of 'friend_invations_remote_data_source.dart';

class FriendInvationsRemoteDataSourceImpl implements FriendInvationsRemoteDataSource {
  final _apiService = Get.find<ApiService>();
  @override
  Future<BaseResponse<int, ApiError>> getSubscriberAmount({required int userId}) async {
    try {
      var response = await _apiService.get('${ApiConstants.getSubscriberAmount}/$userId');
      if (response.statusCode == HttpStatus.ok && response.data != null) {
        return BaseResponse<int, ApiError>.success(statusCode: response.statusCode!, data: response.data!);
      } else if (response.data is Map && response.data['error'] != null) {
        var error = ApiError.fromMap(response.data);
        return BaseResponse<int, ApiError>.error(statusCode: response.statusCode, error: error);
      } else if (response.data is String && response.data != null) {
        return BaseResponse<int, ApiError>.error(statusCode: response.statusCode, error: ApiError(error: Error(errorMessage: response.data)));
      } else {
        return BaseResponse<int, ApiError>.error(statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      return BaseResponse<int, ApiError>.error(statusCode: e.response?.statusCode, error: ApiError(error: Error(errorMessage: e.message)));
    }
  }

  @override
  Future<BaseResponse<int, ApiError>> getSubscriptionAmount({required int userId}) async {
    try {
      var response = await _apiService.get('${ApiConstants.getSubscriptionAmount}/$userId');
      if (response.statusCode == HttpStatus.ok && response.data != null) {
        return BaseResponse<int, ApiError>.success(statusCode: response.statusCode!, data: response.data!);
      } else if (response.data is Map && response.data['error'] != null) {
        var error = ApiError.fromMap(response.data);
        return BaseResponse<int, ApiError>.error(statusCode: response.statusCode, error: error);
      } else if (response.data is String && response.data != null) {
        return BaseResponse<int, ApiError>.error(statusCode: response.statusCode, error: ApiError(error: Error(errorMessage: response.data)));
      } else {
        return BaseResponse<int, ApiError>.error(statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      return BaseResponse<int, ApiError>.error(statusCode: e.response?.statusCode, error: ApiError(error: Error(errorMessage: e.message)));
    }
  }

}