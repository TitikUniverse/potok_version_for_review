import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../navigation/parameters/post_parameters.dart';
import '../../navigation/routes.dart';
import '../../resources/resource_string.dart';
import '../../theme/potok_theme.dart';
import '../../theme/themes_impl/dark.dart';
import '../../theme/themes_impl/light.dart';
import '../authentication/screen/intro_screen.dart';
import '../authentication/screen/login_screen.dart';
import '../errors/error_screen.dart';
import '../errors/not_registered_user_screen.dart';
import '../friends/screen/friends_screen.dart';
import '../home/screen/home_screen.dart';
import '../potok_scaffold.dart';
import '../recommendation/screen/recommendation_screen.dart';
import '../registration/index.dart';
import '../user_profile/screen/user_profile_screen.dart';
import '../view_post/screen/view_post_screen.dart';

class App extends StatelessWidget {
  App({super.key});

  final ValueKey<String> _scaffoldKey = const ValueKey<String>('App scaffold');

  @override
  Widget build(BuildContext context) {
    return CupertinoApp.router(
      routerConfig: RouterConfig(
        routeInformationParser: _router.routeInformationParser,
        routeInformationProvider: _router.routeInformationProvider,
        routerDelegate: _router.routerDelegate,
      ),
      title: ResourceString.appName,
      debugShowCheckedModeBanner: false,
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      builder: (context, child) => kIsWeb ? PotokTheme(
        light: lightAppTheme,
        dark: darkAppTheme,
        child: child ?? ErrorWidget('Child needed!')
      ) : KeyboardDismiss(
            androidLoseFocus: true,
            child: PotokTheme(
              light: lightAppTheme,
              dark: darkAppTheme,
              child: child ?? ErrorWidget('Child needed!')
            ),
          )
    );
  }

  late final GoRouter _router = GoRouter(
    errorBuilder: (context, state) => ErrorScreen(title: ResourceString.everythingIsBad, description: state.error.toString()),
    // redirect: _guard,
    initialLocation: NavigationRoutesString.root,
    // refreshListenable: _auth,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: NavigationRoutesString.root,
        redirect: (context, state) => NavigationRoutesString.intro,
      ),
      GoRoute(
        path: NavigationRoutesString.intro,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const IntroScreen()
        ),
      ),
      // GoRoute(
      //   path: '/needUpdate',
      //   pageBuilder: (context, state) => MaterialPage(
      //     key: state.pageKey,
      //     child: const NeedUpdateScreen()
      //   ),
      // ),
      GoRoute(
        path: NavigationRoutesString.login,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const LoginScreen()
        ),
      ),
      GoRoute(
        path: NavigationRoutesString.registration,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const RegistrationScreenStepOne()
        ),
      ),
      // GoRoute(
      //   path: '/messenger',
      //   pageBuilder: (BuildContext context, GoRouterState state) {
      //     return MaterialPage(
      //       child: PotokScaffold(
      //         key: _scaffoldKey,
      //         selectedTab: ScaffoldTab.recommendation,
      //         child: CurrentUser.currentUser != null ? ChatListScreen(key: chatListScreenKey) : const NotRegisteredUserScreen(),
      //       )
      //     );
      //   },
      //   routes: [
      //     GoRoute(
      //       path: 'chat/:chatId', // Отправляй chatId = 0, если нужен новый пустой чат
      //       pageBuilder: (BuildContext context, GoRouterState state) {
      //         int chatId = int.parse(state.pathParameters['chatId'] as String);
      //         currentOpenedChatKey = GlobalKey();
      //         return MaterialPage(
      //           child: ChatScreen(key: currentOpenedChatKey, chatId: chatId)
      //         );
      //       }
      //     ),
      //   ]
      // ),
      GoRoute(
        path: NavigationRoutesString.recommendation,
        pageBuilder: (BuildContext context, GoRouterState state) => MaterialPage(
          child: PotokScaffold(
            key: _scaffoldKey,
            selectedTab: ScaffoldTab.recommendation,
            child: const RecomendationScreen(),
          ),
        ),
      ),
      GoRoute(
        path: NavigationRoutesString.home,
        pageBuilder: (BuildContext context, GoRouterState state) => MaterialPage(
          child: PotokScaffold(
            key: _scaffoldKey,
            selectedTab: ScaffoldTab.feed,
            child: const HomeScreen(),
          ),
        ),
      ),
      GoRoute(
        path: NavigationRoutesString.post,
        pageBuilder: (context, state) {
          var postParameters = state.extra as PostParameters;
          return MaterialPage(
            key: state.pageKey,
            child: ViewPostScreen(userMultimediaPost: postParameters.post, selectedImageIndex: postParameters.selectedImageIndex, showOnlyComment: false),
          );
        }
      ),
      // GoRoute(
      //   path: '/postList',
      //   pageBuilder: (context, state) {
      //     late int id;
      //     late PostType postType;
      //     int? index;

      //     if (state.queryParameters.containsKey('id')) id = int.parse(state.queryParameters['id'] as String);
      //     if (state.queryParameters.containsKey('postType')) postType = PostType.values.firstWhere((element) => element.name == state.queryParameters['postType'] as String);
      //     if (state.queryParameters.containsKey('index')) index = int.parse(state.queryParameters['index'] as String);

      //     late UserMultimediaPostModel _userMultimediaPost;
      //     if (postType == PostType.friendFeed) _userMultimediaPost = userPersonalFeed.firstWhere((element) => element.id == id);
      //     if (postType == PostType.potokFeed) _userMultimediaPost = userRecomendtaionFeed.firstWhere((element) => element.id == id);
      //     if (postType == PostType.profilePosts) {
      //       for (var item in accountMultimediaPosts.values) {
      //         final _post = item.firstWhereOrNull((element) => element.id == id);
      //         if (_post != null) {
      //           _userMultimediaPost = _post;
      //           break;
      //         }
      //       }
      //     }
      //     if (postType == PostType.savedPosts) _userMultimediaPost = savedPosts.firstWhere((element) => element.id == id);
      //     if (postType == PostType.archivePosts) _userMultimediaPost = archivedPosts.firstWhere((element) => element.id == id);
      //     if (postType == PostType.fromNotification) _userMultimediaPost = userPostFromNotification!;

      //     return MaterialPage(
      //       key: state.pageKey,
      //       child: ViewSharedPostScreen(post: _userMultimediaPost),
      //     );
      //   }
      // ),
      GoRoute(
        path: NavigationRoutesString.friend,
        pageBuilder: (BuildContext context, GoRouterState state) {
          int? pageIndex;
          if (state.uri.queryParameters.containsKey('pageIndex')) pageIndex = int.parse(state.uri.queryParameters['pageIndex'] as String);
          
          return MaterialPage(
            child: PotokScaffold(
              key: _scaffoldKey,
              selectedTab: ScaffoldTab.friend,
              child: FriendsScreen(initialPageIndex: pageIndex),
            ),
          );
        }
      ),
      // GoRoute(
      //   path: '/notification',
      //   pageBuilder: (BuildContext context, GoRouterState state) => MaterialPage(
      //     child: PotokScaffold(
      //       key: _scaffoldKey,
      //       selectedTab: ScaffoldTab.friend,
      //       child: const NotificationScreen(),
      //     ),
      //   ),
      // ),
      // // GoRoute(
      // //   path: '/camerasearch',
      // //   pageBuilder: (BuildContext context, GoRouterState state) => CupertinoPage(
      // //     child: PotokScaffold(
      // //       key: _scaffoldKey,
      // //       selectedTab: ScaffoldTab.feed,
      // //       child: SearchFriendUsingCamera(),
      // //     ),
      // //   ),
      // // ),
      // GoRoute(
      //   path: '/newpost',
      //   pageBuilder: (context, state) {
      //     if (!state.queryParameters.containsKey('fileView')) {
      //       return MaterialPage(
      //       key: state.pageKey,
      //       child: const ErrorScreen(title: 'Ошибка', description: 'fileView is required')
      //     );
      //     }

      //     S3FileView fileView = S3FileView.values.firstWhere((e) => e.toString() == state.queryParameters['fileView']);
      //     return MaterialPage(
      //       key: state.pageKey,
      //       child: PrepparingContentBeforeScreen(fileView: fileView)
      //     );
      //   }
      // ),
      // GoRoute(
      //   path: '/settings',
      //   pageBuilder: (context, state) => MaterialPage(
      //     key: state.pageKey,
      //     child: const SettingsScreen()
      //   ),
      // ),
      // GoRoute(
      //   path: '/accountmanagement',
      //   pageBuilder: (context, state) => MaterialPage(
      //     key: state.pageKey,
      //     child: const AccountManagementScreen()
      //   ),
      // ),
      // GoRoute(
      //   path: '/qrcode',
      //   pageBuilder: (context, state) => MaterialPage(
      //     key: state.pageKey,
      //     child: const QrCodeScreen()
      //   ),
      // ),
      // GoRoute(
      //   path: '/edituseraccount',
      //   pageBuilder: (context, state) => MaterialPage(
      //     key: state.pageKey,
      //     child: const EditUserAccountScreen()
      //   ),
      // ),
      // GoRoute(
      //   path: '/archive',
      //   pageBuilder: (context, state) => MaterialPage(
      //     key: state.pageKey,
      //     child: const ArchiveContentScreen()
      //   ),
      // ),
      // GoRoute(
      //   path: '/savedContent',
      //   pageBuilder: (context, state) => MaterialPage(
      //     key: state.pageKey,
      //     child: const SavedContentScreen()
      //   ),
      // ),
      // GoRoute(
      //   path: '/blacklist',
      //   pageBuilder: (context, state) => MaterialPage(
      //     key: state.pageKey,
      //     child: const BlackListScreen()
      //   ),
      // ),
      // GoRoute(
      //   path: '/appinfo',
      //   pageBuilder: (context, state) => MaterialPage(
      //     key: state.pageKey,
      //     child: const AppInfoScreen()
      //   ),
      // ),
      // GoRoute(
      //   path: '/subscribers',
      //   pageBuilder: (context, state) {
      //     String? nickname = state.queryParameters['user'];
      //     String pageIndex = state.queryParameters['pageIndex'] ?? '0';

      //     if (nickname == null) {
      //       return MaterialPage(
      //       key: state.pageKey,
      //       child: const ErrorScreen(title: 'Что-то сломалось', description: 'Nickname is required')
      //     );
      //     }

      //     UserInfoModel? user = MyApp.cacheLibrary.getProfileByNickname(nickname);

      //     if (user == null) {
      //       return MaterialPage(
      //         key: state.pageKey,
      //         child: const ErrorScreen(title: 'Ой...', description: 'У нас нет такого пользователя')
      //       );
      //     }

      //     return MaterialPage(
      //       key: state.pageKey,
      //       child: SubscriberListScreen(userId: user.id, accountNickname: nickname, pageIndex: int.parse(pageIndex))
      //     );
      //   }
      // ),
      // // GoRoute(
      // //   path: '/map',
      // //   pageBuilder: (BuildContext context, GoRouterState state) => CupertinoPage(
      // //     key: state.pageKey,
      // //     child: Platform.isIOS ? const MapboxScreen() : const MapboxScreen(),
      // //   ),
      // // ),
      GoRoute( // ! Этот роут должен быть всегда последним из всех роутов в этом списке. Это очень важно!
        path: '/:userNickname',
        name: 'userProfile',
        pageBuilder: (BuildContext context, GoRouterState state) {
          String userNickname = state.pathParameters['userNickname'] ?? 'null';
          return MaterialPage(
            child: PotokScaffold(
              key: _scaffoldKey,
              selectedTab: ScaffoldTab.profile,
              child: userNickname == 'null' ? const NotRegisteredUserScreen() : UserProfileScreen(userNickname: userNickname)
            ),
          );
        }
      )
    ]
  );
}