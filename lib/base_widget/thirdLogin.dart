import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:moonblink/global/resources_manager.dart';

class ThirdLogin extends StatefulWidget {
  @override
  _ThirdLoginState createState() => _ThirdLoginState();
}

class _ThirdLoginState extends State<ThirdLogin> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['profile', 'email']);
  final FacebookLogin _facebookLogin = FacebookLogin();

  Future<void> _signInWithGoogle() async {
    GoogleSignInAccount googleUser;
    GoogleSignInAuthentication googleAuth;
    try {
      googleUser = await _googleSignIn.signIn();
      googleAuth = await googleUser.authentication;

      print('accessToken: ${googleAuth.accessToken}');
      print('idToken: ${googleAuth.idToken}');
      print('displayName: ${googleUser.displayName}');
      print('email: ${googleUser.email}');
      print('id: ${googleUser.id}');
      print('photoUrl: ${googleUser.photoUrl}');
    } catch (error) {
      print(error);
    }
  }

  Future<void> _signOutGoogle() async {
    await _googleSignIn.signOut();
    print("Sign Out");
  }

  Future<void> _signInWithFacebook() async {
    final FacebookLoginResult result = await _facebookLogin.logIn(['email']);
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        print('case loggedIn');
        final FacebookAccessToken accessToken = result.accessToken;
        print('token: ${accessToken.token}');
        print('declinedPermission: ${accessToken.declinedPermissions}');
        print('expires: ${accessToken.expires}');
        print('isValid: ${accessToken.isValid()}');
        print('permissions: ${accessToken.permissions}');
        print('userId: ${accessToken.userId}');
        final graphResponse = await Dio().get(
            'https://graph.facebook.com/${accessToken.userId}?fields=name,first_name,last_name,email&access_token=${accessToken.token}');
        final profile = jsonDecode(graphResponse.data);
        print(profile);
        break;
      case FacebookLoginStatus.cancelledByUser:
        print('case cancelledByUser');
        break;
      case FacebookLoginStatus.error:
        print('case error');
        break;
    }
  }

  Future<void> _signOutFacebook() async {
    await _facebookLogin.logOut();
    print('log out');
  }

  @override
  void initState() {
    super.initState();
    /*_googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentUser = account;
      });
    });*/
    try {
      _googleSignIn.signInSilently();
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    ///no provider widget is wrapped
    //var model = Provider.of<LoginModel>(context);
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              color: theme.hintColor.withAlpha(50),
              height: 0.6,
              width: 60,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child:
                  Text('Third Login', style: TextStyle(color: theme.hintColor)),
            ),
            Container(
              color: theme.hintColor.withAlpha(50),
              height: 0.6,
              width: 60,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              GestureDetector(
                onTap: _signInWithGoogle,
                child: Image.asset(
                  ImageHelper.wrapAssetsLogo('google_logo.png'),
                  width: 40,
                  height: 40,
                ),
              ),
              GestureDetector(
                onTap: _signInWithFacebook,
                child: Image.asset(
                  ImageHelper.wrapAssetsLogo('facebook_logo.png'),
                  width: 40,
                  height: 40,
                ),
              )
            ],
          ),
        ),
        SizedBox(height: 20),
        //For testing
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            FutureBuilder<bool>(
              initialData: false,
              future: _googleSignIn.isSignedIn(),
              builder: (context, snapshot) {
                return RaisedButton(
                  onPressed: snapshot.data ? _signOutGoogle : null,
                  child: Text('Log Out Google'),
                  disabledColor: Colors.grey[600],
                );
              }
            ),
            FutureBuilder<bool>(
              initialData: false,
              future: _facebookLogin.isLoggedIn,
              builder: (context, snapshot) {
                return RaisedButton(
                  onPressed: snapshot.data ? _signOutFacebook : null,
                  child: Text('Log Out Facebook'),
                  disabledColor: Colors.grey[600],
                );
              }
            ),
          ],
        )
      ],
    );
  }
}
