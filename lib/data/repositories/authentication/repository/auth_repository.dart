import 'dart:async';

import '../../../data_sources/authentication/local/authentication_local_data_source.dart';
import '../../../data_sources/authentication/remote/authentication_remote_data_source.dart';
import '../../../models/api_error.dart';
import '../../../models/auth/auth_info_model.dart';
import '../../../models/base_response.dart';
import '../../../models/user/user_info_model.dart';
import 'authentication_status.dart';

part 'auth_repository_impl.dart';

abstract class AuthRepository {
  factory AuthRepository() = AuthRepositoryImpl;

  Stream<AuthenticationStatus> get loggedStatusGenerator;

  AuthenticationStatus get loggedStatus;

  bool get isFirstLaunch;

  bool get isLogged;

  Future<void> setFirstLaunch();

  /// Если token указать null, то будет авторизован первый пользователь из хранилища аккаунтов
  Future<BaseResponse<UserInfoModel, ApiError>> startNewSession(String? token);

  Future<BaseResponse<AuthInfoModel, ApiError>> authenticate(String nickname, String password);

  Future<BaseResponse<bool, ApiError>> doesUserExist(String nickname);

  /// Регистрация не является авторизацией и требует после себя авторизацию
  Future<BaseResponse<UserInfoModel, ApiError>> register(String nickname, String password);

  Future<void> logOut();

  FutureOr<void> close();

  Stream<String?> get appLinkStream;

  Future<String?> get initialRoute;
}