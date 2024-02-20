part of 'friend_invations_repository.dart';

class FriendInvationsRepositoryImpl implements FriendInvationsRepository {
  final FriendInvationsRemoteDataSource _friendInvationsRemoteDataSource = FriendInvationsRemoteDataSource();

  @override
  Future<BaseResponse<int, ApiError>> getSubscriberAmount({required int userId}) async =>
      _friendInvationsRemoteDataSource.getSubscriberAmount(userId: userId);

  @override
  Future<BaseResponse<int, ApiError>> getSubscriptionAmount({required int userId}) async =>
      _friendInvationsRemoteDataSource.getSubscriptionAmount(userId: userId);
}