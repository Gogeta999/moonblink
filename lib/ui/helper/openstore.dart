import 'package:moonblink/utils/platform_utils.dart';
import 'package:url_launcher/url_launcher.dart';

void openStore() async {
  String appStoreUrl;
  if (Platform.isIOS) {
    appStoreUrl = 'https://apps.apple.com/us/app/id1526791060';
  } else {
    appStoreUrl =
        'https://play.google.com/store/apps/details?id=com.moonuniverse.moonblink';
  }
  try {
    bool nativeAppLaunch = await launch(appStoreUrl, forceSafariVC: false);
    if (!nativeAppLaunch) {
      await launch(appStoreUrl, forceSafariVC: false);
    }
  } catch (e) {
    await launch(appStoreUrl, forceSafariVC: false);
  }
}
