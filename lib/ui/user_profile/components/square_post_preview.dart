import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:potok/ui/widgets/cupertino_context_menu/custom_context_menu_action.dart';

import '../../../data/data_sources/authentication/local/authentication_local_data_source.dart';
import '../../../data/models/user/user_info_model.dart';
import '../../../data/models/user_content/post_content_type.dart';
import '../../../data/models/user_content/user_multimedia_post_model.dart';
import '../../../theme/potok_theme.dart';
import '../../widgets/cupertino_context_menu/custom_cupertino_context_menu.dart';
import '../screen/list_view_profile_post_view_screen.dart';
import '../state/user_content_controller.dart';

class SquarePostPreview extends StatelessWidget {
  SquarePostPreview({super.key, required this.index, required this.userMultimediaPost, required this.userInfo});

  final int index;
  final UserMultimediaPostModel userMultimediaPost;
  final UserInfoModel userInfo;
  final AuthenticationLocalDataSource _authenticationLocalDataSource = AuthenticationLocalDataSource();

  @override
  Widget build(BuildContext context) {
    bool isVideo = false;
    int videoIndexThumbnailPosition = 0;
    var theme = PotokTheme.of(context);
    final UserContentController _userContentController = Get.find<UserContentController>(tag: userInfo.nickname);

    if (userMultimediaPost.multimediaPostContentRefs.length == 2) {
      if (p.extension(userMultimediaPost.multimediaPostContentRefs[0].contentUrl).toLowerCase() == '.mp4') {
        isVideo = true;
        videoIndexThumbnailPosition = 1;
      } else if (p.extension(userMultimediaPost.multimediaPostContentRefs[1].contentUrl).toLowerCase() == '.mp4') {
        isVideo = true;
        videoIndexThumbnailPosition = 0;
      }
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        CustomCupertinoContextMenu(
          actions: [
            if (_authenticationLocalDataSource.currentUser?.id == userMultimediaPost.author.id) CustomCupertinoContextMenuAction(
              onPressed: () async {
                // TODO: implement this
                // ActionResult response = await UserMultimediaPostService.archivatePost(userMultimediaPost.id);
                // if (response.statusCode == 200) {
                //   showTopSnackBar(Overlay.of(context), const CustomSnackBar.success(message: 'Публикация перемещена в архив'), dismissType: DismissType.onSwipe);
                //   Navigator.pop(context);
                //   if (onDeleteItem != null) {
                //     Future.delayed(const Duration(milliseconds: 200), () {
                //       onDeleteItem!(postFolderModel, userMultimediaPost);
                //     });
                //   }
                // }
              },
              trailingIcon: const Icon(Icons.archive),
              child: const Text("Архивировать"),
            ),
            _authenticationLocalDataSource.currentUser?.id == userMultimediaPost.author.id ? Obx(() {
              return CustomCupertinoContextMenuAction(
                onPressed: () async {
                  await _userContentController.deletePost(userMultimediaPost);
                  Navigator.pop(context);
                },
                isDestructiveAction: true,
                trailingIcon: _userContentController.isDeletePostLoading.value
                ? const CircularProgressIndicator.adaptive()
                : const Icon(
                  CupertinoIcons.delete,
                  color: CupertinoColors.destructiveRed,
                  size: 18,
                ),
                child: const Text('Удалить'),
              );
            })
            : CustomCupertinoContextMenuAction(
              onPressed: () {
                // TODO: Добавить функцию, отправляющую жалобу
                Navigator.pop(context);
              },
              trailingIcon: const Icon(Icons.report_rounded),
              child: const Text('Пожаловаться')
            )
          ],
          child: GestureDetector(
            onTap: () async {
              // ignore: unused_local_variable
              Map<String, dynamic>? result = await context.pushTransparentRoute(ListViewProfilePostViewScreen(index: index, userInfo: userInfo), backgroundColor: theme.backgroundColor);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: index == 0 ? const Radius.elliptical(25, 16) : Radius.zero,
                topRight: index == 1 ? const Radius.elliptical(25, 16) : Radius.zero,
              ),
              child: _buildPostView(context, isVideo: isVideo, videoIndexThumbnailPosition: videoIndexThumbnailPosition)
            )
          )
        ),
        Positioned(
          right: 8,
          bottom: 4,
          // padding: const EdgeInsets.only(right: 7.0, bottom: 3.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              userMultimediaPost.isLiked ? const IgnorePointer(
                child: Icon(
                  Icons.favorite_rounded,
                  size: 14,
                  color: Colors.redAccent,
                ),
              )
              : const IgnorePointer(
                child: Icon(
                  Icons.favorite_border_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ),
              const IgnorePointer(
                child: SizedBox(width: 3),
              ),
              IgnorePointer(
                child: Text(
                  userMultimediaPost.likeAmount.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        if (isVideo) const Positioned(
          right: 6,
          top: 6,
          child: IgnorePointer(
            child: Icon(
              Icons.play_arrow_rounded,
              size: 24,
              color: Colors.white,
            ),
          ),
        )
        else if (userMultimediaPost.multimediaPostContentRefs.length > 1) const Positioned(
          right: 6,
          top: 6,
          child: IgnorePointer(
            child: Icon(
              Icons.collections_outlined,
              size: 17,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPostView(BuildContext context, {required bool isVideo, required int videoIndexThumbnailPosition}) {
    var theme = PotokTheme.of(context);

    if (userMultimediaPost.contentType == PostContentType.imageAndText || 
        userMultimediaPost.contentType == PostContentType.singleImage ||
        userMultimediaPost.contentType == PostContentType.singleVideo ||
        userMultimediaPost.contentType == PostContentType.videoAndText ||
        userMultimediaPost.fileView == 'profile-post-image' ||
        userMultimediaPost.fileView == 'profile-post-video') {
      return Hero(
        tag: 'disable-hero-post-${userMultimediaPost.id}',
        child: CachedNetworkImage(
          imageUrl: !isVideo ? userMultimediaPost.multimediaPostContentRefs[0].contentUrl : userMultimediaPost.multimediaPostContentRefs[videoIndexThumbnailPosition].contentUrl,
          fit: BoxFit.cover,
          fadeInDuration: Duration.zero
        ),
      );
    }
    if (userMultimediaPost.contentType == PostContentType.singleText) {
      return Container(
        color: theme.backgroundColor,
        alignment: Alignment.center,
        padding: const Pad(all: 16),
        child: Text(
          userMultimediaPost.description!,
          maxLines: 10,
          style: TextStyle(
            overflow: TextOverflow.ellipsis,
            color: theme.textColor
          ),
        ),
      );
    }
    if (userMultimediaPost.contentType == PostContentType.videoMessage) {
      return Container(
        color: theme.backgroundColor,
        child: Icon(Icons.video_chat_outlined, color: theme.brandColor,),
      );
    }
    if (userMultimediaPost.contentType == PostContentType.voice) {
      return Container(
        color: theme.backgroundColor,
        child: Icon(Icons.voice_chat, color: theme.brandColor,),
      );
    }

    return Container(
        color: theme.backgroundColor,
        child: Icon(Icons.error_outline, color: theme.brandColor,),
      );
  }
}