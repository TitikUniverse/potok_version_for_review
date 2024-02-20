import 'package:flutter/widgets.dart';

import '../../../resources/resource_string.dart';
import '../../../theme/potok_theme.dart';
import '../../base/base_screen_mixin.dart';
import '../../widgets/shackbar/snackbar.dart';

class EulaText extends StatelessWidget with BaseScreenMixin {
  const EulaText({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = PotokTheme.of(context);
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.center,
      children: [
        Text(ResourceString.afterPerformingTheActionYouAgree,
        textAlign: TextAlign.center,
          style: TextStyle(
            color: theme.textColor.withOpacity(.5),
            fontSize: 14,
          ),
          softWrap: true,
        ),
        GestureDetector(
          onTap: () async {
            String url = 'https://potok.online/ru/termsofuse.html';
            try {
              launchURL(url);
            } catch (e) {
              PotokSnackbar.failure(context, title: ResourceString.error, message: ResourceString.errorOpenUrl);
            }
          },
          child: Text(
            ResourceString.userAgreement,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.textColor.withOpacity(.7),
              fontSize: 14,
              decoration: TextDecoration.underline
            ),
          ),
        ),
        Text(' ${ResourceString.and} ',
        textAlign: TextAlign.center,
          style: TextStyle(
            color: theme.textColor.withOpacity(.5),
            fontSize: 14,
          ),
          softWrap: true,
        ),
        GestureDetector(
          onTap: () async {
            String url = 'https://potok.online/ru/privacy.html';
            try {
              launchURL(url);
            } catch (e) {
              PotokSnackbar.failure(context, title: ResourceString.error, message: ResourceString.errorOpenUrl);
            }
          },
          child: Text(
            ResourceString.privacyPolicy,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.textColor.withOpacity(.7),
              fontSize: 14,
              decoration: TextDecoration.underline
            ),
          ),
        ),
      ],
    );
  }
}