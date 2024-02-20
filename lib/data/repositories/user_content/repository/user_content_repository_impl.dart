part of 'user_content_repository.dart';

class UserContentRepositoryImpl implements UserContentRepository {
  final UserContentRemoteDataSource _userContentRemoteDataSource = UserContentRemoteDataSource();

  @override
  Future<BaseResponse<List<UserMultimediaPostModel>, ApiError>> getUserPosts({required int authorId, required int count, int? skipCount, bool lunaMode = false}) async =>
      _userContentRemoteDataSource.getUserPosts(authorId: authorId, count: count, skipCount: skipCount, lunaMode: lunaMode);
      
  @override
  Future<BaseResponse<dynamic, ApiError>> removePostFromSaved({required int postId}) async =>
      _userContentRemoteDataSource.removePostFromSaved(postId: postId);
      
  @override
  Future<BaseResponse<dynamic, ApiError>> addPostToSaved({required int postId}) async =>
      _userContentRemoteDataSource.addPostToSaved(postId: postId);
      
  @override
  Future<BaseResponse<int, ApiError>> addPostLike({required int postId, required int userId}) async =>
      _userContentRemoteDataSource.addPostLike(postId: postId, userId: userId);

  @override
  Future<BaseResponse<int, ApiError>> deletePostLike({required int postId, required int userId}) async =>
      _userContentRemoteDataSource.deletePostLike(postId: postId, userId: userId);
  
  @override
  Future<BaseResponse<List<UserPostCommentModel>, ApiError>> getPostComment({required int postId, required int count, required int? skipCount}) async =>
      _userContentRemoteDataSource.getPostComment(postId: postId, count: count, skipCount: skipCount);
      
  @override
  Future<BaseResponse<List<UserInfoModel>, ApiError>> getUsersWhoLikedPost({required int postId, required int pageNumber}) async =>
      _userContentRemoteDataSource.getUsersWhoLikedPost(postId: postId, pageNumber: pageNumber);
      
  @override
  Future<BaseResponse<dynamic, ApiError>> addNewPostComment({required int postId, required int userWhoSentComment, required String commentText}) async =>
      _userContentRemoteDataSource.addNewPostComment(postId: postId, userWhoSentComment: userWhoSentComment, commentText: commentText);
  
  @override
  Future<BaseResponse<AwsUploadResultModel, ApiError>> uploadFile(String filepath, String? filename, S3FileView fileView, {String? contentType}) async =>
      _userContentRemoteDataSource.uploadFile(filepath, filename, fileView, contentType: contentType);
      
  @override
  Future<BaseResponse<UserMultimediaPostModel, ApiError>> addNewPost(List<String?> fileUrls, String fileView, PostContentType contentType, String? postDesription, bool isParticipateInBattle, bool isLunaPost, ObjectFit objectFit, PostFolderModel? folder) async =>
      _userContentRemoteDataSource.addNewPost(fileUrls, fileView, contentType, postDesription, isParticipateInBattle, isLunaPost, objectFit, folder);
      
  @override
  Future<BaseResponse<dynamic, ApiError>> deletePost({required int postId}) async =>
      _userContentRemoteDataSource.deletePost(postId: postId);
}