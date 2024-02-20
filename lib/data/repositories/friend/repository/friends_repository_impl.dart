part of 'friends_repository.dart';

class FriendsRepositoryImpl implements FriendsRepository {
  final FriendsRemoteDataSource _friendsRemoteDataSource = FriendsRemoteDataSource();

  @override
  Future<BaseResponse<FriendStatus, ApiError>> checkFriendStatus({required int firendId}) async => 
      _friendsRemoteDataSource.checkFriendStatus(firendId: firendId);
}