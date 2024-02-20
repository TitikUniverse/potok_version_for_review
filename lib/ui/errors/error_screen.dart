import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../navigation/routes.dart';
import '../../resources/resource_string.dart';
import '../../theme/potok_theme.dart';
import '../widgets/button/default_potok_button.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({Key? key, required this.title, required this.description}) : super(key: key);

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    var theme = PotokTheme.of(context);
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          ResourceString.error,
          style: TextStyle(fontWeight: FontWeight.w700, color: theme.textColor)
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: theme.textColor)
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(color: theme.textColor)
              ),
              const SizedBox(height: 4),
              DefaultPotokButton(
                onTap: () => context.go(NavigationRoutesString.root),
                backgroundColor: theme.frontColor,
                text: ResourceString.toMainScreen
              )
            ],
          ),
        ),
      ),
    );
  }
}