import 'dart:io';
import 'dart:ui';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shimmer/shimmer.dart';

import '../../../data/data_sources/authentication/local/authentication_local_data_source.dart';
import '../../../data/models/user/user_info_model.dart';
import '../../../data/repositories/friend/repository/friend_status.dart';
import '../../../resources/resource_string.dart';
import '../../../theme/potok_theme.dart';
import '../../base/base_screen_mixin.dart';
import '../../widgets/blur_image_background.dart';
import '../../widgets/shackbar/snackbar.dart';
import '../components/square_post_preview.dart';
import '../state/new_post_controller.dart';
import '../state/user_content_controller.dart';
import '../state/user_profile_controller.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key, required this.userNickname});

  final String userNickname;

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> with BaseScreenMixin {
  late final ScrollController _scrollController;
  late final UserContentController _userContentController;
  late final UserProfileController _userProfileController;
  final AuthenticationLocalDataSource _authenticationLocalDataSource = AuthenticationLocalDataSource();

  final double avatarSize = 77;

  bool _isInitValueAccountInfo = true;

  UserInfoModel? userInfo;

  @override
  void initState() {
    _scrollController = ScrollController();
    _userContentController = Get.put(UserContentController(), tag: widget.userNickname);
    _userProfileController = Get.put(UserProfileController(), tag: widget.userNickname);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      userInfo = await _userProfileController.fetchUserProfileData(widget.userNickname);
      if (userInfo != null) await _userContentController.fetchUserPosts(authorId: userInfo!.id);
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    Get.delete<UserContentController>(tag: widget.userNickname);
    Get.delete<UserProfileController>(tag: widget.userNickname);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = PotokTheme.of(context);
    var mq = MediaQuery.of(context);
    return Scaffold(
      body: Stack(
        children: [
          currentAppTheme(context) == ThemeMode.dark
            ? const BlurImageBackground(imagePath: 'assets/images/ios_default_wallpaper.png')
            : const BlurImageBackground(imagePath: 'assets/images/ios_default_wallpaper_light.png', opacity: 0.87),
          ExtendedNestedScrollView(
            controller: _scrollController,
            // [pinned sliver header issue](https://github.com/flutter/flutter/issues/22393)
            pinnedHeaderSliverHeightBuilder: () {
              return 0;//mq.padding.top + kToolbarHeight;
            },
            // [inner scrollables in tabview sync issue](https://github.com/flutter/flutter/issues/21868)
            onlyOneScrollInBody: true,
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverToBoxAdapter(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ? Шапка
                    Container(
                      width: mq.size.width,
                      clipBehavior: Clip.none,
                      decoration: BoxDecoration(
                        color: theme.frontColor,
                        borderRadius: const BorderRadius.vertical(bottom: Radius.elliptical(25, 16)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            alignment: AlignmentDirectional.topCenter,
                            children: [
                              // ? Содержимое шапки внутреннее
                              Container(
                                // padding: EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top),
                                height: (widget.userNickname == _authenticationLocalDataSource.currentUser?.nickname ? 110 : 125) + MediaQuery.of(context).viewPadding.top,
                                // height: ((_hasBioInfo() == true && (userInfo!.linkInBio != '' || userInfo!.description != '')) ? 210 : 180) + size.width * 0.31 - ((userInfo!.name == null || userInfo!.name == '') ? 25: 0),
                                width: mq.size.width,
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.vertical(bottom: Radius.elliptical(25, 16)),
                                ),
                                clipBehavior: Clip.hardEdge,
                                child: Stack(
                                  fit: StackFit.expand,
                                  alignment: Alignment.center,
                                  children: [
                                    // ? Фоновая картинка
                                    Container(
                                      // height: 250 + MediaQuery.of(context).viewPadding.top,
                                      width: MediaQuery.of(context).size.width,
                                      clipBehavior: Clip.hardEdge,
                                      decoration: const BoxDecoration(),
                                      child: ImageFiltered(
                                        imageFilter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                                        child: GetBuilder<UserProfileController>(
                                          tag: widget.userNickname,
                                          builder: (controller) {
                                            if (controller.userInfo?.avatarUrl != null && controller.userInfo?.avatarUrl != '') {
                                              return CachedNetworkImage(imageUrl: controller.userInfo!.avatarUrl!, fit: BoxFit.cover);
                                            }
                                            return Image.asset('assets/images/noavatar.png', fit: BoxFit.cover);
                                          },
                                        )
                                      ) 
                                    ),
                              
                                    // ? Градиент
                                    GetBuilder<UserProfileController>(
                                      tag: widget.userNickname,
                                      builder: (controller) {
                                        if (controller.userInfo == null) return const SizedBox.shrink();
                                        return Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topRight,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                (controller.userInfo!.isVerifiedAccount! ? theme.extraordinaryColors.verifiedColor : (controller.userInfo!.isAuthorOfQualityContent!) ? theme.extraordinaryColors.potokSignColor : theme.extraordinaryColors.usualThingColor).withOpacity(0.1), 
                                                (controller.userInfo!.isVerifiedAccount! ? theme.extraordinaryColors.verifiedColor : (controller.userInfo!.isAuthorOfQualityContent!) ? theme.extraordinaryColors.potokSignColor : theme.extraordinaryColors.usualThingColor).withOpacity(0.08), 
                                                (controller.userInfo!.isVerifiedAccount! ? theme.extraordinaryColors.verifiedColor : (controller.userInfo!.isAuthorOfQualityContent!) ? theme.extraordinaryColors.potokSignColor : theme.extraordinaryColors.usualThingColor).withOpacity(0.2)],
                                              // colors: [(userInfo!.isVerifiedAccount! ? Constant.superAccentColor : (userInfo!.isAuthorOfQualityContent!) ? Constant.kometaAccentColor : Constant.newAccentColor).withOpacity(0.3), (userInfo!.isVerifiedAccount! ? Constant.superAccentColor : (userInfo!.isAuthorOfQualityContent!) ? Constant.kometaAccentColor : Constant.newAccentColor).withOpacity(0.2), (userInfo!.isVerifiedAccount! ? Constant.superAccentColor : (userInfo!.isAuthorOfQualityContent!) ? Constant.kometaAccentColor : Constant.newAccentColor).withOpacity(0.6)],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                              
                                    // ? Всё что на переде шапки
                                    SafeArea(
                                      child: Padding(
                                        padding: const Pad(horizontal: 10),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              children: [
                                                if (widget.userNickname != _authenticationLocalDataSource.currentUser?.nickname) Material(
                                                  color: Colors.transparent,
                                                  child: InkWell(
                                                    borderRadius: BorderRadius.circular(30.0),
                                                    highlightColor: Colors.white54,
                                                    onTap: () {
                                                      GoRouter.of(context).pop();
                                                    },
                                                    child: Container(
                                                      padding: const Pad(all: 10),
                                                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
                                                    ),
                                                  ),
                                                ),

                                                // ? Аватарка
                                                Container(
                                                  width: avatarSize,
                                                  height: avatarSize,
                                                  margin: const Pad(horizontal: 15),
                                                  decoration: const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black12,
                                                        offset: Offset(0, 2),
                                                        blurRadius: 6.0,
                                                      ),
                                                    ],
                                                  ),
                                                  child: CircleAvatar(
                                                    backgroundColor: theme.backgroundColor,
                                                    child: GetBuilder<UserProfileController>(
                                                      tag: widget.userNickname,
                                                      builder: (controller) {
                                                        if (controller.userInfo == null) {
                                                          return ClipOval(
                                                            child: Shimmer.fromColors(
                                                              baseColor: theme.backgroundColor,
                                                              highlightColor: theme.frontColor,
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                  color: theme.frontColor.withOpacity(.5),
                                                                  borderRadius: BorderRadius.circular(5)
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                        if (controller.userInfo?.avatarUrl == null || controller.userInfo?.avatarUrl == '') {
                                                          return ClipOval(
                                                            child: Image(
                                                              height: avatarSize,
                                                              width: avatarSize,
                                                              image: const AssetImage('assets/images/noavatar.png'),
                                                              fit: BoxFit.cover,
                                                            ),
                                                          );
                                                        }
                                                        return ClipOval(
                                                          child: CachedNetworkImage( 
                                                            fadeInDuration: Duration.zero,
                                                            height: avatarSize,
                                                            width: avatarSize,
                                                            imageUrl: controller.userInfo!.avatarUrl!,
                                                            fit: BoxFit.cover,
                                                            errorWidget: (context, error, stackTrace) => const Icon(Icons.error)
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  )
                                                ),
                                        
                                                // ? Nickname & метки галочки и потока
                                                GetBuilder<UserProfileController>(
                                                  tag: widget.userNickname,
                                                  builder: (controller) {
                                                    if (controller.userInfo == null) {
                                                      return Shimmer.fromColors(
                                                        baseColor: theme.backgroundColor,
                                                        highlightColor: theme.frontColor,
                                                        child: Container(
                                                          width: mq.size.width * 0.35,
                                                          height: 30,
                                                          decoration: BoxDecoration(
                                                            color: theme.frontColor.withOpacity(.5),
                                                            borderRadius: BorderRadius.circular(5)
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                    return Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            Text(
                                                              controller.userInfo!.nickname,
                                                              style: const TextStyle(
                                                                fontWeight: FontWeight.w600,
                                                                fontSize: 20,
                                                                color: Colors.white
                                                              ),
                                                            ),
                                                            if (controller.userInfo!.isAuthorOfQualityContent == true) Tooltip(
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
                                                                  height: 20,
                                                                  width: 20,
                                                                  imageUrl: 'https://ratemeapp.hb.bizmrg.com/potokassets/static/usertypes/kometa.png',
                                                                  fit: BoxFit.cover,
                                                                )
                                                              ),
                                                            ),
                                                            if (controller.userInfo!.isVerifiedAccount == true) Tooltip(
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
                                                                  height: 20,
                                                                  width: 20,
                                                                  imageUrl:'https://ratemeapp.hb.bizmrg.com/potokassets/static/usertypes/super.png',
                                                                  fit: BoxFit.cover,
                                                                )
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        if (controller.userInfo!.name != null && controller.userInfo!.name != '') Text(
                                                          controller.userInfo!.name!,
                                                          style: const TextStyle(
                                                            fontWeight: FontWeight.w600,
                                                            fontSize: 16,
                                                            color: Color.fromARGB(255, 237, 237, 237)
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                ),
                                        
                                                const Spacer(),
                                                
                                                if (widget.userNickname != _authenticationLocalDataSource.currentUser?.nickname) Container(
                                                  height: 22,
                                                  width: 22,
                                                  margin: const Pad(all: 10),
                                                  child: PopupMenuButton<int>(
                                                    padding: const EdgeInsets.all(0),
                                                    offset: const Offset(0,0),
                                                    iconSize: 22,
                                                    icon: const Icon(Icons.more_vert_rounded, color: Colors.white,),
                                                    color: theme.frontColor,
                                                    itemBuilder: (context) => [
                                                      PopupMenuItem(
                                                        value: 1,
                                                        child: Text("Пожаловаться",style: TextStyle(color: theme.textColor, fontSize: 14.0),),
                                                      ),
                                                      PopupMenuItem(
                                                        value: 0,
                                                        child: GetBuilder<UserProfileController>(
                                                          tag: widget.userNickname,
                                                          builder: (controller) => Text(
                                                            controller.userBlockCheck.isUserBlocked ? "Разблокировать" : "Заблокировать",
                                                            style: TextStyle(color: theme.textColor, fontSize: 14.0)
                                                          )
                                                        ),
                                                      ),
                                                    ],
                                                    onSelected: (item) {
                                                      // TODO: implement this
                                                      // _showActionsMenu(item, widget.userInfo.nickname);
                                                    }
                                                  ),
                                                )
                                                else  Material(
                                                  color: Colors.transparent,
                                                  child: InkWell(
                                                    borderRadius: BorderRadius.circular(30.0),
                                                    highlightColor: Colors.white54,
                                                    onTap:() {
                                                      // TODO: implement this
                                                      // showProfileSettings();
                                                    },
                                                    child: Container(
                                                      padding: const Pad(all: 10),
                                                      child: const Icon(Icons.settings_rounded, color: Colors.white, size: 22),
                                                    ),
                                                  )
                                                )
                                              ]
                                            ),

                                            GetBuilder<UserProfileController>(
                                              tag: widget.userNickname,
                                              builder: (controller) {
                                                if (controller.userBlockCheck.isUserBlocked == false) return const SizedBox.shrink();
                                                return const Text('В вашем черном списке', style: TextStyle(color: Colors.white, fontSize: 16.0));
                                              },
                                            ),
                                            
                                            // ? Отступ
                                            SizedBox(height: widget.userNickname == _authenticationLocalDataSource.currentUser?.nickname ? 0 : 16), // Чтобы на кнопки действий не залезало
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      
                              // ? Кнопки внизу шапки
                              if (widget.userNickname != _authenticationLocalDataSource.currentUser?.nickname) Positioned(
                                bottom: -28, width: mq.size.width, 
                                child: OtherUserActions(
                                  userNickname: widget.userNickname,
                                  // friendStatus: _friendStatus,
                                  // userInfo: widget.userInfo,
                                  // onTabFriendStatusButton: () async {
                                  //   if (widget.userInfo.id != CurrentUser.currentUser!.id) await _checkFriendStatus();
                                  //   await _fetchSubscriberAmount();
                                  // },
                                )
                              )
                            ],
                          ),
            
                          // ? Низ шапки, где описание и ссылка
                          GetBuilder<UserProfileController>(
                            tag: widget.userNickname,
                            builder: (controller) {
                              if (controller.userInfo == null) {
                                return const SizedBox.shrink();
                              }
                              if (controller.userInfo!.hasBioInfo == false && controller.userInfo!.hasLinkInBio == false) {
                                return const SizedBox.shrink(); 
                              }
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isInitValueAccountInfo = !_isInitValueAccountInfo;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(height: widget.userNickname == _authenticationLocalDataSource.currentUser?.nickname ? 0 : 16), // Чтобы на кнопки действий не залезало
                                      if (controller.userInfo!.description != null && controller.userInfo!.description != '') AnimatedCrossFade(
                                        crossFadeState: _isInitValueAccountInfo
                                            ? CrossFadeState.showFirst
                                            : CrossFadeState.showSecond,
                                        duration: const Duration(milliseconds: 200),
                                        firstChild: Text(
                                          controller.userInfo!.description!,
                                          maxLines: 3,
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.fade,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: theme.textColor
                                          ),
                                        ),
                                        secondChild: Text(
                                          controller.userInfo!.description!,
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.fade,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: theme.textColor
                                          ),
                                        ),
                                      ),
                
                                      const SizedBox(height: 5),
                
                                      if (controller.userInfo?.hasLinkInBio == false) const SizedBox.shrink()
                                      else InkWell(
                                        onTap: () {
                                          late String url;
                                        if (controller.userInfo!.linkInBio!.trim().startsWith('https://') || controller.userInfo!.linkInBio!.trim().startsWith('http://')) {
                                            url = controller.userInfo!.linkInBio!.trim();
                                          } else {
                                            url = 'https://${controller.userInfo!.linkInBio!.trim()}';
                                          }
                                          try {
                                            launchURL(url);
                                          } catch (e) {
                                            PotokSnackbar.failure(context, title: ResourceString.error, message: ResourceString.errorOpenUrl);
                                          }
                                        },
                                        child: Text(
                                          controller.userInfo!.linkInBio!,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: theme.brandColor,
                                            fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ),
                              );
                            },
                          )
                        ],
                      ),
                    ),
                
                    // ? Кнопки новый пост / видео
                    GetBuilder<UserProfileController>(
                      tag: widget.userNickname,
                      builder: (controller) {
                        return Container(
                          padding: EdgeInsets.only(
                            top: controller.userInfo?.hasBioInfo == true //&& (widget.userInfo.linkInBio != '' || widget.userInfo.description != '') 
                              ? 12
                              : widget.userNickname == _authenticationLocalDataSource.currentUser?.nickname ? 12 : 30
                            // bottom: _hasBioInfo() == true && (userInfo!.linkInBio != '' || userInfo!.description != '') ? 6.0 : 0
                          ),
                          margin: Pad(horizontal: mq.size.width * 0.05, bottom: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ? Блок со статистикой профиля
                              SizedBox(
                                height: 45,
                                child: Row(
                                  children: [
                                    // ? Подписчиков
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: theme.frontColor,
                                          borderRadius: BorderRadius.circular(15.0),
                                        ),
                                        child: TextButton(
                                          onPressed: () async {
                                            if (widget.userNickname != _authenticationLocalDataSource.currentUser?.nickname) {
                                              // TODO: implement this GoRouter
                                              // GoRouter.of(context).push('/subscribers?user=${widget.userInfo.nickname}&pageIndex=0');
                                            }
                                            else {
                                              // TODO: implement this GoRouter
                                              // GoRouter.of(context).push('/friend?pageIndex=0');
                                            }
                                          },
                                          child: Obx(
                                            () => Text(
                                              'Подписчиков ${controller.subscriberAmount.value}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: theme.textColor
                                              ),
                                            )
                                          )
                                        ),
                                      ),
                                    ),
              
                                    const SizedBox(width: 10),
              
                                    // ? Подписок
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: theme.frontColor,
                                          borderRadius: BorderRadius.circular(15.0),
                                        ),
                                        child: TextButton(
                                          onPressed: () async {
                                            if (widget.userNickname != _authenticationLocalDataSource.currentUser?.nickname) {
                                              // TODO: implement this GoRouter
                                              // GoRouter.of(context).push('/subscribers?user=${widget.userInfo.nickname}&pageIndex=1');
                                            }
                                            else {
                                              // TODO: implement this GoRouter
                                              // GoRouter.of(context).push('/friend?pageIndex=1');
                                            }
                                          },
                                          child: Obx(
                                            () => Text(
                                              'Подписок ${controller.subscriptionAmount.value}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: theme.textColor
                                              ),
                                            )
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
              
                              const SizedBox(height: 8),
              
                              // ? Блок "Новый пост"
                              if (widget.userNickname == _authenticationLocalDataSource.currentUser?.nickname) GetBuilder<NewPostController>(
                                builder: (newPostController) {
                                  return Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (newPostController.isVoiceMessageRecording == false) Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // ? Прикреплённые к посту файлы
                                            AnimatedContainer(
                                              duration: const Duration(milliseconds: 100),
                                              constraints: BoxConstraints(
                                                maxHeight: newPostController.attachedFilesToPost.isNotEmpty ? 120 : 0,
                                              ),
                                              child: Container(
                                                margin: const EdgeInsets.symmetric(vertical: 8.0),
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                                                clipBehavior: Clip.hardEdge,
                                                decoration: BoxDecoration(
                                                  color: theme.frontColor,
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: ListView.separated(
                                                  shrinkWrap: true,
                                                  padding: EdgeInsets.zero,
                                                  scrollDirection: Axis.horizontal,
                                                  itemCount: newPostController.attachedFilesToPost.length,
                                                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                                                  itemBuilder: (context, index) => Container(
                                                    width: 90,
                                                    height: 90,
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    clipBehavior: Clip.hardEdge,
                                                    child: Stack(
                                                      fit: StackFit.expand,
                                                      children: [
                                                        if (newPostController.attachedFilesToPost.keys.toList()[index].type == AssetType.image) Image.memory(newPostController.attachedFilesToPost.values.toList()[index], fit: BoxFit.cover),
                                                        if (newPostController.attachedFilesToPost.keys.toList()[index].type == AssetType.video) Image.memory(newPostController.attachedFilesToPost.values.toList()[index], fit: BoxFit.cover),
                                                        if (newPostController.attachedFilesToPost.keys.toList()[index].type == AssetType.video) const Icon(Icons.play_arrow_rounded, size: 40, color: Colors.white60),
                                                        Align(
                                                          alignment: Alignment.topRight,
                                                          child: GestureDetector(
                                                            onTap: () => newPostController.removeFileFromAttachedToPost(index),
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                color: theme.frontColor,
                                                                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(5))
                                                              ),
                                                              child: const Icon(Icons.close_rounded)
                                                            ),
                                                          )
                                                        )
                                                      ],
                                                    )
                                                  )
                                                ),
                                              ),
                                            ),
                                            
                                            // ? Поле для ввода текста нового поста
                                            TextField(
                                              controller: newPostController.textController,
                                              onChanged: (value) {
                                                if (value.isEmpty) {
                                                  if (newPostController.isSendPostButtonShow != false) {
                                                    newPostController.isSendPostButtonShow = false;
                                                  }
                                                } else {
                                                  if (newPostController.isSendPostButtonShow != true) {
                                                    newPostController.isSendPostButtonShow = true;
                                                  }
                                                }
                                              },
                                              textCapitalization: TextCapitalization.sentences,
                                              keyboardType: TextInputType.multiline,
                                              maxLines: 10,
                                              minLines: 1,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: theme.textColor
                                              ),
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor: theme.frontColor,
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(15.0),
                                                  borderSide: BorderSide.none
                                                ),
                                                hintText: 'Начните писать здесь...',
                                                hintStyle: TextStyle(color: theme.textColor.withOpacity(.4)),
                                                prefixIcon: IconButton(
                                                  onPressed: () => newPostController.pickContent(context),
                                                  icon: const Icon(Icons.attach_file_outlined),
                                                ),
                                                prefixIconColor: theme.brandColor,
                                              ),
                                            ),
                                          ],
                                        )
                                      ),
                                      const SizedBox(width: 10),
                                      GestureDetector(
                                        onTap: () => newPostController.uploadPost(context),
                                        child: Container(
                                          height: 50,
                                          width: 50, //_isMessageRecording ? MediaQuery.of(context).size.width / 1.2 : 50,
                                          decoration: BoxDecoration(
                                            color: theme.frontColor,
                                            borderRadius: BorderRadius.circular(15.0),
                                          ),
                                          child: newPostController.isSendPostButtonLoading 
                                          ? const CircularProgressIndicator.adaptive()
                                          : newPostController.textController.text.isNotEmpty || newPostController.attachedFilesToPost.isNotEmpty
                                            ? (Platform.isIOS) ? Padding(padding: const Pad(all: 14), child: SvgPicture.asset('assets/icons/normal/Share.svg', color: theme.brandColor)) : Icon(Icons.send_rounded, color: theme.brandColor)
                                            : Box(
                                              width: 40, //_isMessageRecording ? MediaQuery.of(context).size.width / 1.4 : 40,
                                              height: 50,
                                              child: Icon(CupertinoIcons.mic_circle, color: theme.brandColor, size: 26),
                                              // TODO: replace Icon() to SocialMediaRecorder()
                                              // child: SocialMediaRecorder(
                                              //   cancelText: 'Отменить',
                                              //   slideToCancelText: 'Отменить >',
                                              //   backGroundColor: Colors.transparent,
                                              //   counterBackGroundColor: theme.frontColor,
                                              //   counterTextStyle: TextStyle(color: theme.textColor, fontSize: 14),
                                              //   slideToCancelTextStyle: TextStyle(color: theme.textColor, fontSize: 14),
                                              //   cancelTextStyle: TextStyle(color: theme.textColor, fontSize: 14),
                                              //   recordIcon: Icon(CupertinoIcons.mic_circle, color: theme.brandColor, size: 26),
                                              //   recordIconBackGroundColor: theme.brandColor.withOpacity(.4),
                                              //   recordIconWhenLockBackGroundColor: theme.brandColor.withOpacity(.4),
                                              //   sendButtonIcon: (Platform.isIOS) ? Padding(
                                              //     padding: const EdgeInsets.all(12.0),
                                              //     child: SvgPicture.asset(
                                              //       'assets/icons/normal/Share.svg',
                                              //       width: 20,
                                              //       height: 20,
                                              //       color: Colors.white
                                              //     ),
                                              //   ) : const Icon(Icons.send_rounded, color: Colors.white),
                                              //   sendRequestFunction: (soundFile, soundDuration) async {
                                              //     setState(() {
                                              //       _isMessageRecording = false;
                                              //     });
                                              //     return;
                                              //     if (soundFile != null) {
                                              //       _sendVoiceMessage(soundFile, soundDuration);
                                              //     }
                                              //   },
                                              //   onStartRecord: () {
                                              //     setState(() {
                                              //       _isMessageRecording = true;
                                              //     });
                                              //   },
                                              // ),
                                            )
                                        ),
                                      )
                                    ],
                                  );
                                }
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                )
              )
            
            ],
            body: GetBuilder<UserContentController>(
              tag: widget.userNickname,
              builder: (controller) {
                if (controller.posts == null) {
                  return const Center(child: CircularProgressIndicator.adaptive());
                }
                if (controller.posts!.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        '${widget.userNickname} пока что не опубликовал(-а) ни одного поста.\nЖдём...',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: theme.textColor)
                      ),
                    )
                  );
                }
                return NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (controller.isNextPageLoading == false && controller.isNeedLoadMore == true && notification.metrics.pixels + 1000 > notification.metrics.maxScrollExtent) {
                      controller.fetchNextPage(authorId: userInfo!.id);
                      return true;
                    }
                    return true;
                  },
                  child: GridView.builder(
                    padding: Pad.zero,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 8 / 9,
                      mainAxisSpacing: 2,
                      crossAxisSpacing: 2
                    ),
                    itemCount: controller.posts!.length,
                    itemBuilder: (context, index) => SquarePostPreview(index: index, userInfo: userInfo!, userMultimediaPost: controller.posts![index]),
                  ),
                  // child: ListView.separated(
                  //   padding: EdgeInsets.zero,
                  //   itemCount: userContentController.userPosts!.length,
                  //   separatorBuilder: (context, index) => const SizedBox(height: 10),
                  //   itemBuilder: (context, index) {
                  //     if (index + 5 == userContentController.userPosts?.length) {
                  //       userContentController.fetchUserPosts(authorId: userInfo!.id);
                  //     }
          
                  //     return ProfilePostItem(post: userContentController.userPosts![index], postType: PostType.profilePosts);
                  //   }
                  // );
                );
              },
            )
          ),
        ],
      ),
    );
  }
}

/// Кнопки действий с профилем, которые показываются на всех профилях, кроме профиля текущего юзера
class OtherUserActions extends StatelessWidget {
  OtherUserActions({super.key, required this.userNickname});

  final String userNickname;

  final AuthenticationLocalDataSource _authenticationLocalDataSource = 
      AuthenticationLocalDataSource();
  
  String get _friendButtonName {
    var friendStatus = Get.find<UserProfileController>(tag: userNickname).friendStatus;
    if (_authenticationLocalDataSource.currentUser == null) {
      return ResourceString.subscribe;
    } else if (friendStatus.value == FriendStatus.notFriend) {
      return ResourceString.subscribe;
    } else if (friendStatus.value == FriendStatus.subscriber) {
      return ResourceString.unsubscribe;
    } else if (friendStatus.value == FriendStatus.friend) {
      return ResourceString.removeFromFriends;
    } else if (friendStatus.value == FriendStatus.notFriend) {
      return ResourceString.acceptAsFriends;
    }

    return FriendStatus.unknown.name;
  }

  @override
  Widget build(BuildContext context) {
    var theme = PotokTheme.of(context);
    var mq = MediaQuery.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {},
            child: Container(
              width: mq.size.width * 0.405,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  width: 1,
                  color: theme.brandColor
                ),
                color: theme.brandColor,
              ),
              child: Obx(
                () => Text(
                  _friendButtonName,
                  style: const TextStyle(
                    overflow: TextOverflow.ellipsis,
                    color: Colors.white
                  ),
                )
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {},
            child: Container(
              width: mq.size.width * 0.405,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  width: 1,
                  color: theme.brandColor
                ),
                color: theme.brandColor,
              ),
              child: Text(
                ResourceString.toWrite,
                style: const TextStyle(
                  overflow: TextOverflow.ellipsis,
                  color: Colors.white
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}