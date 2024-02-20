
import '../../data/models/user_content/user_multimedia_post_model.dart';
import '../../data/repositories/user_content/repository/post_type.dart';

class PostParameters {
  final UserMultimediaPostModel post;
  final PostType postType;
  final int selectedImageIndex;

  PostParameters({required this.post, required this.postType, required this.selectedImageIndex});

  Map<String, dynamic> toJson() => {
    "post": post.toJson(),
    "postType": postType.name,
    "selectedImageIndex": selectedImageIndex,
  };
}