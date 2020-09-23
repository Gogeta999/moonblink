import 'package:moonblink/utils/platform_utils.dart';
import 'package:url_launcher/url_launcher.dart';

void openStore() async {
  String appStoreUrl;
  if (Platform.isIOS) {
    appStoreUrl = 'fb://profile/103254564508101';
  } else {
    appStoreUrl =
        'https://play.google.com/store/apps/details?id=com.moonuniverse.moonblink';
  }
  const String pageUrl = 'https://www.facebook.com/Moonblink2000';
  try {
    bool nativeAppLaunch = await launch(appStoreUrl,
        forceSafariVC: false, universalLinksOnly: true);
    if (!nativeAppLaunch) {
      await launch(pageUrl, forceSafariVC: false);
    }
  } catch (e) {
    await launch(pageUrl, forceSafariVC: false);
  }
}
