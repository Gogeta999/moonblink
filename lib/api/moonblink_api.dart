class Api {
  // // BASE URL
  static const String BASE = "https://moonblinkuniverse.com/";
  //Dev Server Address in IP
  static const String DEV = "http://157.230.35.18/";
  // Production Address in IP
  //static const String BASE = "https://128.199.254.89/";

  /// Story for normal user
  static const String STORY = 'moonblink/api/v1/social/stories';

  /// Drop specific story
  static const String DropStory =
      'moonblink/api/v1/user/'; //example = moonblink/api/v1/user/10/story/28

  /// Home Data [type 1 is partner type]
  static const String HOME = "moonblink/api/v1/social/user";

  /// [Simple Tasks Addresses]for user to get and post for simple tasks
  static const String SimpleRequestApi = "moonblink/api/v1/user/";

  /// [Show Ad or not]
  static const String ShowAds = "moonblink/api/v1/social/ads";

  /// Partner detail page for normal user to check and book
  /// Post to give reaction link is adding $userIdNum after user/ and then add /react;
  static const String SocialRequest = "moonblink/api/v1/social/user/";

  ///[partner's ownprofile page api]
  static const String PartnerOwnProfile = "moonblink/api/v1/user/";

  //user wallet
  static const String UserWallet = 'moonblink/api/v1/user/';

  //top up
  static const String TopUp =
      '/moonblink/api/v1/user/'; //full endpoint = '/moonblink/api/v1/user/10/coin/topup'

  //ad reward
  static const String AdReward =
      'moonblink/api/v1/user/'; // eg - moonblink/api/v1/user/{user_id}/ads/view

  // register
  static const String REGISTER = "moonblink/api/v1/register";

  // Register as Partner
  static const String RegisterAsPartner = "moonblink/api/v1/user/";

  // Verify as Partner
  static const String VerifyAsPartner = "moonblink/api/v1/user/";

  // Get otp again
  static const String GetOtpCode = "moonblink/api/v1/user/";

  //get blocked List
  static const String getUserBlockedList =
      'moonblink/api/v1/user/'; //moonblink/api/v1/user/{user_id}/block/list

  // Block or unblock user
  static const String BlockOrUnblock =
      'moonblink/api/v1/user/'; //moonblink/api/v1/user/{user_id}/block

  // Notification List
  static const String UserNotifications = 'moonblink/api/v1/user/'; //eg - /moonblink/api/v1/user/5/notification

  //Notification read/unread
  static const String UserNotificationRead = 'moonblink/api/v1/user/'; //eg - moonblink/api/v1/user/{user_id}/notification/{notification_id}

  // report user
  static const String ReportUser =
      'moonblink/api/v1/social/user/'; //moonblink/api/v1/user/{partner_user_id}/report

  // login
  static const String LOGIN = 'moonblink/api/v1/login';

  // logout
  static const String LOGOUT = "moonblink/api/v1/logout";

  /// Post story by partner user
  /// [add userid+ /story]
  static const String POSTSTORY = 'moonblink/api/v1/user/';

  //SetProfile
  static const String SetProfile = "moonblink/api/v1/user/";

  //Game List
  static const String GameList = 'moonblink/api/v1/social/game/price';

  //for choose_user_play_game_page
  static const String UserPlayGame =
      '/moonblink/api/v1/user/'; //eg-/moonblink/api/v1/user/5/profile/game

  ///update game profile
  static const String UpdateGameProfile =
      '/moonblink/api/v1/user/'; //eg - /moonblink/api/v1/user/1/profile/game

  ///delete game profile
  static const String DeleteGameProfile =
      'moonblink/api/v1/user/'; //eg - /moonblink/api/v1/user/1/profile/game/{game_id}
  ///Booking
  static const String Booking = "moonblink/api/v1/social/user/";

  static const String BookingAccept = "/moonblink/api/v1/user/";

  //Partner Status
  static const String SetStatus = "moonblink/api/v1/user/";

  //Conversation List
  static const String ConversationList =
      "moonblink/api/v1/social/user/conversations";

  //Messages
  static const String Messages = "moonblink/api/v1/social/user/";

  //Calling
  static const String Calling =
      "moonblink/api/v1/social/user/conversations/call";

  //set status
  static const String Endbooking = "moonblink/api/v1/user/";

  //Rating
  static const String Rategame = "moonblink/api/v1/social/user/";

  //get user history
  static const String UserHistory =
      'moonblink/api/v1/social/user/'; //eg - moonblink/api/v1/social/user/4/transaction

  //get user transaction
  static const String UserTransaction =
      'moonblink/api/v1/user/'; //eg - moonblink/api/v1/user/4/transaction

  //ForgetPassword
  static const String ForgetPassword = "moonblink/api/v1/password/forget";

  //Reset Password
  static const String ResetPassword = "moonblink/api/v1/password/reset";

  //UserRating
  static const String UserRating = 'moonblink/api/v1/social/rating';
}
