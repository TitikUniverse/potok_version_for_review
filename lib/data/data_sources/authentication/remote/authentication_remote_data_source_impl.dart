part of 'authentication_remote_data_source.dart';

class AuthenticationRemoteDataSourceImpl
    implements AuthenticationRemoteDataSource {
  final _apiService = Get.find<ApiService>();

  @override
  Future<BaseResponse<UserInfoModel, ApiError>> register(String nickname, String password) async {
    try {
      var response = await _apiService.post(ApiConstants.register, data: UserIdentityByPasswordModel(nickname: nickname, password: password).toJson());
      if (response.statusCode == HttpStatus.created && response.data != null) {
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

  @override
  Future<BaseResponse<UserInfoModel, ApiError>> startNewSession({required String token}) async {
    try {
      var response = await _apiService.post(ApiConstants.startNewSession, data: UserIdentityByTokenModel(token: token).toJson());
      if (response.statusCode == HttpStatus.ok && response.data != null) {
        var startNewSessionResponse = UserInfoModel.fromJson(response.data);
        return BaseResponse<UserInfoModel, ApiError>.success(statusCode: response.statusCode!, data: startNewSessionResponse);
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

  @override
  Future<BaseResponse<AuthInfoModel, ApiError>> authenticate(String nickname, String password) async {
    try {
      var response = await _apiService.post(ApiConstants.authenticate, data: UserIdentityByPasswordModel(nickname: nickname, password: password).toJson());
      if (response.statusCode == HttpStatus.ok && response.data != null) {
        var authenticateResponse = AuthInfoModel.fromJson(response.data);
        return BaseResponse<AuthInfoModel, ApiError>.success(statusCode: response.statusCode!, data: authenticateResponse);
      } else if (response.data is Map && response.data['error'] != null) {
        var error = ApiError.fromMap(response.data);
        return BaseResponse<AuthInfoModel, ApiError>.error(statusCode: response.statusCode, error: error);
      } else if (response.data is String && response.data != null) {
        return BaseResponse<AuthInfoModel, ApiError>.error(statusCode: response.statusCode, error: ApiError(error: Error(errorMessage: response.data)));
      } else {
        return BaseResponse<AuthInfoModel, ApiError>.error(statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      return BaseResponse<AuthInfoModel, ApiError>.error(statusCode: e.response?.statusCode, error: ApiError(error: Error(errorMessage: e.message)));
    }
  }

  @override
  Future<BaseResponse<bool, ApiError>> doesUserExist(String nickname) async {
    try {
      var response = await _apiService.get('${ApiConstants.doesUserExist}/$nickname}');
      if (response.statusCode == HttpStatus.ok && response.data != null) {
        var doesUserExistResponse = response.data == 'true' ? true : false;
        return BaseResponse<bool, ApiError>.success(statusCode: response.statusCode!, data: doesUserExistResponse);
      } else if (response.data is Map && response.data['error'] != null) {
        var error = ApiError.fromMap(response.data);
        return BaseResponse<bool, ApiError>.error(statusCode: response.statusCode, error: error);
      } else if (response.data is String && response.data != null) {
        return BaseResponse<bool, ApiError>.error(statusCode: response.statusCode, error: ApiError(error: Error(errorMessage: response.data)));
      } else {
        return BaseResponse<bool, ApiError>.error(statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      return BaseResponse<bool, ApiError>.error(statusCode: e.response?.statusCode, error: ApiError(error: Error(errorMessage: e.message)));
    }
  }
}
