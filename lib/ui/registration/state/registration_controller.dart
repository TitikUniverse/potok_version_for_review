import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:potok/navigation/routes.dart';

import '../../../data/repositories/authentication/index.dart';
import '../../../resources/resource_string.dart';
import '../../widgets/shackbar/snackbar.dart';

class RegistrationController extends GetxController {
  RegistrationController({required AuthRepository authRepository}) : _authRepository = authRepository;

  final AuthRepository _authRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _passIsHidden = true;
  bool get passIsHidden => _passIsHidden;

  void changePassVisible() {
    _passIsHidden = !_passIsHidden;
    update();
  }

  Future<bool?> doesUserExist(BuildContext context, String nickname) async {
    _isLoading = true;
    update();
    var request = await _authRepository.doesUserExist(nickname);
    _isLoading = false;
    update();
    if (request.isSuccessful && request.data != null) {
      PotokSnackbar.failure(context, title: ResourceString.error, message: ResourceString.thisNicknameAlreadyOccupied);
      return request.data!;
    } else {
      PotokSnackbar.failure(context, title: ResourceString.error, message: request.error?.error?.errorMessage ?? ResourceString.errorDefault);
      return null;
    }
  }

  Future register(BuildContext context, String nickname, String password) async {
    _isLoading = true;
    update();
    
    var registerRequest = await _authRepository.register(nickname, password);
    if (registerRequest.isError) {
      PotokSnackbar.failure(context, title: ResourceString.error, message: registerRequest.error?.error?.errorMessage ?? ResourceString.errorDefault);
      return;
    }
    PotokSnackbar.success(context, title: ResourceString.welcome, message: ResourceString.successfulRegistration);

    var authRequest = await _authRepository.authenticate(nickname, password);
    if (authRequest.isError) {
      PotokSnackbar.failure(context, title: ResourceString.error, message: authRequest.error?.error?.errorMessage ?? ResourceString.errorDefault);
      return;
    }

    GoRouter.of(context).push(NavigationRoutesString.recommendation);
  }
}