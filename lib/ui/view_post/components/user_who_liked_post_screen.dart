
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide GetDynamicUtils;

import '../../../data/models/user_content/user_multimedia_post_model.dart';
import '../../../utils/color_print.dart';
import '../../friends/components/friend_item.dart';
import '../state/post_controller.dart';

class UserWhoLikedPostScreen extends StatefulWidget {
  const UserWhoLikedPostScreen({super.key, required this.post});

  final UserMultimediaPostModel post;

  @override
  State<UserWhoLikedPostScreen> createState() => _UserWhoLikedPostScreenState();
}

class _UserWhoLikedPostScreenState extends State<UserWhoLikedPostScreen> {
  final ScrollController _scrollController = ScrollController();
  late final PostController _postController;

  bool isLoading = false;
  bool isNeedLoadMore = true;
  
  bool _topFlag = false;
  final double _screenUpScrollDepth = -50.0;

  Future<void> _fetchUsers() async {
    isLoading = true;
    isNeedLoadMore = await _postController.tryFetchUsersWhoLike(postId: widget.post.id);
    isLoading = false;
  }

  @override
  void initState() {
    _postController = Get.find<PostController>(tag: widget.post.id.toString());
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels <= _screenUpScrollDepth && _topFlag == false) {
            _topFlag = true;
            printInfo("reach the top", name: '$UserWhoLikedPostScreen');
            Navigator.pop(context);
            return true;
          }
          
          var nextPageTrigger = 0.8 * notification.metrics.maxScrollExtent;
          if (notification.metrics.pixels > nextPageTrigger) {
            if (isNeedLoadMore && !isLoading) {
              _fetchUsers();
              return true;
            }
            return true;
          }
          return true;
        },
        child: GetBuilder<PostController>(
          tag: widget.post.id.toString(),
          builder: (controller) {
            return ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.only(bottom: 20),
              itemCount: isLoading ? controller.usersWhoLike!.length + 1 : controller.usersWhoLike!.length,
              itemBuilder: (context, index) {
                if (isLoading && index == controller.usersWhoLike!.length) return const CircularProgressIndicator.adaptive();
                return FriendItem(userInfoModel: controller.usersWhoLike![index]);
              },
            );
          }
        ),
      ),
    );
  }
}