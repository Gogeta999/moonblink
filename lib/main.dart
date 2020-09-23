import 'dart:async';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/provider_manager.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/services/ad_manager.dart';
import 'package:moonblink/services/chat_service.dart';
import 'package:moonblink/services/push_notification_manager.dart';
import 'package:moonblink/utils/constants.dart';
import 'package:moonblink/view_model/local_model.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:moonblink/view_model/theme_model.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';

import 'bloc_pattern/simple_bloc_observer.dart';
import 'services/locator.dart';
import 'services/navigation_service.dart';

// String usertoken = StorageManager.sharedPreferences.getString(token);

main() async {
  Provider.debugCheckInvalidValueType = null;
  WidgetsFlutterBinding.ensureInitialized();
  await StorageManager.init();
  InAppPurchaseConnection.enablePendingPurchases();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    print('Disposing main app');
    super.dispose();
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
          return ScopedModel(
              model: ChatModel(),
              child: MaterialApp(
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
                onGenerateRoute: Router.generateRoute,
                initialRoute: RouteName.splash,
                navigatorKey: locator<NavigationService>().navigatorKey,
              ));
        }),
      ),
    );
  }
}
