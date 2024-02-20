import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:light_compressor/light_compressor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:photo_manager/photo_manager.dart';
import 'package:potok/utils/extensions/get_file_size.dart';
import 'package:titik_attachment_picker/titik_attachment_picker.dart';

import '../../../data/models/user_content/object_fit.dart';
import '../../../data/models/user_content/post_content_type.dart';
import '../../../data/models/user_content/s3_fileview.dart';
import '../../../data/repositories/user_content/repository/user_content_repository.dart';
import '../../../resources/resource_string.dart';
import '../../../theme/potok_theme.dart';
import '../../../ui/widgets/shackbar/snackbar.dart';
import '../../../utils/color_print.dart';

class UserContentUploadService {
  UserContentUploadService({required UserContentRepository userContentRepository}) : _userContentRepository = userContentRepository;

  final UserContentRepository _userContentRepository;

  Future<List<AssetEntity>?> pickContent(BuildContext context, [List<AttachmentType> avaiableTypes = const [AttachmentType.photo, AttachmentType.video]]) async {
    var theme = PotokTheme.of(context);
    final PermissionState _ps = await PhotoManager.requestPermissionExtend();
    if (_ps.isAuth) {
      TitikAttachmentPicker _attachmentPicker = TitikAttachmentPicker(
        avaiableTypes: avaiableTypes,
        height: MediaQuery.of(context).size.height * 0.90,
        attachmentStyle: AttachmentStyle(
          selectedColor: theme.brandColor,
          selectedTextStyle: const TextStyle(
            color: Colors.white
          ),
          primaryColor: theme.brandColor
        ),
        backgroundColor: theme.backgroundColor,
        textColor: theme.textColor
      );

      final List<AssetEntity> result = await _attachmentPicker.open(context);

      if (result.isNotEmpty) {
        return result;
      }
      return null;
    }
    else if (_ps == PermissionState.limited) {
      await PhotoManager.presentLimited();
      await PhotoManager.openSetting();
    }
    else {
      await PhotoManager.openSetting();
      // TODO: Limited(iOS) or Rejected, use `==` for more precise judgements.
      // You can call `PhotoManager.openSetting()` to open settings for further steps.
    }
    return null;
  }

  Future<bool> uploadImages(BuildContext context, List<File> files, {String? postDescription}) async {
    List<String?> imageData = [];
    if (files.isNotEmpty) {
      PotokSnackbar.info(context, message: 'Фотография загружается');
      for (int i = 0; i < files.length; i++) {
        Directory tempDir = await getTemporaryDirectory();
        File? preparedFile = await _compressAndGetPhotoFile(files[i], '${tempDir.path}/${DateTime.now().toIso8601String()}${p.extension(files[i].path)}');
        if (files[i].path != preparedFile?.path) {
          // Преобразование дало результат и теперь можно преобразовывать
          // ! Если в этот if не попало, то преобразование не удалось по уважительной причине и остался изначальный файл. Если он лежит в DCIM, то переименовать его не получится (permission denied) и будем грузить оргиниал в этом случае
          String rndFileName = _getRandomString(15);
          preparedFile = await _changeFileNameOnly(preparedFile, '$rndFileName${p.extension(preparedFile!.path)}');
        }

        var uploadResultModel = await _userContentRepository.uploadFile(preparedFile!.path, p.basename(preparedFile.path), S3FileView.profilepostimage);
        if (uploadResultModel.isSuccessful) {
          imageData.add(uploadResultModel.data!.data);
        } 
        else if (uploadResultModel.statusCode == 413) {
          PotokSnackbar.failure(context, message: 'Видео слишком большое');
          return false;
        } 
        else {
          PotokSnackbar.failure(context, message: ResourceString.errorDefault);
          return false;
        }
      }
    } 
    else {
      return false;
    }

    // Отгрузка в API к БД
    var actionResult =
        await _userContentRepository.addNewPost(
            imageData,
            'profile-post-image',
            (postDescription == null || postDescription.isEmpty) ? PostContentType.singleImage : PostContentType.imageAndText,
            postDescription,
            false,
            false,
            ObjectFit.fitWidth,
            null);

    if (actionResult.isSuccessful && actionResult.data != null) {
      return true;
    } 
    else {
      PotokSnackbar.failure(context, message: actionResult.error?.error?.errorMessage ?? ResourceString.errorDefault);
      return false;
    }
  }

  Future<bool> uploadVideo(BuildContext context, List<File> files, {String? postDescription, required Uint8List cover}) async {
    Directory tempDir = await getTemporaryDirectory();
    File coverFile = await File('${tempDir.path}/${DateTime.now().toIso8601String()}.png').create();
    coverFile.writeAsBytesSync(cover);
    files.add(coverFile);
    final FlutterVideoInfo videoInfo = FlutterVideoInfo();
    // Отгрузка в бакет
    List<String?> videoData = [];
    if (files.isNotEmpty) {
      if (files.length != 2) {
        PotokSnackbar.failure(context, message: 'Error: content must be contain 2 item');
        return false;
      }
      PotokSnackbar.info(context, message: 'Видео загружается');
      for (int i = 0; i < files.length; i++) {
        VideoCompressResult<File?> compressResult;

        // Первым всегда идет видео
        if (i == 0) {
          compressResult = await _compressAndGetVideoFileAndroid(files[i]);
          switch (compressResult.returnType) {
            case ReturnType.bitrate_is_low:
              compressResult.file = files[i];
              break;
            case ReturnType.success:
              PotokSnackbar.info(context, message: 'Видео было сжато для улучшения скорости загрузки');
              break;
            default:
              String recommendation = 'Наша рекомендация на счет публикации этого видео: не рекомендуем.';
              VideoData? vInfo = await videoInfo.getVideoInfo(files[i].path);
              if (vInfo == null) {
                recommendation = 'Наша рекомендация на счет публикации этого видео: не удалось вычислить рекомендацию.';
              } else if ((vInfo.filesize! / 1000000) / (vInfo.duration! / 1000) < 1.2) { // Если размер видео на 1 секунду меньше чем 1.2Mb
                recommendation = 'Наша рекомендация на счет публикации этого видео: рекомендуем.';
              }
              
              Vibrate.feedback(FeedbackType.error);
              OkCancelResult response = await showOkCancelAlertDialog(
                context: context,
                isDestructiveAction: false,
                title: 'Не удалось сжать видео',
                message: 'Обратите внимание: если ваше видео весит слишком много, пользователи могут игнорировать его из-за слишком медленной загрузки.\n$recommendation\nПродолжить без сжатия?'
              );
              if (response.index == 1) {
                return false;
              }
              compressResult.file = files[i];
          }
          if (compressResult.file == null) {
            PotokSnackbar.failure(context, message: 'Не удалось обработать видео. Сообщите в поддержку');
            return false;
          }
          var uploadResultModel = await _userContentRepository.uploadFile(compressResult.file!.path, p.basename(compressResult.file!.path), S3FileView.profilepostvideo);
          if (uploadResultModel.isSuccessful) {
            videoData.add(uploadResultModel.data!.data); 
          } 
          else if (uploadResultModel.statusCode == 413) {
            PotokSnackbar.failure(context, message: 'Видео слишком большое');
            return false;
          } 
          else {
            PotokSnackbar.failure(context, message: ResourceString.errorDefault);
            return false;
          }
        }
        // Вторым всегда идет превью видео
        if (i == 1) {
          File? cover = files[i];
          var uploadResultModel =
            await _userContentRepository.uploadFile(
              cover.path,
              p.basename(cover.path),
              S3FileView.profilepostthumbnailvideo
            );
          if (uploadResultModel.isSuccessful) {
            videoData.add(uploadResultModel.data!.data);
          } 
          else if (uploadResultModel.statusCode == 413) {
            PotokSnackbar.failure(context, message: 'Видео слишком большое');
            return false;
          } 
          else {
            PotokSnackbar.failure(context, message: ResourceString.errorDefault);
            return false;
          }
        }
      }
    } else {
      return false;
    }

    // Отгрузка в API к БД
    var actionResult = await _userContentRepository.addNewPost(
      videoData,
      'profile-post-video',
      (postDescription == null || postDescription.isEmpty) ? PostContentType.singleVideo : PostContentType.videoAndText,
      postDescription,
      false,
      false,
      ObjectFit.fitWidth,
      null
    );

    if (actionResult.isSuccessful && actionResult.data != null) {
      PotokSnackbar.success(context, message: 'Видео загружено');
      return true;
    } 
    else {
      PotokSnackbar.failure(context, message: actionResult.error?.error?.errorMessage ?? "Произошла ошибка при загрузке видео. Обратитесь в поддержку");
      return false;
    }
  }

  Future<bool> uploadText(BuildContext context, {required String postDescription}) async {
    // Отгрузка в API к БД
    var actionResult = await _userContentRepository.addNewPost(
      [],
      'null',
      PostContentType.singleText,
      postDescription,
      false,
      false,
      ObjectFit.fitWidth,
      null
    );
    if (actionResult.data != null) {
      PotokSnackbar.success(context, message: 'Текст загружен');
      return true;
      // GoRouter.of(context).go('/${CurrentUser.currentUser!.nickname}');
    } 
    else {
      PotokSnackbar.failure(context, message: actionResult.error?.error?.errorMessage ?? "Произошла ошибка. Обратитесь в поддержку");
      return false;
    }
  }
  
  Future<bool> uploadVoice(BuildContext context, {required File voiceFile, required Duration voiceDuration}) async {
    late String content;

    // Отгрузка голосового в бакет
    var uploadResultModel = await _userContentRepository.uploadFile(voiceFile.path, p.basename(voiceFile.path), S3FileView.voice);
    if (uploadResultModel.statusCode == 201) {
      content = json.encode({'url': uploadResultModel.data!.data, 'duration': voiceDuration.inMilliseconds});
    } 
    else if (uploadResultModel.statusCode == 413) {
      PotokSnackbar.failure(context, message: 'Голосовое слишком большое');
      return false;
    } 
    else {
      PotokSnackbar.failure(context, message: uploadResultModel.error?.error?.errorMessage ?? "Произошла ошибка. Обратитесь в поддержку");
      return false;
    }
    
    // Отгрузка в API к БД
    var actionResult = await _userContentRepository.addNewPost(
      [content],
      'voice',
      PostContentType.voice,
      null,
      false,
      false,
      ObjectFit.fitWidth,
      null
    );
    if (actionResult.data != null) {
      PotokSnackbar.success(context, message: 'Голосовое сообщение загружено');
      return true;
      // GoRouter.of(context).go('/${CurrentUser.currentUser!.nickname}');
    } 
    else {
      PotokSnackbar.failure(context, message: actionResult.error?.error?.errorMessage ?? "Произошла ошибка. Обратитесь в поддержку");
      return false;
    }
  }

  Future<File?> _compressAndGetPhotoFile(File file, String targetPath) async {
    // String fl = await file.getFileSizeString();
    double fileLength = file.size;
    if (fileLength < 0.6) {
      // Если файл весит меньше 600 Кб - компрессировать не нужно
      return file;
    }

    XFile? result;
    try {
      if (p.extension(file.path).toLowerCase() != '.heic') {
        throw UnsupportedError("Этот файл имеет формат, отличный от .heic");
      }
      result = await FlutterImageCompress.compressAndGetFile(
          file.absolute.path, targetPath,
          quality: 60, format: CompressFormat.heic);
    } on UnsupportedError catch (e) {
      debugPrint(e.toString());
      bool isJpeg = p.extension(file.path).toLowerCase() == '.jpeg' || p.extension(file.path).toLowerCase() == '.jpg';
      result = await FlutterImageCompress.compressAndGetFile(
          file.absolute.path, targetPath,
          quality: 54,
          format: isJpeg ? CompressFormat.jpeg : CompressFormat.png);
    }
    return result != null ? File(result.path) : null;
  }

  Future<VideoCompressResult<File?>> _compressAndGetVideoFileAndroid(File file) async {
    final LightCompressor _lightCompressor = LightCompressor();
    final FlutterVideoInfo videoInfo = FlutterVideoInfo();

    int targetHeight = 1024;
    int targetWidth = 576;

    var a = await videoInfo.getVideoInfo(file.path);

    if (a != null) {
      // Keep the original orientation
      if (a.orientation == 90 || a.orientation == 270) {
        // var temp = targetHeight;
        // targetHeight = targetWidth;
        // targetWidth = temp;
        targetHeight = a.height!;
        targetWidth = a.width!;
      }
      else if (a.width! > a.height!) {
        targetHeight = a.height!;
        targetWidth = a.width!;
      }
    }

    final Result response = await _lightCompressor.compressVideo(
      path: file.path,
      videoQuality: VideoQuality.high,
      isMinBitrateCheckEnabled: true,
      video: Video(
        videoName: _getRandomString(20),
        videoHeight: targetHeight,
        videoWidth: targetWidth,
      ),
      android: AndroidConfig(isSharedStorage: true, saveAt: SaveAt.Movies),
      ios: IOSConfig(saveInGallery: false)
    );

    if (response is OnSuccess) {
      final String outputFilePath = response.destinationPath;
      // use the file
      return VideoCompressResult(
        file: File(outputFilePath),
        returnType: ReturnType.success
      );
    } else if (response is OnFailure) {
      // failure message
      printError(response.message);
      if (response.message.startsWith('[Bitrate is low]')) {
        return VideoCompressResult(
          file: null,
          returnType: ReturnType.bitrate_is_low
        );
      }
      else if (response.message.startsWith('[Metadata]')) {
        return VideoCompressResult(
          file: null,
          returnType: ReturnType.metada_error
        );
      }
      
      return VideoCompressResult(
        file: null,
        returnType: ReturnType.internal_error
      );

    } else if (response is OnCancelled) {
      print(response.isCancelled);
      return VideoCompressResult(
        file: null,
        returnType: ReturnType.cancelled
      );
    }
    return VideoCompressResult(
      file: null,
      returnType: ReturnType.internal_error
    );
  }

  String _getRandomString(int length) {
    Random _rnd = Random();
    const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz';
    return String.fromCharCodes(Iterable.generate(
        length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }

  Future<File?> _changeFileNameOnly(File? file, String newFileName) {
    if (file == null) return Future.value(null);
    var path = file.path;
    var lastSeparator = path.lastIndexOf(Platform.pathSeparator);
    var newPath = path.substring(0, lastSeparator + 1) + newFileName;
    return file.rename(newPath);
  }
}

class VideoCompressResult<T> {
  File? file;
  final ReturnType returnType;

  VideoCompressResult({
    this.file,
    required this.returnType
  });
}

enum ReturnType {
  success,

  /// Битрейт видео уже был оень низкий
  bitrate_is_low,

  metada_error,

  internal_error,

  cancelled
}