import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:http_parser/http_parser.dart';

import '../../../../services/api/service/api.dart';
import '../../../../services/api/service/api_service.dart';
import '../../../models/api_error.dart';
import '../../../models/base_response.dart';
import '../../../models/user/user_info_model.dart';
import '../../../models/user_content/aws_upload_result_model.dart';
import '../../../models/user_content/comment_mode.dart';
import '../../../models/user_content/multimedia_post_content_ref_model.dart';
import '../../../models/user_content/new_post_model.dart';
import '../../../models/user_content/object_fit.dart';
import '../../../models/user_content/post_content_type.dart';
import '../../../models/user_content/post_folder_model.dart';
import '../../../models/user_content/s3_fileview.dart';
import '../../../models/user_content/user_multimedia_post_model.dart';
import '../../authentication/local/authentication_local_data_source.dart';

part 'user_content_remote_data_source_impl.dart';

abstract class UserContentRemoteDataSource {
  factory UserContentRemoteDataSource() = UserContentRemoteDataSourceImpl;

  Future<BaseResponse<List<UserMultimediaPostModel>, ApiError>> getUserPosts({required int authorId, required int count, int? skipCount, bool lunaMode = false});
  Future<BaseResponse<dynamic, ApiError>> deletePost({required int postId});

  Future<BaseResponse<dynamic, ApiError>> removePostFromSaved({required int postId});
  Future<BaseResponse<dynamic, ApiError>> addPostToSaved({required int postId});

  Future<BaseResponse<int, ApiError>> deletePostLike({required int postId, required int userId});
  Future<BaseResponse<int, ApiError>> addPostLike({required int postId, required int userId});

  Future<BaseResponse<List<UserPostCommentModel>, ApiError>> getPostComment({required int postId, required int count, required int? skipCount});
  Future<BaseResponse<List<UserInfoModel>, ApiError>> getUsersWhoLikedPost({required int postId, required int pageNumber});
  Future<BaseResponse<dynamic, ApiError>> addNewPostComment({required int postId, required int userWhoSentComment, required String commentText});

  Future<BaseResponse<AwsUploadResultModel, ApiError>> uploadFile(String filepath, String? filename, S3FileView fileView, {String? contentType});
  Future<BaseResponse<UserMultimediaPostModel, ApiError>> addNewPost(List<String?> fileUrls, String fileView, PostContentType contentType, String? postDesription, bool isParticipateInBattle, bool isLunaPost, ObjectFit objectFit, PostFolderModel? folder);
}