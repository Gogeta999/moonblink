import 'package:moonblink/utils/platform_utils.dart';

class AdManager {
  static String get adMobAppId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-2553224590005557~4621580830';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-2553224590005557~4787287702';
    } else {
      throw UnsupportedError('Unsupported Platform');
    }
  }

  static String get rewardedAdId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-2553224590005557/6918896522';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-2553224590005557/4212572630';
    } else {
      throw UnsupportedError('Unsupported Platform');
    }
  }

  static String get nativeAdId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-2553224590005557/4636348112';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-2553224590005557/3245322937';
    } else {
      throw UnsupportedError('Unsupported Platform');
    }
  }
}