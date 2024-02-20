import 'package:url_launcher/url_launcher.dart';

import '../../utils/validator.dart';

mixin BaseScreenMixin {
  Future<void> launchURL(String? url,
      [LaunchMode mode = LaunchMode.platformDefault]) async {
    if (url?.isNotEmpty != true) return;
    final parseUrl = Uri.parse(url!);
    var isEmail = emailValidator(url)?.isNotEmpty != true;
    if (isEmail) {
      launchEmail(url);
    } else {
      if (await canLaunchUrl(parseUrl)) {
        await launchUrl(parseUrl, mode: mode);
      } else {
        throw parseUrl;
      }
    }
  }

  Future<void> launchEmail(String? email) async {
    final emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: _encodeQueryParameters(<String, String>{
        'subject': '',
      }),
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      throw emailLaunchUri;
    }
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}