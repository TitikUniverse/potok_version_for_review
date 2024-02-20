import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../data/data_sources/authentication/local/authentication_local_data_source.dart';
import '../../../services/user_content_upload/service/user_content_upload_service.dart';
import '../../widgets/shackbar/snackbar.dart';
import 'user_content_controller.dart';

class NewPostController extends GetxController {
  final TextEditingController textController = TextEditingController();

  /// Кнопка отправки нового поста занята или нет
  bool isSendPostButtonLoading = false;

  /// Записывается ли в данный момент голосовое
  bool isVoiceMessageRecording = false;

  bool _isSendPostButtonShow = false;

  /// Показывать ли кнопку отправки сообщения.
  /// Она может не показываться, например, если юзер хочет записать голосовое
  bool get isSendPostButtonShow => _isSendPostButtonShow;

  set isSendPostButtonShow(bool value) {
    _isSendPostButtonShow = value;
    update();
  }

  final Map<AssetEntity, Uint8List> _attachedFilesToPost = {};

  /// Файлы, которые пользователь собирается прикрепить к новому посту
  /// 
  /// [AssetEntity] - сам файл.
  /// [Uint8List] - обложка (превью)
  Map<AssetEntity, Uint8List> get attachedFilesToPost => _attachedFilesToPost;

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }

  /// Добавить новый файл с устройства к посту в виде вложения
  void attachFileToNewPost(AssetEntity file, Uint8List cover) {
    _attachedFilesToPost[file] = cover;
    update();
  }

  /// Открепить уже прикреплённый файл от нового поста
  void removeFileFromAttachedToPost(int keyIndex) {
    _attachedFilesToPost.remove(_attachedFilesToPost.keys.toList()[keyIndex]);
    update();
  }

  /// Открывает окно для выбора файлов с утройства
  Future<void> pickContent(BuildContext context) async {
    var content = await Get.find<UserContentUploadService>().pickContent(context);
    if (content == null) return;
    if (attachedFilesToPost.isNotEmpty && content.first.type != attachedFilesToPost.keys.first.type) {
      attachedFilesToPost.clear(); // Открепить все вложения от поста, если новые другого типа
      PotokSnackbar.info(context, message: 'Можно прикреплять только файлы одиного типа');
    }
    for (var element in content) {
      var file = await element.thumbnailData;
      if (file != null) attachedFilesToPost[element] = file;
    }
    update();
  }

  Future<void> uploadPost(BuildContext context) async {
    if (isSendPostButtonLoading) return;
    if (textController.text.isEmpty && _attachedFilesToPost.isEmpty) return;
    isSendPostButtonLoading = true;
    update();

    List<File> files = [];
    for (var element in _attachedFilesToPost.keys) {
      var file = await element.file;
      if (file != null) files.add(file);
    }

    var contentManager = Get.find<UserContentUploadService>();
    late bool resultUpload;

    if (_attachedFilesToPost.isEmpty) {
      if (textController.text.isEmpty) return;
      resultUpload = await contentManager.uploadText(context, postDescription: textController.text);
    }
    else if (_attachedFilesToPost.keys.first.type == AssetType.image) {
      resultUpload = await contentManager.uploadImages(context, files, postDescription: textController.text);
    } 
    else if (_attachedFilesToPost.keys.first.type == AssetType.video) {
      resultUpload = await contentManager.uploadVideo(context, files, cover: _attachedFilesToPost.values.first, postDescription: textController.text);
    }

    if (resultUpload == true) {
      _attachedFilesToPost.clear();
      textController.text = '';
      isSendPostButtonLoading = false;
      update();

      var authenticationLocalDataSource = AuthenticationLocalDataSource();
      Get.find<UserContentController>(tag: authenticationLocalDataSource.currentUser!.nickname).fetchUserPosts(authorId: authenticationLocalDataSource.currentUser!.id, isRefreshRequest: true);
    }
    else {
      isSendPostButtonLoading = false;
      update();
    }
  }
}