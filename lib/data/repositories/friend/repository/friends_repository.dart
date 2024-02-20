import '../../../data_sources/friends/index.dart';
import '../../../models/api_error.dart';
import '../../../models/base_response.dart';
import 'friend_status.dart';

part 'friends_repository_impl.dart';

abstract class FriendsRepository {
  factory FriendsRepository() = FriendsRepositoryImpl;

  Future<BaseResponse<FriendStatus, ApiError>> checkFriendStatus({required int firendId});
}