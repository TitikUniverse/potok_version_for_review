import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gif/gif.dart';
import 'package:potok/resources/resource_string.dart';

import '../../../../theme/potok_theme.dart';
import '../../widgets/button/default_potok_button.dart';
import '../state/auth_controller.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> with TickerProviderStateMixin {
  late final GifController _controller;

  @override
  void initState() {
    _controller = GifController(vsync: this)
      ..addListener(() async {
        if (_controller.isCompleted) {
          await Future.delayed(const Duration(milliseconds: 1000));
          if (mounted) {
            _controller.reset();
            _controller.forward();
          }
        }
      });

    // The promptForPushNotificationsWithUserResponse function will show the iOS push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await Get.find<AuthController>().startNewSession(context);
      // var router = GoRouter.of(context);
      // bool isAuthorized = await _redirect(context);
      // if (isAuthorized == false) return;
      // // Handle initial deep link
      // scheduleMicrotask(() async {
      //   await Future.delayed(const Duration(milliseconds: 250));
      //   String? location = initialUri?.path;
      //   if (location == null) return;
      //   if (initialUri!.query != '') location = '$location?${initialUri!.query}';
      //   router.push(location);
      // });
    });

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = PotokTheme.of(context);
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.width * 0.5,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Gif(
                  image: currentAppTheme(context) == ThemeMode.dark ? const AssetImage("assets/animations/dark_logo.gif") : const AssetImage("assets/animations/light_logo.gif"),
                  controller: _controller, // if duration and fps is null, original gif fps will be used.
                  //fps: 30,               
                  // duration: const Duration(seconds: 3),
                  autostart: Autostart.no,
                  // placeholder: (context) => const Center(child: Text('Loading...')),
                  onFetchCompleted: () {
                      _controller.reset();
                      _controller.forward();
                  },
              )
            ),
            GetBuilder<AuthController>(
              builder: (controller) {
                return Column(
                  children: [
                    if (controller.isLoading) const CircularProgressIndicator.adaptive(),
                    if (controller.serverIsOffline) Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                      child: Text(
                        ResourceString.serverIsOffline,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Leto Text Sans Defect',
                          color: theme.textColor.withOpacity(.5)
                        ),
                      ),
                    ),
                    if (controller.errorMessage != null) Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                      child: Text(
                        ResourceString.errorDefault,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Leto Text Sans Defect',
                          color: theme.textColor.withOpacity(.5)
                        ),
                      ),
                    ),
                    if (controller.serverIsOffline || controller.errorMessage != null) DefaultPotokButton(
                      onTap: () => controller.startNewSession(context),
                      icon: Icons.error_outline_rounded,
                      text: ResourceString.tryAgain
                    )
                  ],
                );
              },
            )
          ],
        ),
      ),
    );
  }
}