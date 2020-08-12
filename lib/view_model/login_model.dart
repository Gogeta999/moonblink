import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:moonblink/api/moonblink_dio.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/provider/view_state_model.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/services/push_notification_manager.dart';
import 'package:moonblink/view_model/user_model.dart';

// save user login name to let them get their last name after logout
const String mLoginName = 'mLoginName';
// save token to pass our server
const String token = 'token';
const String FCMToken = 'FCM Token';
const String mUserType = 'mUserType';
const String mUserId = 'mUserId';
const String mLoginMail = 'mLoginMail';
const String mstatus = 'status';

class LoginModel extends ViewStateModel {
  final UserModel userModel;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['profile', 'email']);
  final FacebookLogin _facebookLogin = FacebookLogin();

  LoginModel(this.userModel) : assert(userModel != null);

  String getLoginName() {
    return StorageManager.sharedPreferences.getString(mLoginName);
  }

  Future<bool> login(String mail, String password, String type) async {
    setBusy();
    //String fcmToken = StorageManager.sharedPreferences.getString(FCMToken);
    String fcmToken = await PushNotificationsManager().getFcmToken();
    try {
      var user;
      if (type == 'email' &&
          mail != null &&
          password != null &&
          fcmToken != null) {
        user = await MoonBlinkRepository.login(mail, password, fcmToken);
      } else if (type == 'google' && fcmToken != null) {
        await _googleSignIn.signOut();
        GoogleSignInAccount googleUser = await _googleSignIn.signIn();
        if (googleUser != null) {
          //user cancelled login
          GoogleSignInAuthentication auth = await googleUser.authentication;
          user = await MoonBlinkRepository.loginWithGoogle(
              auth.accessToken, fcmToken);
        }
      } else if (type == 'facebook' && fcmToken != null) {
        final FacebookLoginResult result =
            await _facebookLogin.logIn(['email']);
        switch (result.status) {
          case FacebookLoginStatus.loggedIn:
            print('case loggedIn');
            final FacebookAccessToken accessToken = result.accessToken;
            user = await MoonBlinkRepository.loginWithFacebook(
                accessToken.token, fcmToken);
            break;
          case FacebookLoginStatus.cancelledByUser:
            print('case cancelledByUser');
            /*setIdle();
            return false;*/
            break;
          case FacebookLoginStatus.error:
            print('case error');
            /*setIdle();
            return false;*/
            break;
        }
      } else {
        setIdle();
        return false;
      }
      //login success then store data
      if (user != null) {
        userModel.saveUser(user);
        StorageManager.sharedPreferences.setString(token, userModel.user.token);
        StorageManager.sharedPreferences
            .setString(mLoginName, userModel.user.name);
        StorageManager.sharedPreferences.setInt(mUserId, userModel.user.id);
        StorageManager.sharedPreferences.setInt(mstatus, userModel.user.status);
        StorageManager.sharedPreferences.setInt(mUserType, userModel.user.type);
        DioUtils().initWithAuthorization();
        PushNotificationsManager().reInit();
        setIdle();
        return true;
      } else {
        setIdle();
        return false;
      }
    } catch (e, s) {
      setError(e, s);
      return false;
    }
  }

  Future<bool> logout() async {
    if (!userModel.hasUser) {
      // avoid from 2 user in same time
      return false;
    }
    setBusy();
    try {
      //await PushNotificationsManager().removeFcmToken();
      //UserWallet().dispose();
      PushNotificationsManager().dispose();
      DioUtils().initWithoutAuthorization();
      _facebookLogin.isLoggedIn
          .then((value) async => value ? await _facebookLogin.logOut() : null);
      _googleSignIn
          .isSignedIn()
          .then((value) async => value ? await _googleSignIn.signOut() : null);
      // await MoonBlinkRepository.logout();
      userModel.clearUser();
      setIdle();
      return true;
    } catch (e, s) {
      setError(e, s);
      return false;
    }
  }

  Future<bool> uploadStory(story) async {
    setBusy();
    try {
      await MoonBlinkRepository.postStory(story);
      setIdle();
      return true;
    } catch (e, s) {
      setError(e, s);
      return false;
    }
  }

  Future<bool> editProfile(
      cover, profile, nrc, mail, gender, dob, phone, bios, address) async {
    setBusy();
    try {
      var user = await MoonBlinkRepository.setprofle(
          cover, profile, nrc, mail, gender, dob, phone, bios, address);
      userModel.saveUser(user);
      setIdle();
      return true;
    } catch (e, s) {
      setError(e, s);
      return false;
    }
  }

  //change status
  Future<bool> changestatus(int status) async {
    setBusy();
    try {
      await MoonBlinkRepository.changestatus(status);
      setIdle();
      return true;
    } catch (e, s) {
      setError(e, s);
      return false;
    }
  }

  // Future<bool> getOtpCodeAgain(mail) async {
  //   setBusy();
  //   try {
  //     await MoonBlinkRepository.getOtpCode(mail);
  //     setIdle();
  //     return true;
  //   } catch (e, s) {
  //     setError(e, s);
  //     return false;
  //   }
  // }
}
