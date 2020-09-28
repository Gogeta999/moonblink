import 'package:moonblink/utils/platform_utils.dart';
import 'package:url_launcher/url_launcher.dart';

void openFacebookPage() async {
  String fbProtocolUrl;
  if (Platform.isIOS) {
    fbProtocolUrl = 'fb://profile/103254564508101';
  } else {
    fbProtocolUrl = 'fb://page/103254564508101';
  }
  const String pageUrl = 'https://www.facebook.com/Moonblink2000';
  try {
    bool nativeAppLaunch = await launch(fbProtocolUrl,
        forceSafariVC: false, universalLinksOnly: true);
    if (!nativeAppLaunch) {
      await launch(pageUrl, forceSafariVC: false);
    }
  } catch (e) {
    await launch(pageUrl, forceSafariVC: false);
  }
}
