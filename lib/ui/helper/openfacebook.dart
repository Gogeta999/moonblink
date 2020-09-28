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

void openCustomerServicePage() async {
  String customerServiceUrl;
  if (Platform.isIOS) {
    customerServiceUrl = 'fb://profile/103254564508101';
  } else {
    customerServiceUrl = 'fb://page/103254564508101';
  }
  const String pageUrl = 'https://www.facebook.com/Moon-Go-109953790813440/';
  try {
    bool nativeAppLaunch = await launch(customerServiceUrl,
        forceSafariVC: false, universalLinksOnly: true);
    if (!nativeAppLaunch) {
      await launch(pageUrl, forceSafariVC: false);
    }
  } catch (e) {
    await launch(pageUrl, forceSafariVC: false);
  }
}
