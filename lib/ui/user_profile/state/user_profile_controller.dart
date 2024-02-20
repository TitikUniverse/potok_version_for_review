import 'dart:async';

import 'package:get/get.dart';

import '../../../data/data_sources/authentication/local/authentication_local_data_source.dart';
import '../../../data/models/user/user_block_check_model.dart';
import '../../../data/models/user/user_info_model.dart';
import '../../../data/repositories/friend/repository/friend_status.dart';
import '../../../data/repositories/friend/repository/friends_repository.dart';
import '../../../data/repositories/friend_invations/repository/friend_invations_repository.dart';
import '../../../data/repositories/user_profile/repository/user_profile_repository.dart';

class UserProfileController extends GetxController {
  late final UserProfileRepository _userProfileRepository;
  late final FriendsRepository _friendsRepository;
  late final FriendInvationsRepository _friendInvationsRepository;
  final AuthenticationLocalDataSource _authenticationLocalDataSource = AuthenticationLocalDataSource();

  bool get isCurrentUser => userInfo?.id == _authenticationLocalDataSource.currentUser?.id;
  var friendStatus = FriendStatus.unknown.obs;

  UserInfoModel? userInfo;

  // UserInfoModel? userInfo;
  UserBlockCheckModel userBlockCheck = UserBlockCheckModel(isCurrentUserBlocked: false, isUserBlocked: false); // TODO: implement this

  RxInt subscriberAmount = 0.obs; // TODO: implement this
  RxInt subscriptionAmount = 0.obs; // TODO: implement this

  @override
  void onInit() {
    _userProfileRepository = Get.find<UserProfileRepository>();
    _friendsRepository = Get.find<FriendsRepository>();
    _friendInvationsRepository = Get.find<FriendInvationsRepository>();
    super.onInit();
  }

  Future<UserInfoModel?> fetchUserProfileData(String nickname) async {
    var response = await _userProfileRepository.getUserByNickname(nickname);
    if (response.isSuccessful && response.data != null) {
      userInfo = response.data!;
      update();
      scheduleMicrotask(() {
        // Не ставить тут await! Потому что нужно загрузить эти данные в разнобой, чтобы было реще
        if (isCurrentUser == false) checkFriendStatus(response.data!.id);
        fetchSubscriberAmount(response.data!.id);
        getSubscriptionAmount(response.data!.id);
      });
      return response.data;
    } else {
      // TODO: implement this (need handle error)
      return null;
    }
  }

  Future<void> checkFriendStatus(int userId) async {
    var response = await _friendsRepository.checkFriendStatus(firendId: userId);
    if (response.isSuccessful && response.data != null) {
      friendStatus.value = response.data!;
    } else {
      // TODO: implement this (need handle error)
    }
  }

  Future<void> fetchSubscriberAmount(int userId) async {
    var response = await _friendInvationsRepository.getSubscriberAmount(userId: userId);
    if (response.isSuccessful && response.data != null) {
      subscriberAmount.value = response.data!;
    } else {
      // TODO: implement this (need handle error)
    }
  }

  Future<void> getSubscriptionAmount(int userId) async {
    var response = await _friendInvationsRepository.getSubscriptionAmount(userId: userId);
    if (response.isSuccessful && response.data != null) {
      subscriptionAmount.value = response.data!;
    } else {
      // TODO: implement this (need handle error)
    }
  }
}