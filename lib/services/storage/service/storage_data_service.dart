import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'boxes_keys.dart';

class StorageDataService {
  late final Box<String> _encryptedTokenBox;
  late final Box _dataBox;

  Future<StorageDataService> init() async {
    await Hive.initFlutter();
    await _openBoxes();
    return this;
  }

  Future<void> _openBoxes() async {
    var encryptionKey = await _encryptionKey;
    _encryptedTokenBox = await Hive.openBox(kEncryptedAuthorizationTokenBoxName,
        encryptionCipher: HiveAesCipher(encryptionKey));
    _dataBox = await Hive.openBox(kDataBoxName);
  }

  Future<Uint8List> get _encryptionKey async {
    var secureStorage = const FlutterSecureStorage();
    String? encryptionKeyStorage;
    try {
      await secureStorage.read(key: kSecureKey);
      encryptionKeyStorage = await secureStorage.read(key: kSecureKey);
    } on PlatformException {
      await secureStorage.deleteAll();
    }
    if (encryptionKeyStorage?.isNotEmpty != true) {
      var key = Hive.generateSecureKey();
      await secureStorage.write(key: kSecureKey, value: base64UrlEncode(key));
    }
    var encryptionKey =
        base64Url.decode((await secureStorage.read(key: kSecureKey)) ?? '');
    return encryptionKey;
  }

  Future<void> saveToken(String? token, String key) async {
    if (token?.isNotEmpty == true) {
      await _encryptedTokenBox.delete(key);
      await _encryptedTokenBox.put(key, token!);
    }
  }

  String? getToken(String key) => _encryptedTokenBox.get(key) ?? '';

  Future<void> removeToken(String key) async => _encryptedTokenBox.delete(key);

  Future<void> set<T>(String key, T? value) async {
    if (value != null) {
      await _dataBox.delete(key);
      await _dataBox.put(key, value);
    }
  }

  T? get<T>(String key, {T? defaultValue}) {
    final result = _dataBox.get(key) as T?;
    if (T is bool) {
      return (result ?? defaultValue ?? false) as T;
    }
    return result ?? defaultValue;
  }

  Future<void> remove(String key) async => _dataBox.delete(key);

  Future<void> clearAllData() async {
    await _encryptedTokenBox.clear();
    await _dataBox.clear();
  }

  Future<void> clearUserData() async {
    await _encryptedTokenBox.clear();
    var dataBoxKeys = _dataBox.keys;
    for (var key in dataBoxKeys) {
      if (key != kFirstStartKey) {
        await _dataBox.delete(key);
      }
    }
  }
}
