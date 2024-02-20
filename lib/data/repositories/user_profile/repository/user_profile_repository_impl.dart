part of 'user_profile_repository.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileRemoteDataSource _userProfileRemoteDataSource =
      UserProfileRemoteDataSource();

  @override
  Future<BaseResponse<UserInfoModel, ApiError>> getUserByNickname(String nickname) async =>
      await _userProfileRemoteDataSource.getUserByNickname(nickname);
}