import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:go_router/go_router.dart';

import '../../navigation/routes.dart';
import '../../resources/resource_string.dart';

Future<void> showUnauthWarning(BuildContext context) async {
  var _type = FeedbackType.error;
  Vibrate.feedback(_type);
  OkCancelResult response = await showOkCancelAlertDialog(
    context: context,
    isDestructiveAction: false,
    title: ResourceString.error,
    message: ResourceString.unauthActionInfo
  );
  if (response.index == 1) return;
  GoRouter.of(context).push(NavigationRoutesString.login);
}