import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:moonblink/global/resources_manager.dart';
import 'package:oktoast/oktoast.dart';

class ThirdLogin extends StatelessWidget {

  // GoogleSignIn _googleSignIn = GoogleSignIn(
  //   scopes: [
  //     'profile',
  //     'email'
  //   ]
  // );
  // GoogleSignInAccount _signInAccount;
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
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
              child: Text('Third Login',
                  style: TextStyle(color: theme.hintColor)),
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
                onTap: () {
                  showToast('Developing........');
                },
                child: Image.asset(
                  ImageHelper.wrapAssetsLogo('google_logo.png'),
                  width: 40,
                  height: 40,
                ),
              ),
              GestureDetector(
                onTap: () {
                  showToast('Developing........');
                },
                child: Image.asset(
                  ImageHelper.wrapAssetsLogo('facebook_logo.png'),
                  width: 40,
                  height: 40,
                ),
              )
            ],
          ),
        )
      ],
    );
  }

}

