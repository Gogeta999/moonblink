import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/api/moonblink_api.dart';
import 'package:moonblink/api/moonblink_dio.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/BoostGame.dart';
import 'package:moonblink/models/UserBoostingGamePrice.dart';
import 'package:moonblink/models/adModel.dart';
import 'package:moonblink/models/blocked_user.dart';
import 'package:moonblink/models/booking_partner_game_list.dart';
import 'package:moonblink/models/chat_models/last_message.dart';
import 'package:moonblink/models/contact.dart';
import 'package:moonblink/models/follower.dart';
import 'package:moonblink/models/message.dart';
import 'package:moonblink/models/notification_models/user_new_notification.dart';
import 'package:moonblink/models/ownprofile.dart';
import 'package:moonblink/models/partner.dart';
import 'package:moonblink/models/post.dart';
import 'package:moonblink/models/story.dart';
import 'package:moonblink/models/transcationModel.dart';
import 'package:moonblink/models/user.dart';
import 'package:moonblink/models/user_history.dart';
import 'package:moonblink/models/notification_models/user_booking_notification.dart';
import 'package:moonblink/models/notification_models/user_message_notification.dart';
import 'package:moonblink/models/user_play_game.dart';
import 'package:moonblink/models/user_rating.dart';
import 'package:moonblink/models/user_transaction.dart';
import 'package:moonblink/models/wallet.dart';
import 'package:moonblink/services/moongo_database.dart';
import 'package:moonblink/utils/constants.dart';
import 'package:moonblink/utils/platform_utils.dart';
import 'package:moonblink/view_model/login_model.dart';

class MoonBlinkRepository {
  static Future showAd() async {
    var response = await DioUtils().get(Api.ShowAds);
    return SplashAds.fromJson(response.data);
  }
  // home page's post data

  static Future fetchPosts({int pageNum, int type, String gender}) async {
    var response = await DioUtils().get(Api.HOME, queryParameters: {
      'limit': kHomePostLimit,
      'type': type,
      'page': pageNum,
      'gender': gender
    });
    List<Post> posts =
        response.data['data'].map<Post>((item) => Post.fromJson(item)).toList();
    MoonGoDB().insertPosts(posts);
    return posts;
  }

  //Call other user
  static Future call(String channel, int id) async {
    var response = await DioUtils().post(Api.Calling, queryParameters: {
      'channel': channel,
      'user_id': id,
    });
    return response.data;
  }

  //End Booking
  static Future endbooking(int id, int bookingid, int status) async {
    var response = await DioUtils()
        .post(Api.Endbooking + "$id/booking/$bookingid?status=$status");
    return response.data;
  }

  // get Messages
  static Future message(int id) async {
    var response =
        await DioUtils().get(Api.Messages + '$id/messages?limit=40&page=1');
    return response.data['data']
        .map<Lastmsg>((item) => Lastmsg.fromMap(item))
        .toList();
  }

  // get last messages
  static Future<List<LastMessage>> getLastMessages(
      {int id, int limit, int page}) async {
    var response =
        await DioUtils().get(Api.Messages + '$id/messages', queryParameters: {
      'limit': limit,
      'page': page,
    });
    return response.data['data']
        .map<LastMessage>((e) => LastMessage.fromJson(e))
        .toList();
  }

  //Rate game
  static Future rategame(id, bookingid, stars, comment) async {
    var response = await DioUtils().post(Api.Rategame + "$id/booking/rating",
        queryParameters: {
          "booking_id": bookingid,
          "star": stars,
          "comment": comment
        });
    return response.data;
  }

  // Homepage's story data
  static Future fetchStory() async {
    // var usertoken = StorageManager.sharedPreferences.getString(token);
    var response = await DioUtils().get(Api.STORY);
    return response.data['data']
        .map<Story>((item) => Story.fromJson(item))
        .toList();
  }

  static Future dropStory(int storyId) async {
    var userId = StorageManager.sharedPreferences.getInt(mUserId);
    var response =
        await DioUtils().delete(Api.DropStory + '$userId/story/$storyId');
    return response.data['message'];
  }

  /// [Get following list]Contact for get following list for current user
  static Future getFollowingContact() async {
    var userId = StorageManager.sharedPreferences.getInt(mUserId);
    // var userToken = StorageManager.sharedPreferences.getString(token);
    var response =
        await DioUtils().get(Api.SimpleRequestApi + '$userId/following');
    return response.data
        .map<Contact>((item) => Contact.fromJson(item))
        .toList();
  }

  ///[Get follower list]
  static Future getFollowerList(int userId) async {
    var response = await DioUtils().get(Api.Follower + '$userId/follow');
    return response.data
        .map<Follower>((item) => Follower.fromJson(item))
        .toList();
  }

  /// [Normal user to fetch partner user page data]
  static Future fetchPartner(int partnerId) async {
    var response = await DioUtils().get(Api.SocialRequest + '$partnerId');
    return PartnerUser.fromJson(response.data);
  }

  /// [partner user to get their ownprofile page to fetch data and get information]
  static Future fetchOwnProfile() async {
    var partnerId = StorageManager.sharedPreferences.getInt(mUserId);
    var response = await DioUtils().get(Api.PartnerOwnProfile + '$partnerId');
    return OwnProfile.fromJson(response.data);
  }

  /// [fetch search result] currently only support in name search
  static Future fetchSearchResults({key, int pageNum}) async {
    var userId = StorageManager.sharedPreferences.getInt(mUserId);
    var response = await DioUtils()
        .get(Api.SimpleRequestApi + '$userId/search', queryParameters: {
      'name': key,
      'page': pageNum,
    });
    return response.data['data']
        .map<User>((item) => User.fromJsonMap(item))
        .toList();
  }

  //React at homepage
  static Future react(int partnerId, int reactType) async {
    var response = await DioUtils()
        .post(Api.SocialRequest + '$partnerId/react', queryParameters: {
      'react': reactType,
    });
    return response;
  }

  //Transcation List
  static Future getTranscation() async {
    var userId = StorageManager.sharedPreferences.getInt(mUserId);
    var response = await DioUtils()
        .get(Api.SimpleRequestApi + '$userId/transcation', queryParameters: {
      'limit': 20,
    });
    return Transcation.fromJson(response.data);
  }

  ///user wallet
  static Future<Wallet> getUserWallet() async {
    var userId = StorageManager.sharedPreferences.getInt(mUserId);
    var response = await DioUtils().get(Api.UserWallet + '$userId');
    return Wallet.fromJson(response.data['wallet']);
  }

  ///user history
  static Future getUserHistory({int partnerId, int limit, int page}) async {
    var response = await DioUtils()
        .get(Api.UserHistory + '$partnerId/transaction', queryParameters: {
      'limit': limit,
      'page': page,
    });
    return UserHistory.fromJson(response.data);
  }

  ///user transaction list
  static Future getUserTransaction({int limit, int page}) async {
    var userId = StorageManager.sharedPreferences.getInt(mUserId);
    var response = await DioUtils()
        .get(Api.UserTransaction + '$userId/transaction', queryParameters: {
      'limit': limit,
      'page': page,
    });
    return UserTransaction.fromJson(response.data);
  }

  /// need to remove from database
  static Future blockOrUnblock(int blockUserId, int status) async {
    var userId = StorageManager.sharedPreferences.getInt(mUserId);
    FormData formData =
        FormData.fromMap({'block_user_id': blockUserId, 'status': status});
    var response = await DioUtils()
        .postwithData(Api.BlockOrUnblock + '$userId/block', data: formData);
    return response;
  }

  /// report user
  static Future reportUser(int partnerId) async {
    var response = await DioUtils().post(Api.ReportUser + '$partnerId/report');
    return response;
  }

  ///get blocked list
  static Future getUserBlockedList({int limit, int page}) async {
    var userId = StorageManager.sharedPreferences.getInt(mUserId);
    var response = await DioUtils().get(
        Api.getUserBlockedList + '$userId/block/list',
        queryParameters: {'limit': limit, 'page': page});
    return BlockedUsersList.fromJson(response.data);
  }

  /// [login api]
  //login with email & password
  static Future login(String mail, String password, String fcmToken) async {
    FormData formData = FormData.fromMap(
        {'mail': mail, 'password': password, 'fcm_token': fcmToken});
    var response = await DioUtils().postwithData(Api.LOGIN, data: formData);
    return User.fromJsonMap(response.data);
  }

  static Future loginWithFacebook(String token, String fcmToken) async {
    FormData formData = FormData.fromMap(
        {'access_token': token, 'type': 'facebook', 'fcm_token': fcmToken});
    var response = await DioUtils().postwithData(Api.LOGIN, data: formData);
    return User.fromJsonMap(response.data);
  }

  static Future loginWithGoogle(String token, String fcmToken) async {
    FormData formData = FormData.fromMap(
        {'access_token': token, 'type': 'google', 'fcm_token': fcmToken});
    var response = await DioUtils().postwithData(Api.LOGIN, data: formData);
    // print('Response Data: ${response.data}');
    return User.fromJsonMap(response.data);
  }

  ///token means IdentityToken
  static Future loginWithApple(String token, String fcmToken) async {
    FormData formData = FormData.fromMap(
        {'access_token': token, 'type': 'apple', 'fcm_token': fcmToken});
    var response = await DioUtils().postwithData(Api.LOGIN, data: formData);
    return User.fromJsonMap(response.data);
  }

  /// [lout api]
  static logout() async {
    // var usertoken = StorageManager.sharedPreferences.getString(token);
    await DioUtils().get(Api.LOGOUT);
  }

  //Registerwith dio_moonblink another method
  static Future register(String mail, String name, String password) async {
    FormData formData = FormData.fromMap({
      'mail': mail,
      'name': name,
      // 'last_name': lastname,
      'password': password,
    });
    var response = await DioUtils().postwithData(Api.REGISTER, data: formData);
    // print(response);
    return response.data;
  }

  //Register as Partner
  static Future registAsPartner() async {
    var userid = StorageManager.sharedPreferences.getInt(mUserId);
    var usertoken = StorageManager.sharedPreferences.getString(token);
    FormData formData =
        FormData.fromMap({'Authorization': 'Bearer' + usertoken.toString()});
    var response = await DioUtils().postwithData(
        Api.RegisterAsPartner + '$userid/register',
        data: formData);
    return response.data;
  }

  // Story
  static Future postStory(File story) async {
    var storyPath = story.path;
    var userid = StorageManager.sharedPreferences.getInt(mUserId);
    FormData formData = FormData.fromMap({
      'body': '',
      'media': await MultipartFile.fromFile(storyPath, filename: 'xxx.jpg')
    });
    var response = await DioUtils()
        .postwithData(Api.POSTSTORY + '$userid/story', data: formData);
    return response.data;
  }

  //Game List for booking
  static Future getGameList(int partnerId) async {
    var response = await DioUtils().get(Api.GameList, queryParameters: {
      'user_id': partnerId,
    });
    //return GameList.fromJson(response.data);
    return BookingPartnerGameList.fromJson(response.data);
  }

  //Game List for boosting
  static Future<List<UserBoostingGamePrice>> getBoostingGameList(
      int partnerId) async {
    final response =
        await DioUtils().get(Api.BoostingGameList + '$partnerId/boost');
    return response.data
        .map<UserBoostingGamePrice>((e) => UserBoostingGamePrice.fromJson(e))
        .toList();
  }

  //Delete Boosting Game Profile
  static Future deleteBoostingGameProfile(int gameId) async {
    final userId = StorageManager.sharedPreferences.getInt(mUserId);
    final response = await DioUtils().delete(
        Api.DeleteBoostingProfile + '$userId/game/$gameId/boost/profile');
    return response.data;
  }

  static Future setBoostingStatus(int boostingId, int status) async {
    final userId = StorageManager.sharedPreferences.getInt(mUserId);
    final response = await DioUtils().patch(
        Api.SetBoostingStatus + '$userId/boost/$boostingId',
        queryParameters: {'status': status});
    return response.data;
  }

  // User Play Game List
  static Future<UserPlayGameList> getUserPlayGameList() async {
    var userId = StorageManager.sharedPreferences.getInt(mUserId);
    var response =
        await DioUtils().get(Api.UserPlayGame + '$userId/profile/game');
    return UserPlayGameList.fromJson(response.data);
  }

  //update game profile
  static Future updateGameProfile(Map<String, dynamic> gameProfile) async {
    var userId = StorageManager.sharedPreferences.getInt(mUserId);
    FormData formData = FormData.fromMap(gameProfile);
    var response = await DioUtils().postwithData(
        Api.UpdateGameProfile + '$userId/profile/game',
        data: formData);
    return response.data;
  }

  //delete game profile
  static Future deleteGameProfile(int gameId) async {
    var userId = StorageManager.sharedPreferences.getInt(mUserId);
    var response = await DioUtils()
        .delete(Api.DeleteGameProfile + '$userId/profile/game/$gameId');
    return response.data;
  }

  //get user's new notifications
  static Future<UserNewNotificationResponse> getUserNewNotifications(
      int limit, int page) async {
    var userId = StorageManager.sharedPreferences.getInt(mUserId);
    var response = await DioUtils().get(
        Api.UserNotifications + '$userId/notification',
        queryParameters: {'limit': limit, 'page': page});
    return UserNewNotificationResponse.fromJson(response.data);
  }

  //get user's booking notifications
  static Future<UserBookingNotificationResponse> getUserBookingNotifications(
      int limit, int page) async {
    var userId = StorageManager.sharedPreferences.getInt(mUserId);
    var response = await DioUtils()
        .get(Api.UserNotifications + '$userId/notification', queryParameters: {
      'limit': limit,
      'page': page,
      'fcm_type': 'booking',
      'is_archive': 1
    });
    return UserBookingNotificationResponse.fromJson(response.data);
  }

  //get user's message notifications
  static Future<UserMessageNotificationResponse> getUserMessageNotifications(
      int limit, int page) async {
    var userId = StorageManager.sharedPreferences.getInt(mUserId);
    var response = await DioUtils()
        .get(Api.UserNotifications + '$userId/notification', queryParameters: {
      'limit': limit,
      'page': page,
      'fcm_type': 'message',
      'is_archive': 1
    });
    return UserMessageNotificationResponse.fromJson(response.data);
  }

  static markAllNotificationReadState() async {
    int userId = StorageManager.sharedPreferences.getInt(mUserId);
    var response = await DioUtils()
        .patch(Api.UserNotificationRead + '$userId/notification/read');
    return response;
  }

  //change message notification to read state
  static Future<UserMessageNotificationData>
      changeUserMessageNotificationReadState(int notificationId,
          {int isArchive, int isRead}) async {
    var userId = StorageManager.sharedPreferences.getInt(mUserId);
    var response;
    if (isRead != null && isArchive == null) {
      response = await DioUtils().patch(
          Api.UserNotificationRead + '$userId/notification/$notificationId',
          queryParameters: {'is_read': isRead});
    } else if (isArchive != null && isRead == null) {
      response = await DioUtils().patch(
          Api.UserNotificationRead + '$userId/notification/$notificationId',
          queryParameters: {'is_archive': isArchive});
    } else {
      return null;
    }
    return UserMessageNotificationData.fromJson(response.data);
  }

  //change booking notification to read state
  static Future<UserBookingNotificationData>
      changeUserBookingNotificationReadState(int notificationId,
          {int isArchive, int isRead}) async {
    var userId = StorageManager.sharedPreferences.getInt(mUserId);
    var response;
    if (isRead != null && isArchive == null) {
      response = await DioUtils().patch(
          Api.UserNotificationRead + '$userId/notification/$notificationId',
          queryParameters: {'is_read': isRead});
    } else if (isArchive != null && isRead == null) {
      response = await DioUtils().patch(
          Api.UserNotificationRead + '$userId/notification/$notificationId',
          queryParameters: {'is_archive': isArchive});
    } else {
      return null;
    }
    return UserBookingNotificationData.fromJson(response.data);
  }

  // Get Boost game
  static Future<List<BoostGame>> getBoostGame(int id) async {
    var userId = StorageManager.sharedPreferences.getInt(mUserId);
    final response = await DioUtils()
        .get(Api.BoostGameList + '$userId/game/$id/boost/profile');
    return response.data.map<BoostGame>((e) => BoostGame.fromJson(e)).toList();
  }

  //Set Boost Game
  static Future setBoostGameProfile(
      List<Map<String, dynamic>> json, int id) async {
    var userId = StorageManager.sharedPreferences.getInt(mUserId);
    final data = {'boost_profile': json};
    final response = await DioUtils().postwithData(
        Api.BoostGameList + '$userId/game/$id/boost/profile',
        data: data);
    return response.data;
  }

  // Booking
  static Future booking(int partnerId, int gameTypeId, int count) async {
    FormData formData = FormData.fromMap({
      'game_type_id': gameTypeId,
      'count': count,
    });
    var response = await DioUtils()
        .postwithData(Api.Booking + '$partnerId/booking', data: formData);
    return response.data;
  }

  static Future bookingAcceptOrDecline(
      int userId, int bookingId, int status) async {
    var response = await DioUtils()
        .post(Api.BookingAccept + '$userId/booking/$bookingId/?status=$status');
    return response.data;
  }

  // top up
  static Future topUp(String productId) async {
    var userId = StorageManager.sharedPreferences.getInt(mUserId);
    FormData formData = FormData.fromMap({'product_id': productId});
    var response = await DioUtils()
        .postwithData(Api.TopUp + '$userId/coin/topup', data: formData);
    return response.data;
  }

  //ad reward
  static Future adReward() async {
    var userId = StorageManager.sharedPreferences.getInt(mUserId);
    var response = await DioUtils().post(Api.AdReward + '$userId/ads/view');
    return response.data;
  }

  // Set Status
  static Future setstatus(int status) async {
    var userid = StorageManager.sharedPreferences.getInt(mUserId);
    var response = await DioUtils().post(
        Api.SetStatus + '$userid/booking/1/status',
        queryParameters: {'status': status});
    return response.data;
  }

  //change Status
  static Future changestatus(int status) async {
    var userid = StorageManager.sharedPreferences.getInt(mUserId);
    var response = await DioUtils().get(
      Api.SetStatus + '$userid/status?status=$status',
    );
    return response.data;
  }

  // Sign As Partner
  static Future signAsPartner(String phone) async {
    var userid = StorageManager.sharedPreferences.getInt(mUserId);
    var response = await DioUtils().postwithData(
        Api.VerifyAsPartner + '$userid/verify',
        data: FormData.fromMap({'phone': phone}));
    return User.fromJsonMap(response.data);
  }

// Sign As Type5 Partner
  static Future signAsType5Partner(String phone, int vipPlan) async {
    var userid = StorageManager.sharedPreferences.getInt(mUserId);
    var response = await DioUtils().postwithData(
        Api.VerifyAsPartner + '$userid/register/unverify',
        data: FormData.fromMap({'phone': phone, 'vip': vipPlan}));
    return response;
  }

  // Get OTP
  static Future getOtpCode(String mail) async {
    var userid = StorageManager.sharedPreferences.getInt(mUserId);
    var response = await DioUtils().get(Api.GetOtpCode + '$userid/send/otp',
        queryParameters: {'mail': mail});
    return response.data;
  }

  //nrc, email, gender, dob, phone, profile, address
  //Update userprofile data
  static Future setprofle(
      File cover,
      File profile,
      String nrc,
      String mail,
      String gender,
      String dob,
      String phone,
      String bios,
      String address) async {
    var coverPath = cover.path;
    var profilePath = profile.path;
    var userId = StorageManager.sharedPreferences.getInt(mUserId);
    // FormData formData = FormData.fromMap({

    // });

    var response = await DioUtils()
        .postwithData(Api.SetProfile + '$userId/profile', data: {
      'cover_image':
          await MultipartFile.fromFile(coverPath, filename: 'cover.jpg'),
      'profile_image':
          await MultipartFile.fromFile(profilePath, filename: 'profile.jpg'),
      'nrc': nrc,
      'mail': mail,
      'gender': gender,
      'dob': dob,
      'phone': phone,
      'bios': bios,
      'address': address
    });
    return User.fromJsonMap(response.data);
  }

  //Forget Password
  static Future forgetpassword(String mail) async {
    FormData formData = FormData.fromMap({'mail': mail});
    var response =
        await DioUtils().postwithData(Api.ForgetPassword, data: formData);
    return response.data;
  }

  //Reset Password
  static Future resetpassword(String mail, int otp, String password) async {
    FormData formData =
        FormData.fromMap({'mail': mail, 'otp': otp, 'password': password});
    var response =
        await DioUtils().postwithData(Api.ResetPassword, data: formData);
    return response.data;
  }

  //User Rating
  static Future<UserRatingList> userRating(
      int userId, int limit, int page) async {
    var response = await DioUtils().get(Api.UserRating,
        queryParameters: {'user_id': userId, 'limit': limit, 'page': page});
    return UserRatingList.fromJson(response.data['data']);
  }

  static Future requestBoosting(
      int partnerId,
      int gameId,
      String rankFrom,
      String upToRank,
      int estimateDay,
      int estimateHour,
      int estimateCost) async {
    final map = {
      'game_id': gameId,
      'rank_from': rankFrom,
      'up_to_rank': upToRank,
      'estimate_day': estimateDay,
      'estimate_hour': estimateHour,
      'estimate_cost': estimateCost
    };
    final formData = FormData.fromMap(map);
    final response = await DioUtils()
        .postwithData(Api.BoostingRequest + '$partnerId/boost', data: formData);
    return response.data;
  }

  static Future uploadPost(File media, int type, int status,
      {String body = ''}) async {
    final userId = StorageManager.sharedPreferences.getInt(mUserId);
    FormData formData;
    if (body == null || body.isEmpty) {
      formData = FormData.fromMap({
        'media': await MultipartFile.fromFile(media.path),
        'type': type,
        'status': status
      });
    } else {
      formData = FormData.fromMap({
        'body': body,
        'media': await MultipartFile.fromFile(media.path),
        'type': type,
        'status': status
      });
    }
    final response = await DioUtils()
        .postwithData(Api.UploadPost + '$userId/post', data: formData);
    return response.data;
  }
}
