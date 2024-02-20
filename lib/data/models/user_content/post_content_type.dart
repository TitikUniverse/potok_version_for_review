enum PostContentType {
  undefined,
  singleImage,
  singleVideo,
  singleText,
  imageAndText,
  videoAndText,
  voice,
  videoMessage,
}

extension PostContentTypeExtension on PostContentType {
  String asString() {
    switch (this) {
      case PostContentType.singleImage:
        return 'single-images';
      case PostContentType.singleVideo:
        return 'single-video';
      case PostContentType.singleText:
        return 'single-text';
      case PostContentType.imageAndText:
        return 'image-and-text';
      case PostContentType.videoAndText:
        return 'video-and-text';
      case PostContentType.videoMessage:
        return 'video-message';
      case PostContentType.voice:
        return 'voice';
      default:
        return 'undefined';
    }
  }
}

PostContentType postContentTypeFromJson(String? json) {
    if (json == null) return PostContentType.undefined;
    switch (json) {
      case 'single-images':
        return PostContentType.singleImage;
      case 'single-video':
        return PostContentType.singleVideo;
      case 'single-text':
        return PostContentType.singleText;
      case 'image-and-text':
        return PostContentType.imageAndText;
      case 'video-and-text':
        return PostContentType.videoAndText;
      case 'video-message':
        return PostContentType.videoMessage;
      case 'voice':
        return PostContentType.voice;
      default:
        return PostContentType.undefined;
    }
}