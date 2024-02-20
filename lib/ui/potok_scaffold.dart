import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:potok/resources/resource_string.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import '../data/data_sources/authentication/index.dart';
import '../navigation/routes.dart';
import '../theme/potok_theme.dart';
import 'widgets/potok_custom_icons/potok_custom_icons_icons.dart';

/// The enum for scaffold tab.
enum ScaffoldTab {
  /// The feed tab.
  feed,

  /// The messsenger tab.
  recommendation,

  /// The friend tab.
  friend,

  /// The profile tab.
  profile
}

class PotokScaffold extends StatefulWidget {
  /// Creates a [PotokScaffold].
  const PotokScaffold({super.key, required this.selectedTab, required this.child});

  /// Which tab of the scaffold to display.
  final ScaffoldTab selectedTab;

  /// The scaffold body.
  final Widget child;

  @override
  State<PotokScaffold> createState() => PotokScaffoldState();
}

class PotokScaffoldState extends State<PotokScaffold> {
  @override
  Widget build(BuildContext context) {    
    var theme = PotokTheme.of(context);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: SalomonBottomBar(
        backgroundColor: theme.frontColor,
        currentIndex: widget.selectedTab.index,
        onTap: (idx) {
          final String location = GoRouterState.of(context).uri.toString();
          switch (ScaffoldTab.values[idx]) {
            case ScaffoldTab.feed:
              if (location != NavigationRoutesString.home) {
                context.go(NavigationRoutesString.home);
              }
              break;
            case ScaffoldTab.recommendation:
              if (location != NavigationRoutesString.recommendation) {
                context.go(NavigationRoutesString.recommendation);
              }
              break;
            case ScaffoldTab.friend:
              if (location != NavigationRoutesString.friend) {
                context.go(NavigationRoutesString.friend);
              }
              break;
            case ScaffoldTab.profile:
              var currentUser = AuthenticationLocalDataSource().currentUser;
              String userNickname = currentUser != null ? currentUser.nickname : 'null';
              if (location != '/$userNickname') {
                context.go('/$userNickname');
              }
              break;
          }
        },
        items: [
          SalomonBottomBarItem(
            icon: const Icon(PotokCustomIcons.home_icon_middle_rounded),
            title: Text(ResourceString.mainTab),
            selectedColor: theme.textColor,
            unselectedColor: theme.textColor.withOpacity(0.5)
          ),
          SalomonBottomBarItem(
            icon: const Icon(PotokCustomIcons.database_script_icon),
            title: Text(ResourceString.recommendationTab),
            selectedColor: theme.textColor,
            unselectedColor: theme.textColor.withOpacity(0.5)
          ),
          SalomonBottomBarItem(
            icon: const Icon(PotokCustomIcons.group_icon),
            title: Text(ResourceString.friendsTab),
            selectedColor: theme.textColor,
            unselectedColor: theme.textColor.withOpacity(0.5)
          ),
          SalomonBottomBarItem(
            icon: const Icon(PotokCustomIcons.circled_profile_icon_bold),
            title: Text(ResourceString.profileTab),
            selectedColor: theme.textColor,
            unselectedColor: theme.textColor.withOpacity(0.5)
          ),
        ],
      ),
    );
  }
}