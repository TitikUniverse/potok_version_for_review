import 'package:flutter/material.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key, this.initialPageIndex});

  final int? initialPageIndex;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Friends Screen'),
      ),
    );
  }
}