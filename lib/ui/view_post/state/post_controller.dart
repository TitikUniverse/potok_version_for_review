import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:potok/ui/widgets/show_unauth_warning.dart';

import '../../../data/data_sources/authentication/local/authentication_local_data_source.dart';
import '../../../data/models/user/user_info_model.dart';
import '../../../data/models/user_content/comment_mode.dart';
import '../../../data/repositories/user_content/repository/user_content_repository.dart';
import '../../widgets/shackbar/snackbar.dart';

class PostController extends GetxController {
  late final UserContentRepository _userContentRepository;
  final AuthenticationLocalDataSource _authenticationLocalDataSource = AuthenticationLocalDataSource();
  
  List<UserInfoModel>? usersWhoLike;
  List<UserPostCommentModel>? comments;

  /// Нужно ли пагинатору загружать ещё юзеров, кто лайкнул пост
  bool isNeedLoadMoreUsersWhoLike = true;

  /// Нужно ли пагинатору загружать ещё юзеров, кто лайкнул пост
  bool isNeedLoadMoreComments = true;

  /// Отправляется ли сейчас комментарий
  bool isCommentSending = false;

  @override
  void onInit() {
    _userContentRepository = Get.find<UserContentRepository>();
    super.onInit();
  }

  Future<void> fetchComments({required int postId}) async {
    var response = await _userContentRepository.getPostComment(postId: postId, count: 20, skipCount: comments?.length);
    if (response.isSuccessful) {
      comments ??= [];
      if ((response.data ?? []).isEmpty) {
        isNeedLoadMoreComments = false;
      } else {
        comments?.addAll(response.data!);
      }
      update();
    } else {
      // TODO: implement handle error
    }
  }

  /// Return false только если закончились страницы
  Future<bool> tryFetchUsersWhoLike({required int postId}) async {
    int pageNumber = usersWhoLike == null ? 0 : (usersWhoLike!.length / 20).floor();
    if (usersWhoLike != null && usersWhoLike!.length % 20 != 0) {
      pageNumber++;
      isNeedLoadMoreUsersWhoLike = false;
      return false;
    }
    if (!isNeedLoadMoreUsersWhoLike) return false;
    
    var response = await _userContentRepository.getUsersWhoLikedPost(postId: postId, pageNumber: pageNumber);
    if (response.isSuccessful) {
      usersWhoLike ??= [];
      if (response.data != null) usersWhoLike!.addAll(response.data!);
    } else {
      // TODO: implement handle error
    }
    update();
    return true;
  }

  Future<void> addNewComment(BuildContext context, {required int postId, required String text}) async {
    if (text.trim().isEmpty) {
      PotokSnackbar.failure(context, message: 'Текст комментария не должен быть пустым');
      return;
    }
    if (_authenticationLocalDataSource.currentUser == null) {
      showUnauthWarning(context);
      return;
    }
    if (isCommentSending) return;
    isCommentSending = true;
    var response = await _userContentRepository.addNewPostComment(postId: postId, userWhoSentComment: _authenticationLocalDataSource.currentUser!.id, commentText: text);
    if (response.isSuccessful) {
      fetchComments(postId: postId);
    } else {
      // TODO: implement handle error
    }
    isCommentSending = false;
  }
}