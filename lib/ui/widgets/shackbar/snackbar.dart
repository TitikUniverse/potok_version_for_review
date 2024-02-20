import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import 'custom_snack_bar.dart';

class PotokSnackbar {
  PotokSnackbar.failure(BuildContext context, {String? title, required String message,}) {
    showTopSnackBar(
      curve: Curves.fastLinearToSlowEaseIn,
      dismissType: DismissType.onSwipe,
      Overlay.of(context),
      CustomSnackBar.error(
        message: message,
      ),
    );
  }

  PotokSnackbar.info(BuildContext context, {String? title, required String message,}) {
    showTopSnackBar(
      curve: Curves.fastLinearToSlowEaseIn,
      dismissType: DismissType.onSwipe,
      Overlay.of(context),
      CustomSnackBar.info(
        message: message,
      ),
    );
  }

  PotokSnackbar.success(BuildContext context, {String? title, required String message,}) {
    showTopSnackBar(
      curve: Curves.fastLinearToSlowEaseIn,
      dismissType: DismissType.onSwipe,
      Overlay.of(context),
      CustomSnackBar.success(
        message: message,
      ),
    );
  }

  // PotokSnackbar.warning(BuildContext context, {required String title, required String message,}) {
  //   var snackBar = _getSnackBar(context, title: title, message: message, contentType: ContentType.warning);
  //   ScaffoldMessenger.of(context)
  //     ..hideCurrentSnackBar()
  //     ..showSnackBar(snackBar);
  // }
}