import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/repositories/authentication/index.dart';
import '../../../../navigation/routes.dart';
import '../../../../resources/resource_string.dart';
import '../../widgets/shackbar/snackbar.dart';

class AuthController extends GetxController {
  AuthController({required AuthRepository authRepository}) : _authRepository = authRepository;

  final AuthRepository _authRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _serverIsOffline = false;
  bool get serverIsOffline => _serverIsOffline;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> startNewSession(BuildContext context) async {
    _isLoading = true;
    _serverIsOffline = false;
    _errorMessage = null;
    update();
    if (_authRepository.isLogged == false) {
      _setInitialState();
      GoRouter.of(context).go(NavigationRoutesString.login);
    } else {
      var startNewSessionResponse = await _authRepository.startNewSession(null);
      if (startNewSessionResponse.isSuccessful) {
        _setInitialState();
        var initialRoute = await _authRepository.initialRoute;
        if (initialRoute != null) {
          GoRouter.of(context).go(initialRoute);
        } else {
          GoRouter.of(context).go(NavigationRoutesString.recommendation);
        }
      } else {
        if (startNewSessionResponse.statusCode == HttpStatus.badGateway) {
          _serverIsOffline = true;
          _isLoading = false;
          update();
        } else if (startNewSessionResponse.statusCode == HttpStatus.unauthorized || startNewSessionResponse.statusCode == HttpStatus.forbidden) {
          _isLoading = false;
          update();
          GoRouter.of(context).go(NavigationRoutesString.login);
        } else {
          _isLoading = false;
          _errorMessage = startNewSessionResponse.error?.error?.errorMessage ?? ResourceString.error;
          update();
        }
      }
    }
  }

  Future<void> authenticate(BuildContext context, {required String nickname, required String password}) async {
    _setInitialState();
    var authenticateResponse = await _authRepository.authenticate(nickname, password);
    if (authenticateResponse.isSuccessful) {
      if (authenticateResponse.data?.userInfoModel?.isDeleted == true) {
        _errorMessage = ResourceString.authAccountIsDeleted;
        update();
      } else {
        var initialRoute = await _authRepository.initialRoute;
        if (initialRoute != null) {
          GoRouter.of(context).go(initialRoute);
        } else {
          GoRouter.of(context).go(NavigationRoutesString.recommendation);
        }
      }
    } else {
      _isLoading = false;
      _errorMessage = authenticateResponse.error?.error?.errorMessage ?? ResourceString.errorDefault;
      PotokSnackbar.failure(context, title: ResourceString.error, message: _errorMessage ?? ResourceString.errorDefault);
      update();
    }
  }

  void _setInitialState() {
    _isLoading = false;
    _serverIsOffline = false;
    _errorMessage = null;
    update();
  }
}