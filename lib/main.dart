import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:moonblink/api/moonblink_dio.dart';
import 'package:moonblink/bloc_pattern/chat_list/chat_list_bloc.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/provider_manager.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/services/ad_manager.dart';
import 'package:moonblink/services/moongo_database.dart';
import 'package:moonblink/services/push_notification_manager.dart';
import 'package:moonblink/utils/constants.dart';
import 'package:moonblink/view_model/local_model.dart';
import 'package:moonblink/view_model/theme_model.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import 'bloc_pattern/simple_bloc_observer.dart';
import 'bloc_pattern/user_notification/new/user_new_notification_bloc.dart';
import 'services/locator.dart';
import 'services/navigation_service.dart';

/// Bad Coding style
final BehaviorSubject<double> uploadProgress = BehaviorSubject();
final BehaviorSubject<CancelToken> cancelTokenForCreatePost = BehaviorSubject();

main() async {
  Provider.debugCheckInvalidValueType = null;
  WidgetsFlutterBinding.ensureInitialized();
  await StorageManager.init();
  InAppPurchaseConnection.enablePendingPurchases();
  await MoonGoDB().init();
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) => UserNewNotificationBloc(),
      ),
      BlocProvider(
        create: (_) => ChatListBloc(),
      )
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (isDev) print('$state');
    if (state == AppLifecycleState.inactive) {
      StorageManager.sharedPreferences.setBool(isUserOnForeground, false);
      if (isDev)
        print(StorageManager.sharedPreferences.get(isUserOnForeground));
    }
    if (state == AppLifecycleState.resumed) {
      StorageManager.sharedPreferences.setBool(isUserOnForeground, true);
      if (isDev)
        print(StorageManager.sharedPreferences.get(isUserOnForeground));
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  @override
  void dispose() {
    if (isDev) print('Disposing main app');
    MoonGoDB().dispose();
    uploadProgress.close();
    cancelTokenForCreatePost.close();
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  Future<void> _init() async {
    Bloc.observer = SimpleBlocObserver();
    setupLocator();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light));
    PushNotificationsManager().init();
    restartConstants();
    await Firebase.initializeApp();
    FirebaseAdMob.instance.initialize(appId: AdManager.adMobAppId);
  }

  void restartConstants() {
    StorageManager.sharedPreferences.setBool(isUserAtChatBox, false);
    StorageManager.sharedPreferences.setBool(isUserAtVoiceCallPage, false);
  }

  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: MultiProvider(
        providers: providers,
        child: Consumer2<ThemeModel, LocaleModel>(
            builder: (context, themeModel, localModel, child) {
          return Stack(
            children: [
              MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: themeModel.themeData(),
                darkTheme: themeModel.themeData(platformDarkMode: true),
                locale: localModel.locale,
                localizationsDelegates: const [
                  G.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate
                ],
                supportedLocales: G.delegate.supportedLocales,
                onGenerateRoute: MoonGoRouter.generateRoute,
                initialRoute: RouteName.splash,
                navigatorKey: locator<NavigationService>().navigatorKey,
              ),
              StreamBuilder<double>(
                  initialData: null,
                  stream: uploadProgress,
                  builder: (context, snapshot) {
                    if (snapshot.data == null) return Container();
                    return Positioned(
                        top: 60,
                        right: 10,
                        left: 10,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 2),
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.black),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Uploading on progress...'),
                                  GestureDetector(
                                      child: Text('Cancel upload', style: TextStyle(color: Theme.of(context).accentColor)),
                                      onTap: () {
                                        cancelTokenForCreatePost.first
                                            .then((value) {
                                          if (value != null) {
                                            value.cancel("cancelled");
                                            uploadProgress.add(null);
                                          }
                                        });
                                      })
                                ],
                              ),
                              SizedBox(height: 5),
                              LinearProgressIndicator(
                                value: snapshot.data,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).accentColor),
                              )
                            ],
                          ),
                        ));
                  })
            ],
          );
        }),
      ),
    );
  }
}
