import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:get/get.dart';

import '../../../data/data_sources/authentication/local/authentication_local_data_source.dart';
import '../../../data/models/api_error.dart';
import '../../../data/models/base_response.dart';
import '../../../data/models/user_content/user_multimedia_post_model.dart';
import '../../../data/repositories/user_content/repository/user_content_repository.dart';
import '../../../resources/resource_string.dart';
import '../../../services/storage/service/boxes_keys.dart';
import '../../../services/storage/service/storage_data_service.dart';
import '../../widgets/shackbar/snackbar.dart';
import '../../widgets/show_unauth_warning.dart';

class UserContentController extends GetxController {

  late final UserContentRepository _userContentRepository;
  final AuthenticationLocalDataSource _authenticationLocalDataSource = AuthenticationLocalDataSource();

  List<UserMultimediaPostModel>? posts;

  /// Идёи ли в данный момент удаление поста
  RxBool isDeletePostLoading = false.obs;

  /// Занят ли пагинатор
  bool isNextPageLoading = false;

  /// Нужно ли загружать следующую страницу в пагинаторе
  bool isNeedLoadMore = true;

  Future<void> fetchNextPage({required int authorId}) async {
    isNextPageLoading = true;
    var response = await fetchUserPosts(authorId: authorId);
    if (response.isSuccessful && response.data!.isEmpty) {
      isNeedLoadMore = false;
    }
    isNextPageLoading = false;
  }

  @override
  void onInit() {
    _userContentRepository = Get.find<UserContentRepository>();
    super.onInit();
  }

  /// Return null if error
  Future<BaseResponse<List<UserMultimediaPostModel>, ApiError>> fetchUserPosts({required int authorId, bool isRefreshRequest = false}) async {
    if (isRefreshRequest) posts = null;
    var response = await _userContentRepository.getUserPosts(authorId: authorId, count: 20, skipCount: posts?.length);
    if (response.isSuccessful) {
      posts ??= [];
      posts?.addAll(response.data!);
      update();
    } else {
      // TODO: implement handle error
    }
    return response;
  }

  Future<void> deletePost(UserMultimediaPostModel userMultimediaPost) async {
    var response = await _userContentRepository.deletePost(postId: userMultimediaPost.id);
    if (response.isSuccessful) {
      if (posts?.contains(userMultimediaPost) == true) posts?.remove(userMultimediaPost);
      update();
    } else {
      // TODO: implement handle error
    }
  }

  Future<bool?> savePost(BuildContext context, {required bool isSaved, required int postId}) async {
    if (_authenticationLocalDataSource.currentUser == null) {
      await showUnauthWarning(context);
      return isSaved;
    }
    var _type = FeedbackType.impact;
    Vibrate.feedback(_type);

    if (isSaved == false) {
      var storage = Get.find<StorageDataService>();

      int? savedOnboardingCounter = storage.get<int>(kSavedOnboardingCounterKey);
      if (savedOnboardingCounter == null) {
        await storage.set<int>(kSavedOnboardingCounterKey, 3);
        savedOnboardingCounter = 3;
      }
      else {
        savedOnboardingCounter--;
        await storage.set<int>(kSavedOnboardingCounterKey, savedOnboardingCounter);
      }
    
      if (savedOnboardingCounter > 0) {
        PotokSnackbar.info(context, message: ResourceString.postAddToSaved);
      }
    }

    scheduleMicrotask(() async {
      if (isSaved) {
        await _userContentRepository.removePostFromSaved(postId: postId);
      } else {
        await _userContentRepository.addPostToSaved(postId: postId);
      }
    });

    return !isSaved;
  }

  Future<bool?> likePost(BuildContext context, {required bool isLiked, required int postId}) async {
    if (_authenticationLocalDataSource.currentUser == null) {
      await showUnauthWarning(context);
      return isLiked;
    }
    var _type = FeedbackType.impact;
    Vibrate.feedback(_type);

    scheduleMicrotask(() async {
      late BaseResponse<int, ApiError> result;
      if (isLiked) {
        result = await _userContentRepository.deletePostLike(postId: postId, userId: _authenticationLocalDataSource.currentUser!.id);
      } else {
        result = await _userContentRepository.addPostLike(postId: postId, userId: _authenticationLocalDataSource.currentUser!.id);
      }
      if (result.isSuccessful) {
        // ? maybe implement this
      }
      else {
        // TODO: implement handle error
      }
    });

    return !isLiked;
  }

  Future<bool?> doubleTapLikePost(BuildContext context, {required UserMultimediaPostModel post}) async {
    if (_authenticationLocalDataSource.currentUser == null) {
      await showUnauthWarning(context);
      return null;
    }

    // if(!isLikedAnimVisible) {
    //   setState((() => isLikedAnimVisible = !isLikedAnimVisible));
    //   Future.delayed(const Duration(milliseconds: 1100), (){
    //       setState((() => isLikedAnimVisible = !isLikedAnimVisible));
    //     } 
    //   );
    // }
    
    var _type = FeedbackType.impact;
    Vibrate.feedback(_type);

    if (post.isLiked) return null;
    
    return await likePost(context, isLiked: false, postId: post.id);
  }
}