import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../resources/resource_string.dart';
import '../../theme/potok_theme.dart';
import '../widgets/button/default_potok_button.dart';

class NotRegisteredUserScreen extends StatefulWidget {
  const NotRegisteredUserScreen({super.key});

  @override
  State<NotRegisteredUserScreen> createState() => _NotRegisteredUserScreenState();
}

class _NotRegisteredUserScreenState extends State<NotRegisteredUserScreen> {
  @override
  Widget build(BuildContext context) {
    var theme = PotokTheme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              ResourceString.thisOnlyForAuthUsers,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.textColor
              ),
            ),
            const SizedBox(height: 10.0),
            DefaultPotokButton(
              onTap: () {
                context.push('/login');
              },
              icon: Icons.person,
              text: ResourceString.authSignIn,
              backgroundColor: theme.frontColor,
            )
          ],
        ),
      ),
      // bottomNavigationBar: bottomNavBar(context),
    );
  }
}