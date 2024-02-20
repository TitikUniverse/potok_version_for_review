part of 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final StreamController<AuthenticationStatus> _authenticationStatusController =
      StreamController<AuthenticationStatus>.broadcast();
  
  final AuthenticationLocalDataSource _authenticationLocalDataSource =
      AuthenticationLocalDataSource();
  final AuthenticationRemoteDataSource _authenticationRemoteDataSource =
      AuthenticationRemoteDataSource();
  
  @override
  Stream<AuthenticationStatus> get loggedStatusGenerator async* {
    yield loggedStatus;
    yield* _authenticationStatusController.stream;
  }

  @override
  Future<BaseResponse<UserInfoModel, ApiError>> register(String nickname, String password) async {
    return await _authenticationRemoteDataSource.register(nickname, password);
  }

  @override
  Future<BaseResponse<UserInfoModel, ApiError>> startNewSession(String? token) async {
    token ??= await _authenticationLocalDataSource.getAuthenticationToken();
    if (token == null) throw Exception('[startNewSession] Token is required field');
    var startNewSessionResponse = await _authenticationRemoteDataSource.startNewSession(token: token);
    if (startNewSessionResponse.isSuccessful && startNewSessionResponse.data != null) {
      await _authenticationLocalDataSource.saveCurrentUser(startNewSessionResponse.data!);
      _authenticationStatusController.add(AuthenticationStatus.authorized);
    }
    return startNewSessionResponse;
  }

  @override
  Future<BaseResponse<AuthInfoModel, ApiError>> authenticate(String nickname, String password) async {
    var authResponse = await _authenticationRemoteDataSource.authenticate(nickname, password);
    var token = authResponse.data?.token;
    var refreshToken = authResponse.data?.refreshToken;
    var currentUser = authResponse.data?.userInfoModel;
    if (authResponse.isSuccessful && token != null && refreshToken != null && currentUser != null) {
      await _authenticationLocalDataSource.saveAuthenticationToken(token);
      await _authenticationLocalDataSource.saveAuthenticationRefreshToken(refreshToken);
      await _authenticationLocalDataSource.saveCurrentUser(currentUser);
      _authenticationStatusController.add(AuthenticationStatus.authorized);
    }
    return authResponse;
  }

  @override
  Future<BaseResponse<bool, ApiError>> doesUserExist(String nickname) async {
    return await _authenticationRemoteDataSource.doesUserExist(nickname);
  }

  @override
  AuthenticationStatus get loggedStatus {
    if (isFirstLaunch) {
      return AuthenticationStatus.firstStart;
    } else if (isLogged) {
      return AuthenticationStatus.authorized;
    } else {
      return AuthenticationStatus.unauthorized;
    }
  }

  @override
  bool get isFirstLaunch => _authenticationLocalDataSource.isFirstLaunch;

  @override
  bool get isLogged => _authenticationLocalDataSource.isLogged;

  @override
  Stream<String?> get appLinkStream =>
      _authenticationLocalDataSource.appLinkStream;
  
  @override
  Future<String?> get initialRoute async {
    return await _authenticationLocalDataSource.getInitLink();
  }

  @override
  Future<void> setFirstLaunch() async {
    await _authenticationLocalDataSource.setFirstLaunch();
    _authenticationStatusController.add(AuthenticationStatus.unauthorized);
  }

  @override
  Future<void> logOut() async {
    await _authenticationLocalDataSource.removeAllUserData();
  }

  @override
  FutureOr<void> close() async {
    _authenticationStatusController.close();
  }
}