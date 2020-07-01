import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/api/moonblink_api.dart';
import 'package:moonblink/api/moonblink_dio.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/contact.dart';
import 'package:moonblink/models/message.dart';
import 'package:moonblink/models/partner.dart';
import 'package:moonblink/models/post.dart';
import 'package:moonblink/models/story.dart';
import 'package:moonblink/models/user.dart';
import 'package:moonblink/utils/platform_utils.dart';
import 'package:moonblink/view_model/login_model.dart';

class MoonBlinkRepository {

  // home page's post data
  
  static Future fetchPosts(int pageNum) async {
    // await Future.delayed(Duration(seconds: 1)); 
    var response = await DioUtils().get(Api.HOME + '$pageNum');
    return response.data['data'].map<Post>((item) => Post.fromMap(item))
      .toList();
  }
  // get Messages
  static Future message(int id) async{
    var usertoken = StorageManager.sharedPreferences.getString(token);
    var response = await  DioUtils().get(Api.Messages + '$id/messages?limit=20&page=1', queryParameters: {
      'Authorization': 'Bearer' + usertoken.toString()
    });
    return response.data['data'].map<Lastmsg>((item) => Lastmsg.fromMap(item)).toList();
  }
  // Homepage's story data
  static Future fetchStory() async {
    var usertoken = StorageManager.sharedPreferences.getString(token);
    var response = await DioUtils().get(Api.STORY, queryParameters: {
      'Authorization': 'Bearer' + usertoken.toString()
    });
    return response.data['data'].map<Story>((item) => Story.fromMap(item))
      .toList();
  }

  /// [Get following list]Contact for get following list for current user
  static Future getFollowingContact() async {
    var userId = StorageManager.sharedPreferences.getInt(mUserId);
    var userToken = StorageManager.sharedPreferences.getString(token);
    var response = await DioUtils().get(Api.SimpleRequestApi + '$userId/following', queryParameters: {
      'Authorization': 'Bearer' + userToken.toString()
    });
    return response.data.map<Contact>((item) => 
    Contact.fromJson(item)).toList();
  }

  /// [Normal user to fetch partner user page data]
  static Future fetchPartner(int partnerId) async {
    var response = await DioUtils().get(Api.PARTNERDETAIL + '$partnerId');
    return PartnerUser.fromJson(response.data);
  }

  /// [partner user to get their ownprofile page to fetch data and get information]
  static Future fetchOwnProfile() async {
    var partnerId = StorageManager.sharedPreferences.getInt(mUserId);
    var response = await DioUtils().get(Api.PartnerOwnProfile + '$partnerId');
    return PartnerUser.fromJson(response.data);
  }

  /// [fetch search result] currently only support in name search
  static Future fetchSearchResults({key}) async {
    var userId = StorageManager.sharedPreferences.getInt(mUserId);
    var response =
      await DioUtils().get(Api.SimpleRequestApi + '$userId/search', queryParameters: {
        'name': key,
      });
      print(response);
      return response.data['data']
            .map<User>((item) => User.fromJsonMap(item))
            .toList();
  }
  /// [login api]
  //login with email & password
  static Future login(String mail, String password) async{
    var response = await DioUtils().post(Api.LOGIN, queryParameters: {
      'mail': mail,
      'password': password,
    });
    return User.fromJsonMap(response.data);
  }

  static Future loginWithFacebook(String token) async {
    var response = await DioUtils().post(Api.LOGIN, queryParameters: {
      'access_token': token,
      'type': 'facebook'
    });
    return User.fromJsonMap(response.data);
  }

  static Future loginWithGoogle(String token) async {
    var response = await DioUtils().post(Api.LOGIN, queryParameters: {
      'access_token': token,
      'type': 'google'
    });
    return User.fromJsonMap(response.data);
  }

  /// [lout api]
  static logout() async {
    var usertoken = StorageManager.sharedPreferences.getString(token);
    await DioUtils().get(Api.LOGOUT, queryParameters: {
      'Authorization': 'Bearer' + usertoken.toString()
    });
  }
  
  //Registerwith dio_moonblink another method
  static Future register(
    String mail, String name, String lastname, String password) async{

      var response = await DioUtils().post(Api.REGISTER, queryParameters: {
        'mail' : mail,
        'name' : name,
        'last_name' : lastname,
        'password' : password,
      });
      // print(response);
      return response.data;
    }
  
  //Register as Partner
  static Future registAsPartner() async {
    var userid = StorageManager.sharedPreferences.getInt(mUserId);
    var usertoken = StorageManager.sharedPreferences.getString(token);  
    var response = await DioUtils().post(Api.RegisterAsPartner + '$userid/register', queryParameters: {
                'Authorization': 'Bearer' + usertoken.toString()
    });
    return response.data;
  }

  // Story
  static Future postStory(
    File story
  ) async {
    var storyPath = story.path;
    var userid = StorageManager.sharedPreferences.getInt(mUserId); 
    FormData formData = FormData.fromMap({
      'body': '',
      'media': await MultipartFile.fromFile(storyPath, filename: 'xxx.jpg')
    });
    debugPrint('test-------'+ storyPath);
    var response = await DioUtils().postwithData(Api.POSTSTORY+ '$userid/story', data: formData
    );
    return response.data;
  }

  // Booking
  static Future booking() async {
    var userid = StorageManager.sharedPreferences.getInt(mUserId);
    var response = await DioUtils().post(Api.Booking + '$userid/booking', queryParameters: {

    });
    return response.data;
  }

  // Set Status
  static Future setstatus(int status) async {
    var userid = StorageManager.sharedPreferences.getInt(mUserId);
    var response = await DioUtils().post(Api.SetStatus + '$userid/booking/1/status', queryParameters: {
      'status' : status
    });
    return response.data;
  } 
  // Sign As Partner
  static Future signAsPartner( String otp ) async {
      var userid = StorageManager.sharedPreferences.getInt(mUserId);
      var response = await DioUtils().post(Api.VerifyAsPartner + '$userid/verify', queryParameters: {
          'otp': otp
        });
      return User.fromJsonMap(response.data);
  }
  // Get OTP
  static Future getOtpCode( String mail) async {
    var userid = StorageManager.sharedPreferences.getInt(mUserId);
    var response = await DioUtils().get(Api.GetOtpCode + '$userid/send/otp', queryParameters: {
        'mail': mail
    });
    print(response);
    return response.data;
  }

  //nrc, email, gender, dob, phone, profile, address
  //Update userprofile data
  static Future setprofle(
    File cover, File profile, String nrc, String mail, String gender, String dob, String phone, String bios,String address) async{
    var coverPath = cover.path;
    var profilePath = profile.path;
    var userId = StorageManager.sharedPreferences.getInt(mUserId);
    // FormData formData = FormData.fromMap({

    // });
    
    var response = await DioUtils().postwithData(Api.SetProfile + '$userId/profile', data: {
      'cover_image': await MultipartFile.fromFile(coverPath, filename: 'cover.jpg'),
      'profile_image': await MultipartFile.fromFile(profilePath, filename: 'profile.jpg'),
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

}