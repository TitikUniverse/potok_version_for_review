import '../../../data_sources/user_profile/remote/user_profile_remote_data_source.dart';
import '../../../models/api_error.dart';
import '../../../models/base_response.dart';
import '../../../models/user/user_info_model.dart';

part 'user_profile_repository_impl.dart';

abstract class UserProfileRepository {
  factory UserProfileRepository() = UserProfileRepositoryImpl;

  Future<BaseResponse<UserInfoModel, ApiError>> getUserByNickname(String nickname);
}