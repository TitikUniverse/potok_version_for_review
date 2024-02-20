import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../data/models/user/user_info_model.dart';
import '../../../data/repositories/user_content/repository/post_type.dart';
import '../components/profile_post_item.dart';
import '../state/user_content_controller.dart';

class ListViewProfilePostViewScreen extends StatelessWidget {
  ListViewProfilePostViewScreen({super.key, required this.index, required this.userInfo});

  final int index;
  final UserInfoModel? userInfo;

  final ItemScrollController _scrollController = ItemScrollController();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _scrollController.jumpTo(index: index, alignment: 0.1);
    });
    
    return DismissiblePage(
      onDismissed: () {
        Navigator.of(context).pop();
      },
      // Note that scrollable widget inside DismissiblePage might limit the functionality
      // If scroll direction matches DismissiblePage direction
      direction: DismissiblePageDismissDirection.multi,
      isFullScreen: true,
      child: GetBuilder<UserContentController>(
        tag: userInfo?.nickname,
        builder: (controller) {
          return NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (controller.isNextPageLoading == false && controller.isNeedLoadMore == true && notification.metrics.pixels + 1000 > notification.metrics.maxScrollExtent) {
                controller.fetchNextPage(authorId: userInfo!.id);
                return false;
              }
              return false;
            },
            child: Builder(
              builder: (context) {
                if (controller.posts == null) {
                  return const CircularProgressIndicator.adaptive();
                }
                return ScrollablePositionedList.separated(
                  itemScrollController: _scrollController,
                  padding: Pad(vertical: MediaQuery.of(context).padding.vertical),
                  itemCount: controller.posts!.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    return ProfilePostItem(post: controller.posts![index], postType: PostType.profilePosts);
                  }
                );
              },
            )
          );
        }
      ),
    );
  }
}