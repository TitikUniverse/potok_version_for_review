import 'package:easy_localization/easy_localization.dart';

class ResourceString {
  static String get appName => 'Potok';

  // Theme
  static String get themeSystem => tr('theme.system');
  static String get themeLight => tr('theme.light');
  static String get themeDark => tr('theme.dark');

  // Errors
  static String get oops => tr('errors.oops');
  static String get everythingIsBad => tr('errors.everything_is_bad');
  static String get errorPageNotFound => tr('errors.page_not_found');
  static String get error => tr('errors.error');
  static String get errorDefault => tr('errors.error_default');
  static String get errorInvalidPassword => tr('errors.error_invalid_password');
  static String get errorEmptyField => tr('errors.error_empty_field');
  static String get errorInvalidUsername => tr('errors.error_invalid_username');
  static String get errorEnterCorrectEmail => tr('errors.error_enter_correct_email');
  static String get errorEnterCorrectUsername => tr('errors.error_enter_correct_username');
  static String get errorLoginOrPassword => tr('errors.error_login_or_password');
  static String get errorOpenUrl => tr('errors.error_open_url');
  static String get errorConnection => tr('errors.error_connection');
  static String get serverIsOffline => tr('errors.server_is_offline');

  // Auth
  static String get afterPerformingTheActionYouAgree => tr('auth.after_performing_the_action_you_agree');
  static String get userAgreement => tr('auth.user_agreement');
  static String get and => tr('auth.and');
  static String get privacyPolicy => tr('auth.privacy_policy');
  static String get authSignIn => tr('auth.sign_in');
  static String get username => tr('auth.username');
  static String get password => tr('auth.password');
  static String get confirmPassword => tr('auth.confirm_password');
  static String get authCreateNewAccount => tr('auth.create_new_account');
  static String get authAccountIsDeleted => tr('auth.account_is_deleted');
  static String get comeUpWithUsername => tr('auth.come_up_with_a_username');
  static String get comeUpWithPassword => tr('auth.come_up_with_a_password');
  static String get alreadyHaveAccount => tr('auth.already_have_an_account');
  static String get passwordsDontMatch => tr('auth.passwords_dont_match');
  static String get thisNicknameAlreadyOccupied => tr('auth.this_nickname_already_occupied');
  static String get successfulRegistration => tr('auth.successful_registration');
  static String get welcome => tr('auth.welcome');
  static String get thisOnlyForAuthUsers => tr('auth.this_only_for_auth_users');
  static String get unauthActionInfo => tr('auth.unauth_action_info');

  // Action
  static String get next => tr('action.next');
  static String get back => tr('action.back');
  static String get toMainScreen => tr('action.to_main_screen');
  static String get tryAgain => tr('action.try_again');

  // Section
  static String get mainTab => tr('section.main_tab');
  static String get recommendationTab => tr('section.recommendation_tab');
  static String get friendsTab => tr('section.friends_tab');
  static String get profileTab => tr('section.profile_tab');

  // Friend
  static String get subscribe => tr('friend.subscribe');
  static String get unsubscribe => tr('friend.unsubscribe');
  static String get removeFromFriends => tr('friend.remove_from_friends');
  static String get acceptAsFriends => tr('friend.accept_as_friends');

  // Messenger
  static String get toWrite => tr('messenger.to_write');

  // User_content
  static String get moveToArchive => tr('user_content.move_to_archive');
  static String get deletePost => tr('user_content.delete_post');
  static String get complain => tr('user_content.complain');
  static String get postMovedToArchive => tr('user_content.post_moved_to_archive');
  static String get postAddToSaved => tr('user_content.post_add_to_saved');
}