import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:moonblink/api/moonblink_dio.dart';
import 'package:moonblink/bloc_pattern/chat_list/chat_list_bloc.dart';
import 'package:moonblink/bloc_pattern/user_notification/new/user_new_notification_bloc.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/provider/view_state_model.dart';
import 'package:moonblink/services/locator.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/services/navigation_service.dart';
import 'package:moonblink/services/push_notification_manager.dart';
import 'package:moonblink/view_model/user_model.dart';
import 'package:moonblink/services/web_socket_service.dart';

// save user login name to let them get their last name after logout
const String mLoginName = 'mLoginName';
// save token to pass our server
const String token = 'token';
const String FCMToken = 'FCM Token';
const String mUserType = 'mUserType';
const String mUserId = 'mUserId';
const String mLoginMail = 'mLoginMail';
const String mstatus = 'status';
const String mUserProfile = 'mUserProfile';
const String mgameprofile = 'gameprofile';

class LoginModel extends ViewStateModel {
  final UserModel userModel;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['profile', 'email']);
  final FacebookLogin _facebookLogin = FacebookLogin();

  LoginModel(this.userModel) : assert(userModel != null);

  String getLoginName() {
    return StorageManager.sharedPreferences.getString(mLoginName);
  }

  String getLoginMail() {
    return StorageManager.sharedPreferences.getString(mLoginMail);
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
            if (isDev) print('case loggedIn');
            final FacebookAccessToken accessToken = result.accessToken;
            user = await MoonBlinkRepository.loginWithFacebook(
                    accessToken.token, fcmToken)
                .catchError((e) {
              showCupertinoDialog(
                  context: locator<NavigationService>()
                      .navigatorKey
                      .currentState
                      .overlay
                      .context,
                  builder: (context) {
                    return CupertinoAlertDialog(
                      title: Text('Sign In Failed\n'),
                      content: Text('Having trouble signing in using Facebook? '
                          'Would you like to view the instructions that we prepared for you.'),
                      actions: [
                        CupertinoButton(
                          child: Text('No, it\'s okay'),
                          onPressed: () => Navigator.pop(context),
                        ),
                        CupertinoButton(
                          child: Text('Yes, show me'),
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(
                                context, RouteName.facebookLoginError);
                          },
                        )
                      ],
                    );
                  });
            });
            break;
          case FacebookLoginStatus.cancelledByUser:
            if (isDev) print('case cancelledByUser');
            /*setIdle();
            return false;*/
            break;
          case FacebookLoginStatus.error:
            if (isDev) print('case error');
            /*setIdle();
            return false;*/
            break;
        }
      } else if (type == 'apple' && fcmToken != null) {
        if (await AppleSignIn.isAvailable()) {
          final AuthorizationResult result = await AppleSignIn.performRequests([
            AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
          ]);
          switch (result.status) {
            case AuthorizationStatus.authorized:
              String identityTokenString =
                  String.fromCharCodes(result.credential.identityToken);
              user = await MoonBlinkRepository.loginWithApple(
                  identityTokenString, fcmToken);
              break;
            case AuthorizationStatus.error:
              if (isDev) print("Sign in failed: ${result.error.localizedDescription}");
              break;
            case AuthorizationStatus.cancelled:
              if (isDev) print('User cancelled');
              break;
          }
        } else {
          if (isDev) print('Apple SignIn is not available for your device');
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
            .setString(mLoginMail, userModel.user.email);
        StorageManager.sharedPreferences
            .setString(mLoginName, userModel.user.name);
        StorageManager.sharedPreferences
            .setString(mUserProfile, userModel.user.profileUrl);
        StorageManager.sharedPreferences.setInt(mUserId, userModel.user.id);
        StorageManager.sharedPreferences.setInt(mstatus, userModel.user.status);
        StorageManager.sharedPreferences.setInt(mUserType, userModel.user.type);
        StorageManager.sharedPreferences
            .setInt(mgameprofile, userModel.user.gameprofilecount);
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
      PushNotificationsManager().dispose();
      WebSocketService().dispose();
      final context = locator<NavigationService>().navigatorKey.currentContext;
      BlocProvider.of<UserNewNotificationBloc>(context)
          .add(UserNewNotificationCleared());
      BlocProvider.of<ChatListBloc>(context).chatsSubject.add([]);
      _facebookLogin.isLoggedIn
          .then((value) async => value ? await _facebookLogin.logOut() : null);
      _googleSignIn
          .isSignedIn()
          .then((value) async => value ? await _googleSignIn.signOut() : null);
      userModel.clearUser();
      await MoonBlinkRepository.logout();
      DioUtils().initWithoutAuthorization();

      ///to notify server to remove fcm token.
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
