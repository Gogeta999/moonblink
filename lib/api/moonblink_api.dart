class Api {
  // // BASE URL
  static const String BASE = "https://moonblinkuniverse.com/";
  // static const String BASE = "http://128.199.254.89/";

  /// Story for normal user
  static const String STORY = 'moonblink/api/v1/social/stories';

  /// Home Data [type 1 is partner type]
  static const String HOME =
      "moonblink/api/v1/social/user?limit=5&type=1&page=";

  /// [Simple Tasks Addresses]for user to get and post for simple tasks
  static const String SimpleRequestApi = "moonblink/api/v1/user/";

  /// Partner detail page for normal user to check and book
  /// Post to give reaction link is adding $userIdNum after user/ and then add /react;
  static const String PARTNERDETAIL = "moonblink/api/v1/social/user/";

  ///[partner's ownprofile page api]
  static const String PartnerOwnProfile = "moonblink/api/v1/user/";
  // register
  static const String REGISTER = "moonblink/api/v1/register";

  // Register as Partner
  static const String RegisterAsPartner = "moonblink/api/v1/user/";

  // Verify as Partner
  static const String VerifyAsPartner = "moonblink/api/v1/user/";

  // Get otp again
  static const String GetOtpCode = "moonblink/api/v1/user/";
  // login
  static const String LOGIN = 'moonblink/api/v1/login';

  // logout
  static const String LOGOUT = "moonblink/api/v1/logout";

  // User
  static const String USER = "moonblink/api/v1/user/16";

  /// Post story by partner user
  /// [add userid+ /story]
  static const String POSTSTORY = 'moonblink/api/v1/user/';

  //SetProfile
  static const String SetProfile = "moonblink/api/v1/user/";

  ///Booking
  static const String Booking = "moonblink/api/v1/social/user/";

  //Partner Status
  static const String SetStatus = "moonblink/api/v1/user/";

  //Conversation List
  static const String ConversationList =
      "moonblink/api/v1/social/user/conversations";

  //Messages
  static const String Messages = "moonblink/api/v1/social/user/";
}
