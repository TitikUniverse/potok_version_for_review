part of 'user_content_remote_data_source.dart';

class UserContentRemoteDataSourceImpl implements UserContentRemoteDataSource {
  final _apiService = Get.find<ApiService>();

  @override
  Future<BaseResponse<List<UserMultimediaPostModel>, ApiError>> getUserPosts({required int authorId, required int count, int? skipCount, bool lunaMode = false}) async {
    skipCount ??= 0;
    try {
      var response = await _apiService.get('${ApiConstants.getUserPosts}/$authorId/$count/$skipCount/$lunaMode');
      if (response.statusCode == HttpStatus.ok && response.data != null) {
        var userPostsResponse = UserMultimediaPostModel.listMultimediaPostFromJson(response.data);
        return BaseResponse<List<UserMultimediaPostModel>, ApiError>.success(statusCode: response.statusCode!, data: userPostsResponse);
      } else if (response.data is Map && response.data['error'] != null) {
        var error = ApiError.fromMap(response.data);
        return BaseResponse<List<UserMultimediaPostModel>, ApiError>.error(statusCode: response.statusCode, error: error);
      } else if (response.data is String && response.data != null) {
        return BaseResponse<List<UserMultimediaPostModel>, ApiError>.error(statusCode: response.statusCode, error: ApiError(error: Error(errorMessage: response.data)));
      } else {
        return BaseResponse<List<UserMultimediaPostModel>, ApiError>.error(statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      return BaseResponse<List<UserMultimediaPostModel>, ApiError>.error(statusCode: e.response?.statusCode, error: ApiError(error: Error(errorMessage: e.message)));
    }
  }
  
  @override
  Future<BaseResponse<dynamic, ApiError>> removePostFromSaved({required int postId}) async {
    try {
      var response = await _apiService.patch(ApiConstants.removeFromSavedPosts, data: postId);
      if (response.statusCode == HttpStatus.ok && response.data != null) {
        return BaseResponse<String, ApiError>.success(statusCode: response.statusCode!, data: response.data);
      } else if (response.data is Map && response.data['error'] != null) {
        var error = ApiError.fromMap(response.data);
        return BaseResponse<String, ApiError>.error(statusCode: response.statusCode, error: error);
      } else if (response.data is String && response.data != null) {
        return BaseResponse<String, ApiError>.error(statusCode: response.statusCode, error: ApiError(error: Error(errorMessage: response.data)));
      } else {
        return BaseResponse<String, ApiError>.error(statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      return BaseResponse<String, ApiError>.error(statusCode: e.response?.statusCode, error: ApiError(error: Error(errorMessage: e.message)));
    }
  }
  
  @override
  Future<BaseResponse<dynamic, ApiError>> addPostToSaved({required int postId}) async {
    try {
      var response = await _apiService.patch(ApiConstants.addToSavedPosts, data: postId);
      if (response.statusCode == HttpStatus.ok && response.data != null) {
        return BaseResponse<String, ApiError>.success(statusCode: response.statusCode!, data: response.data);
      } else if (response.data is Map && response.data['error'] != null) {
        var error = ApiError.fromMap(response.data);
        return BaseResponse<String, ApiError>.error(statusCode: response.statusCode, error: error);
      } else if (response.data is String && response.data != null) {
        return BaseResponse<String, ApiError>.error(statusCode: response.statusCode, error: ApiError(error: Error(errorMessage: response.data)));
      } else {
        return BaseResponse<String, ApiError>.error(statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      return BaseResponse<String, ApiError>.error(statusCode: e.response?.statusCode, error: ApiError(error: Error(errorMessage: e.message)));
    }
  }

  @override
  Future<BaseResponse<int, ApiError>> deletePostLike({required int postId, required int userId}) async {
    try {
      var response = await _apiService.patch('${ApiConstants.deletePostLike}/$postId/$userId');
      if (response.statusCode == HttpStatus.ok && response.data != null) {
        return BaseResponse<int, ApiError>.success(statusCode: response.statusCode!, data: response.data);
      } else if (response.data is Map && response.data['error'] != null) {
        var error = ApiError.fromMap(response.data);
        return BaseResponse<int, ApiError>.error(statusCode: response.statusCode, error: error);
      } else if (response.data is String && response.data != null) {
        return BaseResponse<int, ApiError>.error(statusCode: response.statusCode, error: ApiError(error: Error(errorMessage: response.data)));
      } else {
        return BaseResponse<int, ApiError>.error(statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      return BaseResponse<int, ApiError>.error(statusCode: e.response?.statusCode, error: ApiError(error: Error(errorMessage: e.message)));
    }
  }
  
  @override
  Future<BaseResponse<int, ApiError>> addPostLike({required int postId, required int userId}) async {
    try {
      var response = await _apiService.patch('${ApiConstants.dddPostLike}/$postId/$userId', data: postId);
      if (response.statusCode == HttpStatus.ok && response.data != null) {
        return BaseResponse<int, ApiError>.success(statusCode: response.statusCode!, data: response.data);
      } else if (response.data is Map && response.data['error'] != null) {
        var error = ApiError.fromMap(response.data);
        return BaseResponse<int, ApiError>.error(statusCode: response.statusCode, error: error);
      } else if (response.data is String && response.data != null) {
        return BaseResponse<int, ApiError>.error(statusCode: response.statusCode, error: ApiError(error: Error(errorMessage: response.data)));
      } else {
        return BaseResponse<int, ApiError>.error(statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      return BaseResponse<int, ApiError>.error(statusCode: e.response?.statusCode, error: ApiError(error: Error(errorMessage: e.message)));
    }
  }
  
  @override
  Future<BaseResponse<List<UserPostCommentModel>, ApiError>> getPostComment({required int postId, required int count, required int? skipCount}) async {
    skipCount ??= 0;
    try {
      var response = await _apiService.get('${ApiConstants.getPostComment}/$postId/$count/$skipCount');
      if (response.statusCode == HttpStatus.ok && response.data != null) {
        var userCommentsResponse = UserPostCommentModel.listPostCommentFromJson(response.data!);
        return BaseResponse<List<UserPostCommentModel>, ApiError>.success(statusCode: response.statusCode!, data: userCommentsResponse);
      } else if (response.data is Map && response.data['error'] != null) {
        var error = ApiError.fromMap(response.data);
        return BaseResponse<List<UserPostCommentModel>, ApiError>.error(statusCode: response.statusCode, error: error);
      } else if (response.data is String && response.data != null) {
        return BaseResponse<List<UserPostCommentModel>, ApiError>.error(statusCode: response.statusCode, error: ApiError(error: Error(errorMessage: response.data)));
      } else {
        return BaseResponse<List<UserPostCommentModel>, ApiError>.error(statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      return BaseResponse<List<UserPostCommentModel>, ApiError>.error(statusCode: e.response?.statusCode, error: ApiError(error: Error(errorMessage: e.message)));
    }
  }
  
  @override
  Future<BaseResponse<List<UserInfoModel>, ApiError>> getUsersWhoLikedPost({required int postId, required int pageNumber}) async {
    try {
      var response = await _apiService.get('${ApiConstants.getUsersWhoLikedPost}/$postId/$pageNumber');
      if (response.statusCode == HttpStatus.ok && response.data != null) {
        var userResponse = UserInfoModel.fromJsonList(response.data);
        return BaseResponse<List<UserInfoModel>, ApiError>.success(statusCode: response.statusCode!, data: userResponse);
      } else if (response.data is Map && response.data['error'] != null) {
        var error = ApiError.fromMap(response.data);
        return BaseResponse<List<UserInfoModel>, ApiError>.error(statusCode: response.statusCode, error: error);
      } else if (response.data is String && response.data != null) {
        return BaseResponse<List<UserInfoModel>, ApiError>.error(statusCode: response.statusCode, error: ApiError(error: Error(errorMessage: response.data)));
      } else {
        return BaseResponse<List<UserInfoModel>, ApiError>.error(statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      return BaseResponse<List<UserInfoModel>, ApiError>.error(statusCode: e.response?.statusCode, error: ApiError(error: Error(errorMessage: e.message)));
    }
  }
  
  @override
  Future<BaseResponse<dynamic, ApiError>> addNewPostComment({required int postId, required int userWhoSentComment, required String commentText}) async {
    try {
      var response = await _apiService.patch(ApiConstants.addPostComment, data: {'postId': postId, 'userWhoSentComment': userWhoSentComment, 'text': commentText});
      if (response.statusCode == HttpStatus.created && response.data != null) {
        return BaseResponse<List<UserInfoModel>, ApiError>.success(statusCode: response.statusCode!, data: null);
      } else if (response.data is Map && response.data['error'] != null) {
        var error = ApiError.fromMap(response.data);
        return BaseResponse<List<UserInfoModel>, ApiError>.error(statusCode: response.statusCode, error: error);
      } else if (response.data is String && response.data != null) {
        return BaseResponse<List<UserInfoModel>, ApiError>.error(statusCode: response.statusCode, error: ApiError(error: Error(errorMessage: response.data)));
      } else {
        return BaseResponse<List<UserInfoModel>, ApiError>.error(statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      return BaseResponse<List<UserInfoModel>, ApiError>.error(statusCode: e.response?.statusCode, error: ApiError(error: Error(errorMessage: e.message)));
    }
  }
  
  @override
  Future<BaseResponse<AwsUploadResultModel, ApiError>> uploadFile(String filepath, String? filename, S3FileView fileView, {String? contentType}) async {
    late String fileViewString;

    switch (fileView) {
      case S3FileView.avatarimage:
        fileViewString = 'avatar-image';
        break;
      case S3FileView.profilepostimage:
        fileViewString = 'profile-post-image';
        break;
      case S3FileView.profilepostvideo:
        fileViewString = 'profile-post-video';
        break;
      case S3FileView.profilepostthumbnailvideo:
        fileViewString = 'profile-post-thumbnail-video';
        break;
      case S3FileView.storyimage:
        fileViewString = 'story-image';
        break;
      case S3FileView.storyvideo:
        fileViewString = 'story-video';
        break;
      case S3FileView.voice:
        fileViewString = 'voice';
        break;
      case S3FileView.chatimage:
        fileViewString = 'chat-image';
        break;
      case S3FileView.chatvideo:
        fileViewString = 'chat-video';
        break;
    }
    FormData formData = FormData.fromMap({
      'BucketName': 'ratemeapp',
      'File': MultipartFile.fromBytes(File(filepath).readAsBytesSync(), filename: filename, contentType: contentType != null ? MediaType.parse(contentType) : null)
      // 'File': await MultipartFile.fromFile(filepath, filename: filename)
    });

    try {
      var response = await _apiService.uploadMultipartForm('${ApiConstants.AWSFileUpload}/$fileViewString', data: formData);
      if (response.statusCode == HttpStatus.created && response.data != null) {
        var responseData = AwsUploadResultModel.fromJson(response.data);
        return BaseResponse<AwsUploadResultModel, ApiError>.success(statusCode: response.statusCode!, data: responseData);
      } else if (response.data is Map && response.data['error'] != null) {
        var error = ApiError.fromMap(response.data);
        return BaseResponse<AwsUploadResultModel, ApiError>.error(statusCode: response.statusCode, error: error);
      } else if (response.data is String && response.data != null) {
        return BaseResponse<AwsUploadResultModel, ApiError>.error(statusCode: response.statusCode, error: ApiError(error: Error(errorMessage: response.data)));
      } else {
        return BaseResponse<AwsUploadResultModel, ApiError>.error(statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      return BaseResponse<AwsUploadResultModel, ApiError>.error(statusCode: e.response?.statusCode, error: ApiError(error: Error(errorMessage: e.message)));
    }
  }
  
  @override
  Future<BaseResponse<UserMultimediaPostModel, ApiError>> addNewPost(List<String?> fileUrls, String fileView, PostContentType contentType, String? postDesription, bool isParticipateInBattle, bool isLunaPost, ObjectFit objectFit, PostFolderModel? folder) async {
    List<MultimediaPostContentRef>? multimediaPostContentRefs;
    String? description;
    if (postDesription != '') {
      description = postDesription;
    }
    else {
      description = null;
    }

    if (fileUrls.isNotEmpty) {
      multimediaPostContentRefs = [];
      for (int i = 0; i < fileUrls.length; i++) {
        MultimediaPostContentRef multimediaPostContentRef = MultimediaPostContentRef(
          contentUrl: fileUrls[i]!
        );
        multimediaPostContentRefs.add(multimediaPostContentRef);
      }
    }

    UserNewMultimediaPost userNewMultimediaPost = UserNewMultimediaPost(
      authorId: AuthenticationLocalDataSource().currentUser!.id,
      description: description,
      contentType: contentType,
      isParticipateInBattle: isParticipateInBattle,
      isLunaPost: isLunaPost,
      objectFit: objectFit.name,
      fileView: fileView,
      folderId: folder?.id,
      multimediaPostContentRefs: multimediaPostContentRefs
    );

    try {
      var response = await _apiService.patch(ApiConstants.addNewMultimediaPost, data: userNewMultimediaPost.toJson());
      if (response.statusCode == HttpStatus.created && response.data != null) {
        UserMultimediaPostModel userPost = UserMultimediaPostModel.fromJson(response.data!);
        return BaseResponse<UserMultimediaPostModel, ApiError>.success(statusCode: response.statusCode!, data: userPost);
      } else if (response.data is Map && response.data['error'] != null) {
        var error = ApiError.fromMap(response.data);
        return BaseResponse<UserMultimediaPostModel, ApiError>.error(statusCode: response.statusCode, error: error);
      } else if (response.data is String && response.data != null) {
        return BaseResponse<UserMultimediaPostModel, ApiError>.error(statusCode: response.statusCode, error: ApiError(error: Error(errorMessage: response.data)));
      } else {
        return BaseResponse<UserMultimediaPostModel, ApiError>.error(statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      return BaseResponse<UserMultimediaPostModel, ApiError>.error(statusCode: e.response?.statusCode, error: ApiError(error: Error(errorMessage: e.message)));
    }
  }
  
  @override
  Future<BaseResponse<dynamic, ApiError>> deletePost({required int postId}) async {
    try {
      var response = await _apiService.delete('${ApiConstants.deletePost}/$postId');
      if (response.statusCode == HttpStatus.ok && response.data != null) {
        return BaseResponse<Object, ApiError>.success(statusCode: response.statusCode!, data: null);
      } else if (response.data is Map && response.data['error'] != null) {
        var error = ApiError.fromMap(response.data);
        return BaseResponse<Object, ApiError>.error(statusCode: response.statusCode, error: error);
      } else if (response.data is String && response.data != null) {
        return BaseResponse<Object, ApiError>.error(statusCode: response.statusCode, error: ApiError(error: Error(errorMessage: response.data)));
      } else {
        return BaseResponse<Object, ApiError>.error(statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      return BaseResponse<Object, ApiError>.error(statusCode: e.response?.statusCode, error: ApiError(error: Error(errorMessage: e.message)));
    }
  }
}