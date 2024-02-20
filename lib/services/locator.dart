import 'package:get/get.dart';

import '../data/repositories/authentication/index.dart';
import '../data/repositories/friend/repository/friends_repository.dart';
import '../data/repositories/friend_invations/repository/friend_invations_repository.dart';
import '../data/repositories/user_content/repository/user_content_repository.dart';
import '../data/repositories/user_profile/repository/user_profile_repository.dart';
import '../ui/authentication/state/auth_controller.dart';
import '../ui/registration/state/registration_controller.dart';
import '../ui/user_profile/state/new_post_controller.dart';
import 'api/index.dart';
import 'storage/index.dart';
import 'user_content_upload/service/user_content_upload_service.dart';

Future<void> setupLocator() async {
  // service
  Get.put(StorageDataService(), permanent: true);
  await Get.find<StorageDataService>().init();
  Get.put(ApiService(), permanent: true);
  await Get.find<ApiService>().init();

  // repo
  Get.put(AuthRepository());
  Get.put(UserProfileRepository());
  Get.put(UserContentRepository());
  Get.put(FriendsRepository());
  Get.put(FriendInvationsRepository());

  Get.put(UserContentUploadService(userContentRepository: Get.find<UserContentRepository>()), permanent: true);

  Get.put(AuthController(authRepository: Get.find<AuthRepository>()));
  Get.put(RegistrationController(authRepository: Get.find<AuthRepository>()));
  Get.put(NewPostController());
}
