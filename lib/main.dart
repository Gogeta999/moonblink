import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/provider_manager.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/services/chat_service.dart';
import 'package:moonblink/view_model/local_model.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:moonblink/view_model/theme_model.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';

import 'services/locator.dart';
import 'services/navigation_service.dart';
import 'services/push_notification_manager.dart';

String usertoken = StorageManager.sharedPreferences.getString(token);

//main() => runApp(TestInAPP());

main() async {
  Provider.debugCheckInvalidValueType = null;
  WidgetsFlutterBinding.ensureInitialized();
  await StorageManager.init();
  await PushNotificationsManager().init();
  // if (usertoken != null) {
  // BackgroundFetch.registerHeadlessTask(chatinits);

  // }
  setupLocator();
  Future.delayed(Duration(milliseconds: 100), () => runApp(MyApp()));
  // android's statusbar will change with theme
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light));
}

class MyApp extends StatelessWidget {
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
                  S.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate
                ],
                supportedLocales: S.delegate.supportedLocales,
                onGenerateRoute: Router.generateRoute,
                initialRoute: RouteName.splash,
                navigatorKey: locator<NavigationService>().navigatorKey,
              ));
        }),
      ),
    );
  }
}
