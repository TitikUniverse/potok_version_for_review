
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:like_button/like_button.dart';
import 'package:path/path.dart' as p;
import 'package:shimmer/shimmer.dart';
import 'package:voice_message_package/voice_message_package.dart';

import '../../../data/models/user/user_info_model.dart';
import '../../../data/models/user_content/comment_mode.dart';
import '../../../data/models/user_content/post_content_type.dart';
import '../../../data/models/user_content/user_multimedia_post_model.dart';
import '../../../theme/potok_theme.dart';
import '../../../utils/color_print.dart';
import '../../user_profile/state/user_content_controller.dart';
import '../../widgets/image_viewer.dart';
import '../components/user_who_liked_post_screen.dart';
import '../state/post_controller.dart';

class ViewPostScreen extends StatefulWidget {
  const ViewPostScreen({super.key, required this.userMultimediaPost, this.selectedImageIndex = 0, this.showOnlyComment = false, this.screenUpScrollDepth = -50});

  final UserMultimediaPostModel userMultimediaPost;
  final bool showOnlyComment;
  final int screenUpScrollDepth;
  final int selectedImageIndex;

  @override
  _ViewPostScreenState createState() => _ViewPostScreenState();
}

class _ViewPostScreenState extends State<ViewPostScreen> {
  late final PostController _postController;
  late UserMultimediaPostModel _userMultimediaPost;
  String? alwaysShowingDescription;
  String? hiddenDescription;
  bool isShowingDescription = false;

  late ScrollController _scrollController;
  late TextEditingController _newCommentController;
  bool topFlag = false;
  int _selectedImageIndex = 0;
  final DateFormat dateFormat = DateFormat("dd MMM HH:mm");
  final FocusNode _focusNode = FocusNode();
  

  Future<void> _addNewComment() async {
    _postController.addNewComment(context, postId: _userMultimediaPost.id, text: _newCommentController.text.trim());
  }

  void _scrollListener() {
    if (_scrollController.offset <= widget.screenUpScrollDepth && topFlag == false) {
      topFlag = true;
      printInfo("reach the top", name: '$ViewPostScreen');
      GoRouter.of(context).pop();
    }
  }

  bool _showPostImage() {
    if (widget.userMultimediaPost.multimediaPostContentRefs.isNotEmpty) {
      if (widget.userMultimediaPost.contentType == PostContentType.voice || widget.userMultimediaPost.contentType == PostContentType.videoMessage || widget.userMultimediaPost.contentType == PostContentType.singleText) {
        return false;
      }
      return true;
    } 
    else {
      return false;
    }
  }

  @override
  void initState() {
    // initializeDateFormatting();
    
    _postController = Get.put(PostController(), tag: widget.userMultimediaPost.id.toString());
    _scrollController = ScrollController();
    _newCommentController = TextEditingController();
    _userMultimediaPost = widget.userMultimediaPost;
    _postController.fetchComments(postId: _userMultimediaPost.id);
    if (widget.userMultimediaPost.likeAmount != 0) _postController.tryFetchUsersWhoLike(postId: _userMultimediaPost.id);
    _scrollController.addListener(_scrollListener);
    if (_userMultimediaPost.description != null && _userMultimediaPost.description != '') {
        if (_userMultimediaPost.description!.length > 200) {
        alwaysShowingDescription = _userMultimediaPost.description!.substring(0, 200);
        hiddenDescription = _userMultimediaPost.description!.substring(200, _userMultimediaPost.description!.length);
      } else {
        alwaysShowingDescription = _userMultimediaPost.description;
        hiddenDescription = "";
      }
    } 
    _selectedImageIndex = widget.selectedImageIndex;

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _newCommentController.dispose();
    Get.delete<PostController>(tag: widget.userMultimediaPost.id.toString());
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var theme = PotokTheme.of(context);
    bool isVideo = false;
    int videoPreviewImageIndexPosition = 0;

    // Проверка, видео это или нет
    if (_userMultimediaPost.multimediaPostContentRefs.length == 2) {
      if (p.extension(_userMultimediaPost.multimediaPostContentRefs[0].contentUrl).toLowerCase() == '.mp4') {
        isVideo = true;
        videoPreviewImageIndexPosition = 1;
      }
      if (p.extension(_userMultimediaPost.multimediaPostContentRefs[1].contentUrl).toLowerCase() == '.mp4') {
        isVideo = true;
        videoPreviewImageIndexPosition = 0;
      }
    }

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: SafeArea(
        top: false,
        child: ListView(
          padding: widget.showOnlyComment ? EdgeInsets.zero : EdgeInsets.zero,
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          controller: _scrollController,
          children: <Widget>[
            // ? Фотка поста вверху
            if (!widget.showOnlyComment) Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10.0),
              width: double.infinity,
              // height: size.height, // Тут надо commentAmount == null ? size.height : null - это чтобы не было полоски внизу при прокрутке, если нет комментов. или же в колумн ниже по дереву добавлять пустой прозрачный контейнер
              decoration: BoxDecoration(
                image: _showPostImage() ? DecorationImage(
                  image: CachedNetworkImageProvider(
                    isVideo ? widget.userMultimediaPost.multimediaPostContentRefs[videoPreviewImageIndexPosition].contentUrl : widget.userMultimediaPost.multimediaPostContentRefs[0].contentUrl
                  ),
                  fit: BoxFit.contain
                ) : null,
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(40.0),
                  bottomLeft: Radius.circular(40.0)
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50.0, sigmaY: 50.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // ? Стрелка указывающая вниз
                      Padding(
                        padding: const EdgeInsets.only(top: 0.0, bottom: 10.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 40,
                            color: theme.iconColor.withOpacity(0.25),
                          ),
                        ),
                      ),

                      // ? Фотка
                      if (_showPostImage() == true) GestureDetector(
                        onDoubleTap: () => Get.find<UserContentController>().doubleTapLikePost(context, post: _userMultimediaPost),
                        child: Container(
                          width: widget.userMultimediaPost.multimediaPostContentRefs.length > 1 ? null : size.width * 0.7,
                          height: size.width * 0.7,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25.0)
                          ),
                          child: widget.userMultimediaPost.multimediaPostContentRefs.length > 1 && !isVideo
                          ? PageView.builder(
                            controller: PageController(initialPage: _selectedImageIndex, viewportFraction: 0.75),
                            itemCount: widget.userMultimediaPost.multimediaPostContentRefs.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: Pad(horizontal: size.width * 0.025),
                                child: ImageViewer(
                                  tag: 'post-${widget.userMultimediaPost.id}-$index',
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(25.0),
                                    child: CachedNetworkImage(
                                      imageUrl: widget.userMultimediaPost.multimediaPostContentRefs[index].contentUrl,
                                      fit: BoxFit.cover,
                                      filterQuality: FilterQuality.high,
                                    ),
                                  ),
                                ),
                              );
                            },
                            onPageChanged: (index) {
                              setState(() {
                                _selectedImageIndex = index;
                              });
                            },
                          )
                          : ImageViewer(
                            tag: 'post-${widget.userMultimediaPost.id}-0',
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(25.0),
                              child: CachedNetworkImage(
                                width: size.width * 0.7,
                                imageUrl: isVideo ? widget.userMultimediaPost.multimediaPostContentRefs[videoPreviewImageIndexPosition].contentUrl : widget.userMultimediaPost.multimediaPostContentRefs[0].contentUrl,
                                fit: BoxFit.cover,
                                filterQuality: FilterQuality.high
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ? Голосовое сообщение
                      if (_userMultimediaPost.contentType == PostContentType.voice) Wrap(
                        children: [
                          Container(
                            clipBehavior: Clip.hardEdge,
                            margin: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 6.0),
                            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [theme.frontColor, theme.frontColor],
                                begin: const FractionalOffset(0.0, 0.0),
                                end: const FractionalOffset(1.0, 0.0),
                                stops: const [0.0, 1.0],
                                tileMode: TileMode.clamp
                              ),
                              borderRadius: const BorderRadius.only(
                                // topLeft:  !_isOwnerMessage && _message.replyMessage != null ? const Radius.circular(3.0) : const Radius.circular(18.0),
                                // topRight: _isOwnerMessage && _message.replyMessage != null ? const Radius.circular(3.0) : const Radius.circular(18.0),
                                topLeft: Radius.circular(18.0),
                                topRight: Radius.circular(18.0),
                                bottomLeft: Radius.circular(18.0),
                                bottomRight: Radius.circular(18.0),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(.03),
                                  blurRadius: 6.0,
                                  offset: const Offset(0, 2)
                                )
                              ]
                            ),
                            child: VoiceMessageView(
                              controller: VoiceController(
                                audioSrc: json.decode(_userMultimediaPost.multimediaPostContentRefs.first.contentUrl)['url'],
                                maxDuration: Duration(milliseconds: json.decode(_userMultimediaPost.multimediaPostContentRefs.first.contentUrl)['duration']),
                                isFile: false,
                                onComplete: () {},
                                onPause: () {},
                                onPlaying: () {},
                                onError: (err) {},
                              ),
                              // me: true,
                              // duration: Duration(milliseconds: json.decode(_userMultimediaPost.multimediaPostContentRefs.first.contentUrl)['duration']),
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
                              // audioSrc: json.decode(_userMultimediaPost.multimediaPostContentRefs.first.contentUrl)['url'],//'https://sounds-mp3.com/mp3/0012660.mp3',
                            ),
                          )
                        ],
                      ),
                      
                      // ? Пагинатор
                      if (!isVideo && _userMultimediaPost.multimediaPostContentRefs.length > 1) Container(
                        width: size.width,
                        height: 4.0,
                        margin: const Pad(vertical: 16),
                        child: Center(
                          child: ListView.separated(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) => Container(
                              width: size.width * 0.08 / _userMultimediaPost.multimediaPostContentRefs.length + _userMultimediaPost.multimediaPostContentRefs.length ~/ 3,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.0),
                                color: _selectedImageIndex == index ? theme.iconColor.withOpacity(.3) : theme.iconColor.withOpacity(.15)
                              ),
                            ),
                            separatorBuilder: (context, index) => const SizedBox(width: 5.0),
                            itemCount: _userMultimediaPost.multimediaPostContentRefs.length
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      ActoinsPost()
                    ],
                  ),
                ),
              )
            ),
            // if (!widget.showOnlyComment && widget.userMultimediaPost.multimediaPostContentRefs.isEmpty) Column(
            //   mainAxisSize: MainAxisSize.min,
            //   children: [
            //     SizedBox(height: MediaQuery.of(context).padding.top + 10.0),
            //     // ? Стрелка указывающая вниз
            //     GestureDetector(
            //       onTap: () {
            //         Navigator.of(context).pop();
            //       },
            //       child: Icon(
            //         Icons.keyboard_arrow_down,
            //         size: 40,
            //         color: Colors.white54.withOpacity(0.25),
            //       ),
            //     ),
            //   ],
            // ),
            
            if (!widget.showOnlyComment) const SizedBox(height: 10.0),

            // ? Описание поста
            if (alwaysShowingDescription != null) Container(
              width: double.infinity,
              // height: 500.0,
              margin: widget.showOnlyComment ? const EdgeInsets.only(top: 10.0) : EdgeInsets.zero,
              padding: !widget.showOnlyComment ? const EdgeInsets.only(top: 10.0) : EdgeInsets.zero,
              decoration: const BoxDecoration(
                // color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
              ),
              child: _buildPostDescription(),
            ),

            // ? Переход к списку тех, кто лайкинул пост
            if (widget.userMultimediaPost.likeAmount != 0) GetBuilder<PostController>(
              tag: widget.userMultimediaPost.id.toString(),
              builder: (controller) {
                if (controller.usersWhoLike == null) {
                  return  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Shimmer.fromColors(
                        baseColor: theme.backgroundColor,
                        highlightColor: theme.frontColor,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: 30,
                          margin: const Pad(bottom: 10),
                          decoration: BoxDecoration(
                            color: theme.backgroundColor,
                            borderRadius: BorderRadius.circular(9)
                          ),
                        ),
                      )
                    ],
                  );
                }
                if (controller.usersWhoLike!.isEmpty) {
                  return const SizedBox.shrink();
                }
                return InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) {
                        return SafeArea(
                          bottom: false,
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.55,
                            decoration: BoxDecoration(
                              color: theme.frontColor,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0))
                            ),
                            child: Column(
                              children: [
                                Container(
                                  height: 5,
                                  width: 70,
                                  margin: const EdgeInsets.only(top: 10.0, bottom: 15.0),
                                  decoration: BoxDecoration(
                                    color: theme.textColor.withOpacity(.2),
                                    borderRadius: BorderRadius.circular(30),
                                    shape: BoxShape.rectangle,
                                  ),
                                ),
                                Expanded(
                                  child: UserWhoLikedPostScreen(post: widget.userMultimediaPost),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    );
                  },
                  child: Padding(
                    padding: const Pad(horizontal: 15.0, vertical: 10.0),
                    child: WhoLikeButton(users: controller.usersWhoLike ?? []),
                  ),
                );
              },
            ),
        
            if (widget.userMultimediaPost.description != null || widget.userMultimediaPost.likeAmount != 0) Divider(thickness: 1.0, color: theme.iconColor.withOpacity(.2), height: 3.0),
            
            // ? Комментарии
            Container(
              width: double.infinity,
              // height: 500.0,
              padding: const Pad(vertical: 10.0),
              decoration: const BoxDecoration(
                // color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
              ),
              child: GetBuilder<PostController>(
                tag: widget.userMultimediaPost.id.toString(),
                builder: (controller) {
                  if (controller.comments == null) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive()
                    );
                  }
                  if (controller.comments!.isEmpty) {
                    return Center(
                      child: Text(
                        "Комментариев пока нет",
                        style: TextStyle(
                          color: theme.textColor.withOpacity(.5)
                        )
                      )
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    primary: false,
                    physics: const NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    itemCount: controller.comments?.length ?? 0,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) => CommentItem(commentModel: controller.comments![index], postAuthorId: widget.userMultimediaPost.author.id)
                  );
                },
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, -2),
              blurRadius: 6.0,
            ),
          ],
          color: theme.backgroundColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: TextField(
                      focusNode: _focusNode,
                      controller: _newCommentController,
                      maxLines: 3,
                      minLines: 1,
                      showCursor: true,
                      keyboardAppearance: theme.brightness,
                      textCapitalization: TextCapitalization.sentences,
                      autocorrect: true,
                      cursorColor: theme.brandColor,
                      keyboardType: TextInputType.multiline,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          color: theme.textColor),
                      cursorRadius: const Radius.circular(5.0),
                      decoration: InputDecoration(
                        hintText: "Писать здесь...",
                        hintStyle: TextStyle(
                          color: theme.textColor.withOpacity(.5),
                          fontSize: 15,
                          fontWeight: FontWeight.normal),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none
                      ),
                    ),
                  ),
                ),
                // const SizedBox(width: 5),
                // IconButton(
                //   onPressed: () {
                //     if (_focusNode.hasFocus) {
                //       FocusScope.of(context).unfocus();
                //     } 
                //     else {
                //       FocusScope.of(context).requestFocus(_focusNode);
                //     }
                //   }, 
                //   icon: _focusNode.hasFocus 
                //   ? const Icon(
                //     Icons.keyboard_arrow_down_rounded,
                //     size: 30,
                //     color: Colors.white54,
                //   )
                //   : const Icon(
                //     Icons.keyboard,
                //     color: Colors.white54,
                //     size: 30,
                //   )
                // ),
                
                GetBuilder<PostController>(
                  tag: widget.userMultimediaPost.id.toString(),
                  builder: (controller) {
                    if (controller.isCommentSending == false) {
                      return FloatingActionButton(
                        onPressed: () {
                          _addNewComment();
                          if (_focusNode.hasFocus) {
                            FocusScope.of(context).unfocus();
                          } 
                          // else {
                          //   FocusScope.of(context).requestFocus(_focusNode);
                          // }
                        },
                        child: (Platform.isIOS) ? SvgPicture.asset(
                          'assets/icons/normal/Share.svg',
                          width: 20,
                          height: 20,
                          color: theme.brandColor
                        ) : Icon(
                          Icons.send,
                          color: theme.brandColor,
                          size: 25,
                        ),
                        backgroundColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        highlightElevation: 0,
                        disabledElevation: 0,
                        focusElevation: 0,
                        hoverElevation: 0,
                        elevation: 0,
                      );
                    }
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator.adaptive(),
                    );
                  },
                )
              ],
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom,),
          ],
        ),
      ),
    );
  }

  Widget _buildPostDescription() {
    Size size = MediaQuery.of(context).size;
    var theme = PotokTheme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: widget.showOnlyComment ? 0 : 10.0, horizontal: 12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onLongPress: () {
              // TODO: implement this
              // CommentProperties.showCommentProperties(context, widget.userMultimediaPost, FlagType.post);
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ? Аватар
                CircleAvatar(
                  backgroundColor: theme.backgroundColor,
                  child: ClipOval(
                    child: (_userMultimediaPost.author.avatarUrl == null || widget.userMultimediaPost.author.avatarUrl == '')
                    ? const Image(
                      height: 45.0,
                      width: 45.0,
                      image: AssetImage('assets/images/noavatar.png'),
                      fit: BoxFit.cover,
                    )
                    : CachedNetworkImage(
                      fadeInDuration: Duration.zero,
                      height: 45.0,
                      width: 45.0,
                      imageUrl: _userMultimediaPost.author.avatarUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (context, error, stackTrace) => const Icon(Icons.error)
                    )
                  ),
                ),


                Container(
                  width: size.width - 75,
                  margin: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        _userMultimediaPost.author.nickname,
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                            fontSize: 15,
                            color: theme.textColor,
                            fontWeight: FontWeight.w800),
                      ),
                      hiddenDescription!.isEmpty
                      ? Text(alwaysShowingDescription!, style: TextStyle(fontSize: 15, color: theme.textColor),)
                      : Column(
                          children: <Widget>[
                            Text(
                              isShowingDescription ? (alwaysShowingDescription! + hiddenDescription!) : (alwaysShowingDescription! + "..."),
                              style: TextStyle(fontSize: 15, color: theme.textColor),
                            ),
                            const SizedBox(height: 5.0,),
                            GestureDetector(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Text(
                                    isShowingDescription ? "Cкрыть" : "Больше",
                                    style: TextStyle(fontSize: 15, color: theme.brandColor),
                                  ),
                                ],
                              ),
                              onTap: () {
                                setState(() {
                                  isShowingDescription = !isShowingDescription;
                                });
                              },
                            ),
                          ],
                        ),
          
                      // Text(
                      //   widget.userMultimediaPost.description != null
                      //       ? alwaysShowingDescription!
                      //       : '',
                      //   textAlign: TextAlign.start,
                      //   overflow: TextOverflow.clip,
                      //   style: const TextStyle(fontSize: 15, color: Colors.white),
                      // ),
                      // const SizedBox(
                      //   height: 3.0,
                      // ),
                      // const Text(
                      //   '',
                      //   style: TextStyle(fontSize: 12, color: Colors.white54),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20.0,),
          // Container(
          //   padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
          //   child: const Divider(thickness: 1.0, color: Constant.frontColor, height: 3.0)
          // )
        ],
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget ActoinsPost() {
    var theme = PotokTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: [
              LikeButton(
                padding: const EdgeInsets.only(left: 8.0),
                likeCount: _userMultimediaPost.likeAmount,
                isLiked: _userMultimediaPost.isLiked,
                likeBuilder: (bool isLiked) {
                  return Icon(
                    isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isLiked 
                    ? !_userMultimediaPost.isLunaPost 
                      ? Colors.deepOrangeAccent 
                      : theme.brandColor 
                    : theme.textColor.withOpacity(.75),
                    size: 30.0,
                  );
                },
                onTap: (isLiked) async {
                  var userContentController = Get.find<UserContentController>();
                  bool? result = await userContentController.likePost(context, isLiked: isLiked, postId: _userMultimediaPost.id);
                  if (result != null) {
                    _userMultimediaPost.isLiked = result;
                    if (result == true) {
                      _userMultimediaPost.likeAmount++;
                    } else if (result == false) {
                      _userMultimediaPost.likeAmount--;
                    }
                  }
                  return result;
                },
                countBuilder: (int? count, bool isLiked, String text) {
                  return Text(
                    text,
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      color: theme.textColor
                    ),
                  );
                }
              ),
              const SizedBox(width: 20.0),
              Row(
                children: [
                  SvgPicture.asset(
                      'assets/icons/normal/lines_chat_icon.svg',
                      width: 24,
                      height: 24,
                      color: theme.textColor.withOpacity(.75)),
                  const SizedBox(width: 8.0),
                  Text(
                    _userMultimediaPost.commentAmount.toString(),
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      color: theme.textColor
                    ),
                  ),
                ],
              ),
            ],
          ),
          LikeButton(
            padding: const EdgeInsets.only(right: 8.0),
            isLiked: _userMultimediaPost.isSaved,
            bubblesColor: BubblesColor(dotPrimaryColor: theme.brandColor.withOpacity(.5), dotSecondaryColor: theme.brandColor),
            circleColor: CircleColor(start: theme.textColor, end: theme.brandColor),
            likeBuilder: (bool isSaved) {
              return Icon(
                isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                color: isSaved 
                ? !_userMultimediaPost.isLunaPost 
                  ? theme.brandColor 
                  : theme.brandColor 
                : theme.textColor.withOpacity(.75),
                size: 30.0,
              );
            },
            onTap: (isSaved) async {
              var userContentController = Get.find<UserContentController>();
              bool? result = await userContentController.savePost(context, isSaved: isSaved, postId: _userMultimediaPost.id);
              if (result != null) {
                _userMultimediaPost.isSaved = result;
                if (result == true) {
                  _userMultimediaPost.savedAmount++;
                } else if (result == false) {
                  _userMultimediaPost.savedAmount--;
                }
              }
              return result;
            },
            // countBuilder: (int? count, bool isSaved, String text) {
            //   return Text(
            //     text,
            //     style: const TextStyle(
            //       fontSize: 14.0,
            //       fontWeight: FontWeight.w600,
            //       color: Colors.white70
            //     ),
            //   );
            // }
          ),
        ],
      ),
    );
  }
}

class CommentItem extends StatelessWidget {
  const CommentItem({Key? key, required this.commentModel, required this.postAuthorId}) : super(key: key);

  final UserPostCommentModel commentModel;
  final int postAuthorId;
  
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var theme = PotokTheme.of(context);
    // initializeDateFormatting();
    DateFormat dateFormat = DateFormat("dd MMM HH:mm");

    return GestureDetector(
      onLongPress: () async {
        // TODO: implement this
        // CommentProperties.showCommentProperties(context, commentModel, FlagType.comment, postAuthorId: postAuthorId, fetchComment: fetchComment);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap:() async {
                    GoRouter.of(context).push('/${commentModel.author.nickname}');
                  },
                  child: ClipOval(
                    child: (commentModel.author.avatarUrl == null || commentModel.author.avatarUrl == '')
                    ? const Image(
                      height: 50.0,
                      width: 50.0,
                      image: AssetImage('assets/images/noavatar.png'),
                      fit: BoxFit.cover,
                    )
                    : CachedNetworkImage(
                      fadeInDuration: Duration.zero,
                      height: 50.0,
                      width: 50.0,
                      imageUrl: commentModel.author.avatarUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (context, error, stackTrace) => const Icon(Icons.error)
                    )
                  ),
                ),
                Container(
                  width: size.width * 0.6,
                  margin: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        commentModel.author.nickname,
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                          fontSize: 15,
                          color: theme.textColor,
                          fontWeight: FontWeight.w800
                        ),
                      ),
                      Text(
                        commentModel.text != null
                            ? commentModel.text!
                            : "Null",
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.clip,
                        style: TextStyle(fontSize: 15, color: theme.textColor),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        dateFormat.format(commentModel.dateTimeStamp),
                        style: TextStyle(fontSize: 12, color: theme.textColor.withOpacity(.5)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            LikeButton(
              likeCount: commentModel.likeAmount,
              isLiked: commentModel.isLiked,
              likeBuilder: (bool isLiked) {
                return Icon(
                  isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isLiked ? Colors.deepOrangeAccent : theme.textColor.withOpacity(.5),
                  size: 20.0,
                );
              },
              onTap: (isLiked) async {
                // TODO: implement this
                return isLiked;
                // if (CurrentUser.currentUser == null) {
                //   var _type = FeedbackType.error;
                //   Vibrate.feedback(_type);
                //   OkCancelResult response = await showOkCancelAlertDialog(
                //     context: context,
                //     isDestructiveAction: false,
                //     title: 'Не удалось',
                //     message: 'Чтобы совершить это действие, необходимо войти в аккаунт.\nОткрыть страницу авторизации и регистрации?'
                //   );
                //   if (response.index == 1) return isLiked;
                //   GoRouter.of(context).push('/login');
                //   return isLiked;
                // }
                // var _type = FeedbackType.impact;
                // Vibrate.feedback(_type);
                // late ActionResult<int> result;
                // if (isLiked) {
                //   result = await UserMultimediaPostService.deletePostCommentLikeApi(commentModel.id);
                // } else {
                //   result = await UserMultimediaPostService.addPostCommentLikeApi(commentModel.id);
                // }
                // if (result.statusCode == 200) {
                //   // Это на случай, если лайков наставили уже много, пока юзер решал ставить или нет. Без дилея не срабатывает анимация счетчика лайков
                //   Future.delayed(const Duration(milliseconds: 200), () {
                //     commentModel.isLiked = !isLiked;
                //     if (isLiked) {
                //       commentModel.likeAmount -= 1;
                //     } else {
                //       commentModel.likeAmount += 1;
                //     }
                //     commentModel.likeAmount = result.data!;
                //   });
    
                //   return !isLiked;
                // }
                // else {
                //   commentModel.isLiked = !commentModel.isLiked;
                //   return isLiked;
                // }
              },
              countBuilder: (int? count, bool isLiked, String text) {
                return Text(
                  text,
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: theme.textColor.withOpacity(.5)
                  ),
                );
              }
            ),
          ],
        ),
      ),
    );
  }
}

// TODO: implement this
// class CommentProperties {
//   static Future<void> showCommentProperties(BuildContext context, dynamic subject, FlagType subjectType, {bool isCurrentUserComment = false, int? postAuthorId, void Function()? fetchComment}) async {
//     late UserInfoModel user;
//     UserPostCommentModel? comment;
//     UserMultimediaPostModel? post;

//     void Function()? _fetchComment = fetchComment;

//     if (subjectType == FlagType.account) {
//       UserInfoModel sujectData = subject;
//       user = sujectData;
//     }
//     if (subjectType == FlagType.post) {
//       UserMultimediaPostModel sujectData = subject;
//       user = sujectData.author;
//       post = sujectData;
//     }
//     if (subjectType == FlagType.comment) {
//       UserPostCommentModel sujectData = subject;
//       user = sujectData.author;
//       comment = sujectData;
//     }
    
//     Size size = MediaQuery.of(context).size;
//     var theme = MyTheme.of(context);
//     showMaterialModalBottomSheet(
//         backgroundColor: Colors.transparent,
//         context: context,
//         builder: (context) {
//           return SafeArea(
//             child: StatefulBuilder(
//               builder: (context, setState) => SingleChildScrollView(
//                 controller: ModalScrollController.of(context),
//                 child: Container(
//                   padding: const EdgeInsets.only(
//                     left: 20.0,
//                     right: 20.0,
//                     bottom: 20.0,
//                   ),
//                   decoration: BoxDecoration(
//                     color: theme.frontColor,
//                     borderRadius: const BorderRadius.only(
//                         topLeft: Radius.circular(30.0),
//                         topRight: Radius.circular(30.0)),
//                     shape: BoxShape.rectangle,
//                     boxShadow: const [
//                       BoxShadow(
//                         color: Color(0x44000000),
//                         offset: Offset(0, -2),
//                         blurRadius: 5.0,
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Center(
//                         child: Container(
//                           height: 5,
//                           width: 70,
//                           margin: const EdgeInsets.only(top: 10.0, bottom: 15.0),
//                           alignment: Alignment.topCenter,
//                           decoration: BoxDecoration(
//                             color: theme.textColor.withOpacity(.2),
//                             borderRadius: BorderRadius.circular(30),
//                             shape: BoxShape.rectangle,
//                           ),
//                         ),
//                       ),
                      
//                       DefaultPotokButton(
//                         onTap: () {
//                           Navigator.of(context).pop();
//                           // Navigator.pushNamed(context, '/account', arguments: {'userInfo':  user});
//                           GoRouter.of(context).push('/${user.nickname}');
//                         },
//                         icon: Icons.account_circle_rounded,
//                         text: 'Перейти в профиль'
//                       ),
//                       const SizedBox(height: 8.0),
//                       if (subjectType == FlagType.comment ? comment!.author.id != CurrentUser.currentUser?.id : (subjectType == FlagType.post) ? post!.author.id != CurrentUser.currentUser?.id : false) DefaultPotokButton(
//                         onTap: () async {
//                           // Navigator.of(context).pop();
//                           if (CurrentUser.currentUser == null) {
//                             var _type = FeedbackType.error;
//                             Vibrate.feedback(_type);
//                             OkCancelResult response = await showOkCancelAlertDialog(
//                               context: context,
//                               isDestructiveAction: false,
//                               title: 'Не удалось',
//                               message: 'Чтобы совершить это действие, необходимо войти в аккаунт.\nОткрыть страницу авторизации и регистрации?'
//                             );
//                             if (response.index == 1) return;
//                             GoRouter.of(context).push('/login');
//                             return;
//                           }
//                           FlagDialog.showFlagDialog(context, subjectType, subject);
//                         },
//                         icon: Icons.report_rounded,
//                         text: 'Пожаловаться'
//                       ),
//                       if(subjectType == FlagType.comment ? comment!.author.id != CurrentUser.currentUser?.id : (subjectType == FlagType.post) ? post!.author.id != CurrentUser.currentUser!.id : false) const SizedBox(height: 8.0,),
                      
//                       if((subjectType == FlagType.comment && (comment!.author.id == CurrentUser.currentUser?.id || postAuthorId == CurrentUser.currentUser?.id)) || ((subjectType == FlagType.post && post!.author.id == CurrentUser.currentUser?.id)))
//                       DefaultPotokButton(
//                         onTap: () async {
//                           // TODO: implement this
//                           // if (subjectType == FlagType.comment) {
//                           //   bool r = await DeleteContent.commentDeleteAlert(context, comment!.id);
//                           //   if (r) {
//                           //     Navigator.of(context).pop();
//                           //     // Navigator.pop(context);
//                           //     if (fetchComment != null) fetchComment();
//                           //   } else {
//                           //     Navigator.of(context).pop();
//                           //   }
//                           // }
//                           // if (subjectType == FlagType.post && post!.author.id == CurrentUser.currentUser!.id) {
//                           //   DeleteContent.deleteProfilePost(context, post.id);
//                           // }
//                         },
//                         icon: Icons.delete,
//                         text: 'Удалить'
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       );
  
//   }
// }

class WhoLikeButton extends StatelessWidget {
  const WhoLikeButton({super.key, required this.users});

  final List<UserInfoModel> users;

  final double avatarSize = 30;

  @override
  Widget build(BuildContext context) {
    var theme = PotokTheme.of(context);
    late String label;
    if (users.length >= 3) label = "Понравилось ${users.elementAt(0).name?.trim() ?? users.elementAt(0).nickname.trim()}, ${users.elementAt(1).name?.trim() ?? users.elementAt(1).nickname.trim()} и другим";
    if (users.length == 2) label = "Понравилось ${users.elementAt(0).name?.trim() ?? users.elementAt(0).nickname.trim()}, ${users.elementAt(1).name?.trim() ?? users.elementAt(1).nickname.trim()}";
    if (users.length == 1) label = "Понравилось ${users.elementAt(0).name?.trim() ?? users.elementAt(0).nickname.trim()}";
    // ignore: curly_braces_in_flow_control_structures
     return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.centerLeft,
          children: [
            if (users.length >= 3) Container(
              margin: const EdgeInsets.only(left: 30),
              child: CircleAvatarWithBorder(avatarUrl: users.elementAt(2).avatarUrl, size: avatarSize - 4),
            ),
            if (users.length >= 2) Container(
              margin: const EdgeInsets.only(left: 15),
              child: CircleAvatarWithBorder(avatarUrl: users.elementAt(1).avatarUrl, size: avatarSize - 2),
            ),
            CircleAvatarWithBorder(avatarUrl: users.elementAt(0).avatarUrl, size: avatarSize),
          ],
        ),
        const SizedBox(width: 10.0,),
        Expanded(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: TextStyle(
              color: theme.textColor.withOpacity(.5),
              fontWeight: FontWeight.w600
            ),
          ),
        )
      ],
    );
  }
}

class CircleAvatarWithBorder extends StatelessWidget {
  const CircleAvatarWithBorder({super.key, required this.avatarUrl, required this.size, this.borderWidth = 0.8});

  final String? avatarUrl;
  final double size;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    var theme = PotokTheme.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 2),
            blurRadius: 6.0,
          ),
        ],
        border: Border.all(color: const Color.fromARGB(255, 192, 192, 192), width: borderWidth),
      ),
      child: CircleAvatar(
        backgroundColor: theme.backgroundColor,
        child: ClipOval(
          child: (avatarUrl == null || avatarUrl == '')
          ? Image(
            height: size,
            width: size,
            image: const AssetImage('assets/images/noavatar.png'),
            fit: BoxFit.cover,
          )
          : CachedNetworkImage( 
            fadeInDuration: Duration.zero,
            height: size,
            width: size,
            imageUrl: avatarUrl!,
            fit: BoxFit.cover,
            errorWidget: (context, error, stackTrace) => const Icon(Icons.error)
          )
        ),
      ),
    );
  }
}