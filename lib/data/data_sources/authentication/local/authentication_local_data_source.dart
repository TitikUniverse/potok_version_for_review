import 'package:get/get.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter/services.dart' show PlatformException;

import '../../../../services/storage/index.dart';
import '../../../models/user/user_info_model.dart';

part 'authentication_local_data_source_impl.dart';

abstract class AuthenticationLocalDataSource {
  factory AuthenticationLocalDataSource() = AuthenticationLocalDataSourceImpl;

  bool get isFirstLaunch;

  bool get isLogged;

  Future<void> setFirstLaunch();

  Future<void> saveAuthenticationToken(String token);

  Future<void> removeAuthenticationToken();

  Future<void> saveAuthenticationRefreshToken(String refreshToken);

  Future<void> removeAuthenticationRefreshToken();

  Future<void> saveCurrentUser(UserInfoModel userInfoModel);

  Future<String?> getAuthenticationToken();

  Future<String?> getAuthenticationRefreshToken();

  Future<void> removeAllUserData();

  Future<String?> getInitLink();

  Stream<String?> get appLinkStream;

  UserInfoModel? get currentUser;
}
