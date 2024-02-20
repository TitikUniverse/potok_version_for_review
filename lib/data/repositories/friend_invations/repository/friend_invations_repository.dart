import '../../../data_sources/friend_invations/index.dart';
import '../../../models/api_error.dart';
import '../../../models/base_response.dart';

part 'friend_invations_repository_impl.dart';

abstract class FriendInvationsRepository {
  factory FriendInvationsRepository() = FriendInvationsRepositoryImpl;

  Future<BaseResponse<int, ApiError>> getSubscriberAmount({required int userId});

  Future<BaseResponse<int, ApiError>> getSubscriptionAmount({required int userId});
}