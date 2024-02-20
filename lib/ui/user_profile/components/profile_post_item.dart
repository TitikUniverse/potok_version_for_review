import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:like_button/like_button.dart';
import 'package:path/path.dart' as p;
import 'package:shimmer/shimmer.dart';
import 'package:voice_message_package/voice_message_package.dart';

import '../../../data/data_sources/authentication/local/authentication_local_data_source.dart';
import '../../../data/models/user_content/post_content_type.dart';
import '../../../data/models/user_content/user_multimedia_post_model.dart';
import '../../../data/repositories/user_content/repository/post_type.dart';
import '../../../navigation/parameters/post_parameters.dart';
import '../../../navigation/routes.dart';
import '../../../resources/resource_string.dart';
import '../../../theme/potok_theme.dart';
import '../../widgets/image_viewer.dart';
import '../../widgets/show_unauth_warning.dart';
import '../state/user_content_controller.dart';

class ProfilePostItem extends StatefulWidget {
  const ProfilePostItem({super.key, required this.post, required this.postType});

  final UserMultimediaPostModel post;
  final PostType postType;

  @override
  State<ProfilePostItem> createState() => _AccountPostItemState();
}

class _AccountPostItemState extends State<ProfilePostItem> {
  final AuthenticationLocalDataSource _authenticationLocalDataSource = AuthenticationLocalDataSource();

  int _postViewsCount = 0;

  DateFormat get postDateFormat {
    if (widget.post.dateTimeStamp.year == DateTime.now().year) return DateFormat('dd MMM HH:mm');
    return DateFormat('dd MMM yyyy');
  }

  Future<void> _getPostViewsCount() async {
    // TODO: implement this
    // var response = await UserMultimediaPostService.getPostViewCount(widget.post.id);
    // if (response.statusCode == 200 && response.data != null && response.data is int) {
    //   setState(() {
    //     _postViewsCount = response.data!;
    //   });
    // }
  }

  @override
  void initState() {
    _getPostViewsCount();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var theme = PotokTheme.of(context);
    var mq = MediaQuery.of(context);
    return Container(
      width: mq.size.width,
      padding: const EdgeInsets.only(top: 16),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: theme.frontColor,
        borderRadius: BorderRadius.circular(16)
      ),
      child: Column(
        children: [
          // ? Шапка
          Padding(
            padding: const Pad(horizontal: 20),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ? Никнейм
                    GestureDetector(
                      onTap: () => GoRouter.of(context).push('/${widget.post.author.nickname}'),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.post.author.nickname,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: theme.textColor
                            ),
                          ),
                          if (widget.post.author.isAuthorOfQualityContent!) Tooltip(
                            message: 'Качественный контент',
                            triggerMode: TooltipTriggerMode.tap,
                            verticalOffset: 20,
                            showDuration: const Duration(seconds: 1),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: theme.frontColor
                            ),
                            textStyle: TextStyle(
                              color: theme.textColor,
                              fontSize: 14
                            ),
                            child: Container(
                              margin: const EdgeInsets.only(left: 4.0),
                              child: CachedNetworkImage( 
                                fadeInDuration: Duration.zero,
                                height: 16,
                                width: 16,
                                imageUrl: 'https://ratemeapp.hb.bizmrg.com/potokassets/static/usertypes/kometa.png',
                                fit: BoxFit.cover,
                              )
                            ),
                          ),
                          if (widget.post.author.isVerifiedAccount!) Tooltip(
                            message: 'Проверенный аккаунт',
                            triggerMode: TooltipTriggerMode.tap,
                            verticalOffset: 20,
                            showDuration: const Duration(seconds: 1),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: theme.frontColor
                            ),
                            textStyle: TextStyle(
                              color: theme.textColor,
                              fontSize: 14
                            ),
                            child: Container(
                              margin: const EdgeInsets.only(left: 5.0),
                              child: CachedNetworkImage( 
                                fadeInDuration: Duration.zero,
                                height: 16,
                                width: 16,
                                imageUrl:'https://ratemeapp.hb.bizmrg.com/potokassets/static/usertypes/super.png',
                                fit: BoxFit.cover,
                              )
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // ? Просмотры
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (_authenticationLocalDataSource.currentUser != null) Text(
                      '$_postViewsCount ПРОСМОТРОВ',
                      style: TextStyle(fontSize: 9, height: 1, color: theme.textColor.withOpacity(.4)),
                    ),
                    Text(
                      postDateFormat.format(widget.post.dateTimeStamp),
                      style: TextStyle(fontSize: 9, color: theme.textColor.withOpacity(.4)),
                    ),
                  ],
                ),
              ]
            ),
          ),
    
          // ? Контент поста
          GestureDetector(
            onDoubleTap: () async {
              bool? result = await Get.find<UserContentController>(tag: widget.post.author.nickname).doubleTapLikePost(context, post: widget.post);
              if (result != null) {
                widget.post.isLiked = result;
                if (result == true) {
                  widget.post.likeAmount++;
                } else if (result == false) {
                  widget.post.likeAmount--;
                }
                setState(() {});
              }
            },
            child: _PostContent(
              post: widget.post,
              onPostViewCountChanged: (value) {
                setState(() {
                  _postViewsCount = value ?? _postViewsCount + 1;
                });
              },
            ),
          ),
    
          // ? Нижний бар
          Padding(
            padding: const Pad(horizontal: 15),
            child: _PostBottomBar(post: widget.post, postType: widget.postType),
          )
        ]
      ),
    );
  }
}

class _PostContent extends StatefulWidget {
  const _PostContent({required this.post, this.onPostViewCountChanged});

  final UserMultimediaPostModel post;
  final void Function(int?)? onPostViewCountChanged;

  @override
  State<_PostContent> createState() => _PostContentState();
}

class _PostContentState extends State<_PostContent> {
  int _selectedImageIndex = 0;
  bool isVideo = false;
  int videoIndexPosition = 0;
  int videoPreviewImageIndexPosition = 1;

  BoxFit _getObjectFit(UserMultimediaPostModel post) {
    post.objectFit ??= 'null';
    switch (post.objectFit!.toLowerCase()) {
      case 'cover':
        return BoxFit.cover;
      case 'fitwidth':
        return BoxFit.fitWidth;
      case 'fitheight':
        return BoxFit.fitHeight;
      case 'null':
        return BoxFit.fitWidth;
      default:
        return BoxFit.fitWidth;
    }
  }

  Future<void> _addPostView() async {
    // TODO: implement this
    // var response = await UserMultimediaPostService.addPostView(widget.post.id);
    // if (response.statusCode! >= 200 && response.statusCode! < 300) {
    //   if (widget.onPostViewCountChanged != null) widget.onPostViewCountChanged!(null);
    //   printInfo('add +1 view to post ${widget.post.id}', name: 'user_account_screen.dart');
    // }
    // else {
    //   printWarning('error add view to post ${widget.post.id}', name: 'user_account_screen.dart');
    // }
  }

  @override
  void initState() {
    _addPostView();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var mq = MediaQuery.of(context);
    var theme = PotokTheme.of(context);
    BoxFit fit = _getObjectFit(widget.post);

    // Проверка, видео это или нет
    if (widget.post.multimediaPostContentRefs.length == 2) {
      if (p.extension(widget.post.multimediaPostContentRefs[0].contentUrl).toLowerCase() == '.mp4') {
        isVideo = true;
        videoIndexPosition = 0;
        videoPreviewImageIndexPosition = 1;
      }
      if (p.extension(widget.post.multimediaPostContentRefs[1].contentUrl).toLowerCase() == '.mp4') {
        isVideo = true;
        videoIndexPosition = 1;
        videoPreviewImageIndexPosition = 0;
      }
    }

    // * Тут поддержка старых постов без contentType (поле появилось только в версии 5.0.0)
    // ignore: curly_braces_in_flow_control_structures
    if (widget.post.contentType == PostContentType.undefined) return Column(
      children: [
        // ? Видео
        if  (widget.post.multimediaPostContentRefs.isNotEmpty && isVideo) GestureDetector(
          // onTap: () async { // ! тут onTap нельзя делать, он находится внутри [FlickMultiPlayer] и срабатывает ТОЛЬКО ОТТУДА
          //   _openInFullScreen();
          // },
          child: Container(
            clipBehavior: Clip.hardEdge,
            height: mq.size.height * 0.65,
            margin: const Pad(top: 10),
            alignment: Alignment.center,
            decoration: const BoxDecoration(),
            child: Text(
              'Скоро тут будет пост с видео. А пока его нет',
              style: TextStyle(color: theme.textColor),
            ),
            // child: FlickMultiPlayer(
            //   url: widget.post.multimediaPostContentRefs[videoIndexPosition].contentUrl,
            //   image: widget.post.multimediaPostContentRefs[videoPreviewImageIndexPosition].contentUrl,
            //   fit: _getObjectFit(widget.post),
            //   flickMultiManager: _flickMultiManager,
            //   postType: PostType.profilePosts,
            //   onTap: null//_openInFullScreen,
            // ),
          ),
        ),
        
        // ? Фото
        if (widget.post.multimediaPostContentRefs.isNotEmpty && !isVideo) Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10.0),
              constraints: BoxConstraints(
                maxHeight: mq.size.height * 0.5,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.hardEdge,
              child: widget.post.multimediaPostContentRefs.length > 1 ? PageView.builder( // ExpandablePageView
                controller: PageController(viewportFraction: 0.93),
                physics: const ClampingScrollPhysics(),
                itemCount: widget.post.multimediaPostContentRefs.length,
                onPageChanged: (index) {
                  setState(() {
                    _selectedImageIndex = index;
                  });
                },
                itemBuilder: (BuildContext context, int index) {
                  return ImageViewer(
                    tag: 'post-${widget.post.id}-$index',
                    child: Container(
                      margin: const Pad(horizontal: 4, vertical: 6),
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        border: fit == BoxFit.cover ? null : Border.all(color: theme.textColor.withOpacity(.2), strokeAlign: BorderSide.strokeAlignOutside),
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.07),
                            blurRadius: 5,
                            spreadRadius: 2
                          )
                        ]
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (fit != BoxFit.cover) ImageFiltered(
                            imageFilter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                            child: CachedNetworkImage(
                              height: mq.size.height,
                              imageUrl: widget.post.multimediaPostContentRefs[index].contentUrl,
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                          CachedNetworkImage(
                            width: mq.size.width,
                            imageUrl: widget.post.multimediaPostContentRefs[index].contentUrl,
                            fit: fit,
                            fadeOutDuration: Duration.zero,
                            progressIndicatorBuilder: (context, url, progress) => Shimmer.fromColors(
                              baseColor: theme.textColor.withOpacity(.4),
                              highlightColor: theme.textColor.withOpacity(.2),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: theme.textColor.withOpacity(.4),
                                ),
                              ),
                            )
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
              : ImageViewer(
                tag: 'post-${widget.post.id}-0',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  clipBehavior: Clip.hardEdge,
                  child: CachedNetworkImage(
                    height: mq.size.height,
                    imageUrl: widget.post.multimediaPostContentRefs[0].contentUrl,
                    fit: fit,
                    fadeOutDuration: Duration.zero,
                    progressIndicatorBuilder: (context, url, progress) => Shimmer.fromColors(
                      baseColor: theme.textColor.withOpacity(.4),
                      highlightColor: theme.textColor.withOpacity(.2),
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.textColor.withOpacity(.4),
                        ),
                      ),
                    )
                  ),
                ),
              )
            ),
            // ? Пагинатор
            if (!isVideo && widget.post.multimediaPostContentRefs.length > 1) Container(
              width: mq.size.width,
              height: 4.0,
              margin: const Pad(vertical: 6),
              child: Center(
                child: ListView.separated(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) => Container(
                    width: mq.size.width * 0.08 / widget.post.multimediaPostContentRefs.length + widget.post.multimediaPostContentRefs.length ~/ 3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: _selectedImageIndex == index ? theme.textColor.withOpacity(.7) : theme.textColor.withOpacity(.3)
                    ),
                  ),
                  separatorBuilder: (context, index) => const SizedBox(width: 5.0),
                  itemCount: widget.post.multimediaPostContentRefs.length
                ),
              ),
            ),
          ],
        ),
        
        // ? Описание
        if (widget.post.description != null) GestureDetector(
          // onTap: () => GoRouter.of(context).push('/post?id=${widget.post.id.toString()}&postType=${PostType.profilePosts.name.toString()}&index=$_selectedImageIndex'),
          child: Container(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 12),
            width: MediaQuery.of(context).size.width,
            child: Text(
              widget.post.description!,
              maxLines: isVideo ? 3 : 8,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                color: isVideo ? theme.textColor : theme.textColor,
                fontWeight: FontWeight.normal
              )
            )
          ),
        ),
      ],
    );
    // ignore: curly_braces_in_flow_control_structures
    else return Column(
      children: [
        // ? Фото
        if (widget.post.contentType == PostContentType.imageAndText || widget.post.contentType == PostContentType.singleImage) Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10.0),
              constraints: BoxConstraints(
                maxHeight: mq.size.height * 0.5,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.hardEdge,
              child: widget.post.multimediaPostContentRefs.length > 1 ? PageView.builder( // ExpandablePageView
                controller: PageController(viewportFraction: 0.93),
                physics: const ClampingScrollPhysics(),
                itemCount: widget.post.multimediaPostContentRefs.length,
                onPageChanged: (index) {
                  setState(() {
                    _selectedImageIndex = index;
                  });
                },
                itemBuilder: (BuildContext context, int index) {
                  return ImageViewer(
                    tag: 'post-${widget.post.id}-$index',
                    child: Container(
                      margin: const Pad(horizontal: 4, vertical: 6),
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        border: fit == BoxFit.cover ? null : Border.all(color: theme.textColor.withOpacity(.2), strokeAlign: BorderSide.strokeAlignOutside),
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.07),
                            blurRadius: 5,
                            spreadRadius: 2
                          )
                        ]
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (fit != BoxFit.cover) ImageFiltered(
                            imageFilter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                            child: CachedNetworkImage(
                              height: mq.size.height,
                              imageUrl: widget.post.multimediaPostContentRefs[index].contentUrl,
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                          CachedNetworkImage(
                            width: mq.size.width,
                            imageUrl: widget.post.multimediaPostContentRefs[index].contentUrl,
                            fit: fit,
                            fadeOutDuration: Duration.zero,
                            progressIndicatorBuilder: (context, url, progress) => Shimmer.fromColors(
                              baseColor: theme.textColor.withOpacity(.4),
                              highlightColor: theme.textColor.withOpacity(.2),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: theme.textColor.withOpacity(.4),
                                ),
                              ),
                            )
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
              : ImageViewer(
                tag: 'post-${widget.post.id}-0',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  clipBehavior: Clip.hardEdge,
                  child: CachedNetworkImage(
                    height: mq.size.height,
                    imageUrl: widget.post.multimediaPostContentRefs[0].contentUrl,
                    fit: fit,
                    fadeOutDuration: Duration.zero,
                    progressIndicatorBuilder: (context, url, progress) => Shimmer.fromColors(
                      baseColor: theme.textColor.withOpacity(.4),
                      highlightColor: theme.textColor.withOpacity(.2),
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.textColor.withOpacity(.4),
                        ),
                      ),
                    )
                  ),
                ),
              )
            ),
            // ? Пагинатор
            if (!isVideo && widget.post.multimediaPostContentRefs.length > 1) Container(
              width: mq.size.width,
              height: 4.0,
              margin: const Pad(vertical: 6),
              child: Center(
                child: ListView.separated(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) => Container(
                    width: mq.size.width * 0.08 / widget.post.multimediaPostContentRefs.length + widget.post.multimediaPostContentRefs.length ~/ 3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: _selectedImageIndex == index ? theme.textColor.withOpacity(.7) : theme.textColor.withOpacity(.3)
                    ),
                  ),
                  separatorBuilder: (context, index) => const SizedBox(width: 5.0),
                  itemCount: widget.post.multimediaPostContentRefs.length
                ),
              ),
            ),
          ],
        ),
        
        // ? Видео
        if (widget.post.contentType == PostContentType.videoAndText || widget.post.contentType == PostContentType.singleVideo) GestureDetector(
          // onTap: () async { // ! тут onTap нельзя делать, он находится внутри [FlickMultiPlayer] и срабатывает ТОЛЬКО ОТТУДА
          //   _openInFullScreen();
          // },
          child: Container(
            clipBehavior: Clip.hardEdge,
            height: mq.size.height * 0.65,
            margin: const Pad(top: 10),
            alignment: Alignment.center,
            decoration: const BoxDecoration(),
            child: Text(
              'Скоро тут будет пост с видео. А пока его нет',
              style: TextStyle(color: theme.textColor),
            ),
            // child: FlickMultiPlayer(
            //   url: widget.post.multimediaPostContentRefs[videoIndexPosition].contentUrl,
            //   image: widget.post.multimediaPostContentRefs[videoPreviewImageIndexPosition].contentUrl,
            //   fit: _getObjectFit(widget.post),
            //   flickMultiManager: _flickMultiManager,
            //   postType: PostType.profilePosts,
            //   onTap: null//_openInFullScreen,
            // ),
          ),
        ),
        
        // ? Голосовое
        if (widget.post.contentType == PostContentType.voice) Padding(
          padding: const Pad(top: 15),
          child: Container(
            padding: const Pad(all: 10),
            decoration: BoxDecoration(
              color: theme.frontColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.05),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                ),
              ]
            ),
            child: Wrap(
              children: [
                if (widget.post.multimediaPostContentRefs.first.contentUrl.startsWith('{')) Material(
                  type: MaterialType.transparency,
                  child: VoiceMessageView(
                    controller: VoiceController(
                      audioSrc: json.decode(widget.post.multimediaPostContentRefs.first.contentUrl)['url'],
                      maxDuration: Duration(milliseconds: json.decode(widget.post.multimediaPostContentRefs.first.contentUrl)['duration']),
                      isFile: false,
                      onComplete: () {},
                      onPause: () {},
                      onPlaying: () {},
                      onError: (err) {},
                    ),
                    // me: widget.post.author.id == AuthenticationLocalDataSource().currentUser!.id,
                    // duration: Duration(milliseconds: json.decode(widget.post.multimediaPostContentRefs.first.contentUrl)['duration']),
                    // mePlayIconColor: Colors.black,
                    // contactPlayIconColor: Colors.black,
                    // contactPlayIconBgColor: theme.brandColor,
                    // meBgColor: theme.frontColor.withOpacity(.4),
                    // contactBgColor: theme.frontColor.withOpacity(.4),
                    // meFgColor: theme.brandColor,
                    // contactFgColor: theme.brandColor,
                    // contactCircleColor: theme.brandColor,
                    // formatDuration: (Duration duration) {
                    //   return duration.toString().substring(2, 7);
                    // },
                    // audioSrc: json.decode(widget.post.multimediaPostContentRefs.first.contentUrl)['url'],//'https://sounds-mp3.com/mp3/0012660.mp3',
                  ),
                )
                else Text('Контент сообщения повреждён', style: TextStyle(fontSize: 15, color: theme.textColor.withOpacity(.5), fontStyle: FontStyle.italic))
              ],
            ),
          ),
        ),
        
        // ? Описание
        if (widget.post.description != null && widget.post.contentType != PostContentType.voice && widget.post.contentType != PostContentType.videoMessage) GestureDetector(
          // onTap: () => GoRouter.of(context).push('/post?id=${widget.post.id.toString()}&postType=${PostType.profilePosts.name.toString()}&index=$_selectedImageIndex'),
          child: Container(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 12),
            width: MediaQuery.of(context).size.width,
            child: Text(
              widget.post.description!,
              maxLines: isVideo ? 3 : 8,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                color: isVideo ? theme.textColor : theme.textColor,
                fontWeight: FontWeight.normal
              )
            )
          ),
        ),
      ],
    );
  }
}

class _PostBottomBar extends StatefulWidget {
  const _PostBottomBar({required this.post, required this.postType, this.onPostRemove});

  final UserMultimediaPostModel post;
  final PostType postType;
  final void Function(int postId)? onPostRemove;

  @override
  State<_PostBottomBar> createState() => _PostBottomBarState();
}

class _PostBottomBarState extends State<_PostBottomBar> {
  bool isVideo = false;
  final int _selectedImageIndex = 0;

  UserContentController? _userContentController;
  final AuthenticationLocalDataSource _authenticationLocalDataSource = AuthenticationLocalDataSource();

  @override
  void initState() {
    _userContentController ??= Get.find<UserContentController>(tag: widget.post.author.nickname);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var theme = PotokTheme.of(context);

    // Проверка, видео это или нет
    if (widget.post.multimediaPostContentRefs.length == 2) {
      if (p.extension(widget.post.multimediaPostContentRefs[0].contentUrl).toLowerCase() == '.mp4') {
        isVideo = true;
      }
      if (p.extension(widget.post.multimediaPostContentRefs[1].contentUrl).toLowerCase() == '.mp4') {
        isVideo = true;
      }
    }

    return GetBuilder<UserContentController>(
      tag: widget.post.author.nickname,
      builder: (userContentController) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                // ? Лайки
                LikeButton(
                  likeCount: widget.post.likeAmount,
                  isLiked: widget.post.isLiked,
                  padding: const Pad(vertical: 0, horizontal: 6),
                  // likeCountPadding: const EdgeInsets.all(12),
                  likeBuilder: (bool isLiked) {
                    return isLiked ? Image.asset('assets/icons/normal/Red_heart_3d.png') : Image.asset('assets/icons/normal/Red_heart_3d_unliked.png');
                    // return Icon(
                    //   isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    //   color: isLiked 
                    //   ? !widget.post.isLunaPost 
                    //     ? Colors.deepOrangeAccent.withOpacity(.9) 
                    //     : theme.brandColor.withOpacity(.75) 
                    //   : isVideo ? Colors.white.withOpacity(.75) : theme.textColor.withOpacity(.75),
                    //   size: 28.0,
                    // );
                  },
                  onTap: (isLiked) async {
                    bool? result = await userContentController.likePost(context, isLiked: isLiked, postId: widget.post.id);
                    if (result != null) {
                      widget.post.isLiked = result;
                      if (result == true) {
                        widget.post.likeAmount++;
                      } else if (result == false) {
                        widget.post.likeAmount--;
                      }
                    }
                    return result;
                  },
                  countBuilder: (int? count, bool isLiked, String text) {
                    return Text(
                      text,
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w700,
                        color: isVideo ? theme.textColor : theme.textColor
                      ),
                    );
                  }
                ),
                // const SizedBox(width: 14.0),
                
                // ? Комментарии
                // if (false) InkWell(
                //   onTap: () {
                //     GoRouter.of(context).push('/post?id=${widget.post.id.toString()}&postType=${PostType.profilePosts.name.toString()}&index=$_selectedImageIndex'); 
                //   },
                //   child: Padding(
                //     padding: const Pad(horizontal: 6, vertical: 12),
                //     child: Row(
                //       children: [
                //         SvgPicture.asset(
                //           'assets/icons/normal/lines_chat_icon.svg',
                //           width: 22,
                //           height: 22,
                //           color: isVideo ? Colors.white.withOpacity(.75) : theme.textColor.withOpacity(.75)
                //         ),
                //         const SizedBox(width: 6.0),
                //         Text(
                //           widget.post.commentAmount.toString(),
                //           style: TextStyle(
                //             fontSize: 14.0,
                //             fontWeight: FontWeight.w700,
                //             color: isVideo ? Colors.white : theme.textColor
                //           ),
                //         ),
                //       ],
                //     ),
                //   )
                // ),
                
                // ? Сохранить
                LikeButton(
                  padding: const Pad(vertical: 0, horizontal: 6),
                  isLiked: widget.post.isSaved,
                  likeCount: widget.post.savedAmount,
                  bubblesColor: BubblesColor(dotPrimaryColor: theme.brandColor.withOpacity(.5), dotSecondaryColor: theme.brandColor),
                  circleColor: CircleColor(start: theme.textColor, end: theme.brandColor),
                  likeBuilder: (bool isSaved) {
                    return isSaved ? Image.asset('assets/icons/normal/Package_3d.png') : Image.asset('assets/icons/normal/Package_3d_unsaved.png');
                    // return Icon(
                    //   isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    //   color: isSaved 
                    //   ? widget.post.isLunaPost 
                    //     ? Colors.white.withOpacity(.85) 
                    //     : theme.brandColor.withOpacity(.85) 
                    //   : isVideo ? Colors.white.withOpacity(.75) : theme.textColor.withOpacity(.75),
                    //   size: 28.0,
                    // );
                  },
                  onTap: (isSaved) async {
                    bool? result = await userContentController.savePost(context, isSaved: isSaved, postId: widget.post.id);
                    if (result != null) {
                      widget.post.isSaved = result;
                      if (result == true) {
                        widget.post.savedAmount++;
                      } else if (result == false) {
                        widget.post.savedAmount--;
                      }
                    }
                    return result;
                  },
                  countBuilder: (int? count, bool isLiked, String text) {
                    return Text(
                      text,
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w700,
                        color: isVideo ? theme.textColor : theme.textColor
                      ),
                    );
                  }
                ),
                
                // ? Поделиться
                // if (false) InkWell(
                //   onTap: () async {
                //     // ? implement this
                //     // if (_authenticationLocalDataSource.currentUser == null) {
                //     //   await showUnauthWarning(context);
                //     //   return;
                //     // }
                //     // await openShareBottomSheet(context, onUserSelected: (UserInfoModel interlocutor) async {
                //     //   UserMessageModel? response = await Get.find<MessengerHub>().sendMessage(interlocutor.id, widget.post.id.toString(), contentType: widget.post.fileView, replyMessageId: null);
                //     //   return response;
                //     // });
                //   },
                //   child: Padding(
                //     padding: const Pad(vertical: 12, horizontal: 3),
                //     child: Row(
                //       children: [
                //         SvgPicture.asset(
                //           'assets/icons/normal/Share.svg',
                //           width: 22,
                //           height: 22,
                //           color: isVideo ? Colors.white.withOpacity(.75) : theme.textColor.withOpacity(.75)
                //         ),
                //         // const SizedBox(width: 8.0),
                //         // Text(
                //         //   widget.post.commentAmount.toString(),
                //         //   style: const TextStyle(
                //         //     fontSize: 14.0,
                //         //     fontWeight: FontWeight.w600,
                //         //     color: Colors.white70
                //         //   ),
                //         // ),
                //       ],
                //     ),
                //   )
                // ),
                
                const Spacer(),
        
                // ? Ещё
                if (true) Material(
                  type: MaterialType.transparency,
                  child: PopupMenuButton(
                    padding: EdgeInsets.zero,
                    iconSize: 24,
                    color: theme.frontColor,
                    child: Icon(Icons.more_horiz, color: theme.iconColor),
                    itemBuilder: (context) => [
                      if (_authenticationLocalDataSource.currentUser == null || widget.post.author.id != _authenticationLocalDataSource.currentUser?.id) PopupMenuItem(
                        value: 0,
                        child: Text(ResourceString.complain, style: TextStyle(color: theme.textColor, fontSize: 14.0),),
                      ),
                      if (_authenticationLocalDataSource.currentUser != null && widget.post.author.id == _authenticationLocalDataSource.currentUser?.id) PopupMenuItem(
                        value: 1,
                        child: Text(ResourceString.deletePost, style: TextStyle(color: theme.textColor, fontSize: 14.0),),
                      ),
                      if (_authenticationLocalDataSource.currentUser != null && widget.post.author.id == _authenticationLocalDataSource.currentUser?.id) PopupMenuItem(
                        value: 2,
                        child: Text(ResourceString.moveToArchive, style: TextStyle(color: theme.textColor, fontSize: 14.0),),
                      ),
                    ],
                    onSelected: (item) async {
                      // TODO: implement this
                      // if (item == 0) FlagDialog.showFlagDialog(context, FlagType.post, widget.post);
                      // if (item == 1) {
                      //   bool result = await DeleteContent.deleteProfilePost(context, widget.post.id);
                      //   Navigator.pop(context);
                      //   if (result == true && widget.onPostRemove != null) widget.onPostRemove!(widget.post.id);
                      // }
                      // if (item == 2) {
                      //   ActionResult response = await UserMultimediaPostService.archivatePost(widget.post.id);
                      //   if (response.statusCode == 200) {
                      //     PotokSnackbar.success(context, message: ResourceString.postMovedToArchive);
                      //     if (widget.onPostRemove != null) widget.onPostRemove!(widget.post.id);
                      //   }
                      //   else {
                      //     PotokSnackbar.failure(context, title: ResourceString.error, message: ResourceString.errorDefault);
                      //   }
                      // }
                    }
                  ),
                ),
        
              ],
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    var postParameters = PostParameters(post: widget.post, postType: widget.postType, selectedImageIndex: _selectedImageIndex);
                    GoRouter.of(context).push(NavigationRoutesString.post, extra: postParameters); 
                  },
                  child: Text(
                    'КОММЕНТОВ -> ${widget.post.commentAmount}',
                    style: TextStyle(
                      color: theme.brandColor,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ),
                const Spacer(),
                TextButton(
                  onPressed: () async {
                    if (_authenticationLocalDataSource.currentUser == null) {
                      await showUnauthWarning(context);
                      return;
                    }
        
                    // TODO: implement this
                    // await openShareBottomSheet(context, onUserSelected: (UserInfoModel interlocutor) async {
                    //   String messageContentType = 'profile-post-${widget.post.contentType.asString()}';
                    //   UserMessageModel? response = await Get.find<MessengerHub>().sendMessage(interlocutor.id, widget.post.id.toString(), contentType: messageContentType, replyMessageId: null);
                    //   return response;
                    // });
                  },
                  child: Text(
                    'ПОДЕЛИТЬСЯ ->',
                    style: TextStyle(
                      color: theme.brandColor,
                      fontWeight: FontWeight.bold
                    ),
                  )
                ),
              ],
            )
          ],
        );
      }
    );
  }
}