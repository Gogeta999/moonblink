import 'package:flutter/material.dart';
import 'package:moonblink/global/resources_manager.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:provider/provider.dart';

class ThirdLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //var theme = Theme.of(context);
    var model = Provider.of<LoginModel>(context);
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  model.login(null, null, 'google').then((value) {
                    if (value) {
                      Navigator.of(context).pop(true);
                    } else {
                      model.showErrorMessage(context);
                    }
                  });
                },
                child: Image.asset(
                  ImageHelper.wrapAssetsLogo('google_logo.png'),
                  width: 40,
                  height: 40,
                ),
              ),
              GestureDetector(
                onTap: () {
                  model.login(null, null, 'facebook').then((value) {
                    if (value) {
                      Navigator.of(context).pop(true);
                    } else {
                      model.showErrorMessage(context);
                    }
                  });
                },
                child: Image.asset(
                  ImageHelper.wrapAssetsLogo('facebook_logo.png'),
                  width: 40,
                  height: 40,
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
