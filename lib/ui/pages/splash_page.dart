import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/resources_manager.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/services/push_notification_manager.dart';
import 'package:moonblink/view_model/user_model.dart';
import 'new_user_swiper_page.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  AnimationController _countdownController;

  @override
  void initState() {
    _countdownController =
        AnimationController(vsync: this, duration: Duration(seconds: 4));
    _countdownController.forward();
    super.initState();
  }

  @override
  void dispose() {
    // _logoController.dispose();
    _countdownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () => Future.value(false),
        child: Stack(fit: StackFit.expand, children: <Widget>[
          FutureBuilder(
            future: MoonBlinkRepository.showAd(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Image.asset(ImageHelper.wrapAssetsImage('splash.jpg'),
                    // colorBlendMode: BlendMode
                    //     .srcOver
                    // color: Colors.black.withOpacity(
                    //     Theme.of(context).brightness == Brightness.light
                    //         ? 0
                    //         : 0.65),
                    fit: BoxFit.cover);
              } else if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                if (snapshot.data.status == '1') {
                  return InkWell(
                    // onTap: ,
                    child: Image.network(
                      snapshot.data.adUrl,
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.high,
                    ),
                  );
                } else {
                  return Image.asset(ImageHelper.wrapAssetsImage('splash.jpg'),
                      // colorBlendMode: BlendMode
                      //     .srcOver
                      // color: Colors.black.withOpacity(
                      //     Theme.of(context).brightness == Brightness.light
                      //         ? 0
                      //         : 0.65),
                      fit: BoxFit.cover);
                }
              } else if (snapshot.hasError) {
                return Image.asset(ImageHelper.wrapAssetsImage('splash.jpg'),
                    // colorBlendMode: BlendMode
                    //     .srcOver
                    // color: Colors.black.withOpacity(
                    //     Theme.of(context).brightness == Brightness.light
                    //         ? 0
                    //         : 0.65),
                    fit: BoxFit.cover);
              }
              return Center(child: CircularProgressIndicator());
            },
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: SafeArea(
              child: InkWell(
                onTap: () {
                  nextPage(context);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  margin: EdgeInsets.only(right: 20, bottom: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: Colors.black.withAlpha(100),
                  ),
                  child: AnimatedCountdown(
                    context: context,
                    animation: StepTween(begin: 3, end: 0)
                        .animate(_countdownController),
                  ),
                ),
              ),
            ),
          )
        ]),
      ),
    );
  }
}

class AnimatedCountdown extends AnimatedWidget {
  final Animation<int> animation;

  AnimatedCountdown({key, this.animation, context})
      : super(key: key, listenable: animation) {
    this.animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        nextPage(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var value = animation.value + 1;
    return Text(
      (value == 0 ? '' : '$value | ') + G.of(context).splashSkip,
      style: TextStyle(color: Colors.white),
    );
  }
}

void nextPage(context) {
  final hasUser = StorageManager.localStorage.getItem(mUser);
  bool newUser = StorageManager.sharedPreferences.getBool(isNewUser) ?? true;
  // newUser
  //     ? Navigator.of(context).pushReplacementNamed(RouteName.newUserSwiperPage)
  //     : Navigator.of(context)
  //         .pushNamedAndRemoveUntil(RouteName.main, (route) => false);
  if (newUser == true) {
    Navigator.of(context).pushReplacementNamed(RouteName.newUserSwiperPage);
  } else if (newUser == false && hasUser == null) {
    Navigator.of(context)
        .pushNamedAndRemoveUntil(RouteName.login, (route) => false);
  } else {
    Navigator.of(context)
        .pushNamedAndRemoveUntil(RouteName.main, (route) => false);
  }
}
