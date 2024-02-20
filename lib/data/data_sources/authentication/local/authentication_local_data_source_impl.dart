part of 'authentication_local_data_source.dart';

class AuthenticationLocalDataSourceImpl
    implements AuthenticationLocalDataSource {
  final StorageDataService _storageDataService = Get.find<StorageDataService>();

  @override
  bool get isFirstLaunch =>
      _storageDataService.get<bool>(kFirstStartKey) ?? true;

  @override
  bool get isLogged =>
      (_storageDataService.getToken(kEncryptedAuthorizationTokenKey) ?? '').isNotEmpty;

  @override
  Future<void> setFirstLaunch() async =>
      _storageDataService.set<bool>(kFirstStartKey, false);

  @override
  Future<void> saveAuthenticationToken(String token) async =>
      _storageDataService.saveToken(token, kEncryptedAuthorizationTokenKey);
  
  @override
  Future<void> saveAuthenticationRefreshToken(String token) async =>
      _storageDataService.saveToken(token, kEncryptedRefreshTokenKey);
  
  @override
  Future<void> saveCurrentUser(UserInfoModel userInfoModel) async =>
      _storageDataService.set<String>(kCurrentUserKey, userInfoModel.toRawJson());

  @override
  Future<String?> getAuthenticationToken() async =>
      _storageDataService.getToken(kEncryptedAuthorizationTokenKey);
  
  @override
  Future<String?> getAuthenticationRefreshToken() async =>
      _storageDataService.getToken(kEncryptedRefreshTokenKey);

  @override
  Future<void> removeAuthenticationToken() async =>
      _storageDataService.removeToken(kEncryptedAuthorizationTokenKey);
  
  @override
  Future<void> removeAuthenticationRefreshToken() async =>
      _storageDataService.removeToken(kEncryptedRefreshTokenKey);

  @override
  Future<void> removeAllUserData() async {
    await _storageDataService.clearUserData();
  }

  @override
  Stream<String?> get appLinkStream => linkStream;

  @override
  UserInfoModel? get currentUser {
    var userInfoModel = _storageDataService.get<String?>(kCurrentUserKey);
    if (userInfoModel != null) {
      return UserInfoModel.fromRawJson(userInfoModel);
    }
    return null;
  }

  @override
  Future<String?> getInitLink() async {
    try {
      final initialAppLink = await getInitialLink();
      return initialAppLink;
    } on PlatformException {
      return null;
    }
  }
}
