import 'package:flutter/material.dart';
import 'package:moonblink/global/resources_manager.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/utils/platform_utils.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:provider/provider.dart';
import 'package:apple_sign_in/apple_sign_in.dart';

class ThirdLogin extends StatefulWidget {
  @override
  _ThirdLoginState createState() => _ThirdLoginState();
}

class _ThirdLoginState extends State<ThirdLogin> {
  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
      AppleSignIn.onCredentialRevoked.listen((_) {
        print("Credentials revoked");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var model = Provider.of<LoginModel>(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 20, left: 50, right: 50),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              InkResponse(
                onTap: () {
                  model.login(null, null, 'google').then((value) {
                    if (value) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          RouteName.main, (route) => false);
                    } else {
                      model.showErrorMessage(context);
                    }
                  });
                },
                child: Image.asset(
                  ImageHelper.wrapAssetsLogo('google_logo.png'),
                  width: 44,
                  height: 44,
                ),
              ),
              InkResponse(
                onTap: () {
                  model.login(null, null, 'facebook').then((value) {
                    if (value) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          RouteName.main, (route) => false);
                    } else {
                      model.showErrorMessage(context);
                    }
                  });
                },
                child: Image.asset(
                  ImageHelper.wrapAssetsLogo('facebook_logo.png'),
                  width: 44,
                  height: 44,
                ),
              ),
              if (Platform.isIOS)
                InkResponse(
                  onTap: () => model.login(null, null, 'apple').then((value) {
                    if (value) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          RouteName.main, (route) => false);
                    } else {
                      model.showErrorMessage(context);
                    }
                  }),
                  child: Image.asset(
                    ImageHelper.wrapAssetsLogo('apple_logo.png'),
                    width: 48,
                    height: 48,
                  ),
                )
            ],
          ),
        ),
        SizedBox(height: 20)
      ],
    );
  }
}
