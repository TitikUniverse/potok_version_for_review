class ApiConstants {
  static const String baseUrl = "https://potokgo.online/";
  // static const String baseUrl = "http://localhost:5026/";

  static const String messengerBaseUrl = "https://potokgo.online/";
  // static const String messengerBaseUrl = "http://localhost:5005/";
  
  static const String microserviceApiKeyHeader = "ApiKey";
  static const String microserviceApiKey = "db70e554-5818-43b7-9207-db4083a1d71e";

  // auth
  static const String register = 'api/users/register';
  static const String startNewSession = 'api/users/startnewsession';
  static const String authenticate = 'api/users/authenticate';
  static const String doesUserExist = 'api/users/doesuserexist';

  // user
  static const String getUserByNickname = 'api/Users/GetByNickname';

  // user content
  static const String getUserPosts = 'api/UserMultimediaPost/GetProfilePosts'; // require path params
  static const String removeFromSavedPosts = 'api/UserSavedPosts/RemoveFromSavedPosts';
  static const String addToSavedPosts = 'api/UserSavedPosts/AddToSavedPosts';
  static const String dddPostLike = 'api/UserMultimediaPost/AddPostLike'; // require path params
  static const String deletePostLike = 'api/UserMultimediaPost/DeletePostLike'; // require path params
  static const String addPostView = 'api/UserPostView/Add';
  static const String getPostComment = 'api/UserMultimediaPost/GetPostComment'; // require path params
  static const String getUsersWhoLikedPost = 'api/UserMultimediaPost/GetUsersWhoLikedPost'; // require path params
  static const String addPostComment = 'api/UserMultimediaPost/AddPostComment';
  static const String AWSFileUpload = 'api/AWSFileUpload';
  static const String addNewMultimediaPost = 'api/UserMultimediaPost/addnewmultimediapost';
  static const String deletePost = 'api/UserMultimediaPost/Delete'; // require path params

  // friends
  static const String checkFriendsStatus = 'api/UserFriendsAndContacts/CheckStatus';

  // friend invations
  static const String getSubscriberAmount = 'api/FriendInvitations/GetSubscriberAmount'; // require path params
  static const String getSubscriptionAmount = 'api/FriendInvitations/GetSubscriptionAmount'; // require path params
}