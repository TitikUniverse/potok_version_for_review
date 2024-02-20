import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/user/user_info_model.dart';
import '../../../theme/potok_theme.dart';

class FriendItem extends StatelessWidget {
  const FriendItem({Key? key, required this.userInfoModel, this.isMyFriend = false}) : super(key: key);

  final UserInfoModel userInfoModel;
  final bool isDeleted = false;

  final bool isMyFriend;

  @override
  Widget build(BuildContext context) {
    var theme = PotokTheme.of(context);

    return InkWell(
      // highlightColor: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      splashColor: theme.brandColor,
      onTap: () {
        GoRouter.of(context).push('/${userInfoModel.nickname}');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 15),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 15),
        decoration: BoxDecoration(
          color: theme.frontColor.withOpacity(.76),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, 0),
              blurRadius: 2.0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
                backgroundColor: theme.frontColor,
                radius: 29,
                // backgroundImage:  (!isDeleted) ? const AssetImage('assets/images/noavatar.png') : const AssetImage('assets/images/deletedAvatar.png'),
                foregroundImage:
                  (!isDeleted) ? (userInfoModel.avatarUrl != '' && userInfoModel.avatarUrl != null)
                    ? NetworkImage(userInfoModel.avatarUrl!) as ImageProvider
                    : const AssetImage('assets/images/noavatar.png')
                  : const AssetImage('assets/images/deletedAvatar.png')
            ),
            const SizedBox(
              width: 8,
            ),
            Flexible(
              flex: 10,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Flexible(
                        child: Text(
                          userInfoModel.nickname,
                          style: TextStyle(
                            color: theme.textColor,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w700
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (userInfoModel.isAuthorOfQualityContent == true) Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        child: CachedNetworkImage( 
                          fadeInDuration: Duration.zero,
                          height: 12,
                          width: 12,
                          imageUrl:'https://ratemeapp.hb.bizmrg.com/potokassets/static/usertypes/kometa.png',
                          fit: BoxFit.cover,
                        )
                      ),
                      if (userInfoModel.isVerifiedAccount == true) Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        child: CachedNetworkImage( 
                          fadeInDuration: Duration.zero,
                          height: 12,
                          width: 12,
                         imageUrl:'https://ratemeapp.hb.bizmrg.com/potokassets/static/usertypes/super.png',
                          fit: BoxFit.cover,
                        )
                      ),
                    ],
                  ),
                  if (userInfoModel.name != null && !isDeleted) const SizedBox(height: 1,),
                  if (userInfoModel.name != null && !isDeleted) Text(
                    userInfoModel.name!,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: theme.textColor.withOpacity(.5),
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400
                    ),
                  ),
                  if (isDeleted) const Text(
                    'Аккаунт удален',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            (userInfoModel.isFriend != null && userInfoModel.isFriend == true)
            ? Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: SvgPicture.asset('assets/icons/person-check-svgrepo-com.svg', color: isMyFriend ? Colors.greenAccent.withOpacity(.65) : theme.brandColor.withOpacity(.8)),
              )
            : const SizedBox()
            // Row(
            //   crossAxisAlignment: CrossAxisAlignment.center,
            //   children: [
            //     Text(
            //       userInfoModel.medalsAmount!.toString(),
            //       style: const TextStyle(
            //         color: Colors.white,
            //         fontSize: 16.0,
            //         fontWeight: FontWeight.bold,
            //       ),
            //     ),
            //     SvgPicture.asset('assets/icons/normal/medal_icon.svg', width: 30, height: 30, color: Colors.white,),
            //   ],
            // ),
            // Spacer(),
            // IconButton(
            //   splashRadius: 22,
            //   onPressed: () {},
            //   icon: Icon(
            //     Icons.star_rate_rounded,
            //     color: isBest
            //         ? currentAppTheme.primary
            //         : currentAppTheme.primaryColorDark,
            //     size: 25,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}