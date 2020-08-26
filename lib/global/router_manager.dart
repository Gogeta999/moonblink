import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:moonblink/base_widget/page_route_animation.dart';
import 'package:moonblink/ui/pages/call/voice_call_page.dart';
import 'package:moonblink/ui/pages/license_agreement.dart';
import 'package:moonblink/ui/pages/main/chat/chatbox_page.dart';
import 'package:moonblink/ui/pages/main/home/comment_page.dart';
import 'package:moonblink/ui/pages/main/main_tab.dart';
import 'package:moonblink/ui/pages/main/stories/imagepicker_page.dart';
import 'package:moonblink/ui/pages/main/user_status/user_status_page.dart';
import 'package:moonblink/ui/pages/new_user_swiper_page.dart';
import 'package:moonblink/ui/pages/otp_page.dart';
import 'package:moonblink/ui/pages/settings/settings_page.dart';
import 'package:moonblink/ui/pages/signIO/DebugDio_Network_page.dart';
import 'package:moonblink/ui/pages/signIO/login_page.dart';
import 'package:moonblink/ui/pages/signIO/register_page.dart';
import 'package:moonblink/ui/pages/splash_page.dart';
import 'package:moonblink/ui/pages/user/blocked_user_page.dart';
import 'package:moonblink/ui/pages/user/partner_detail_page.dart';
import 'package:moonblink/ui/pages/user/partner_ownProfile_page.dart';
import 'package:moonblink/ui/pages/user/setpartner_profile_page.dart';
import 'package:moonblink/ui/pages/user/update_partner_profile_page.dart';
import 'package:moonblink/ui/pages/wallet/topup_page.dart';
import 'package:moonblink/ui/pages/wallet/wallet_page.dart';

import '../ui/pages/terms_and_conditions_page.dart';

class RouteName {
  static const String splash = 'splash';
  static const String main = '/';
  static const String userStatus = '/userStatus';
  // static const String comment = 'comment';
  static const String network = 'network';
  // static const String error = 'error';
  static const String imagepick = 'imagepick';
  static const String takepicture = 'takepicture';
  static const String story = 'story';
  static const String setprofile = 'setprofile';
  static const String updateprofile = 'updateprofile';
  static const String otp = 'otp';
  static const String login = 'login';
  static const String register = 'register';
  static const String registerAsPartner = 'registerAsPartner';
  static const String search = 'search';
  static const String setting = 'setting';
  static const String partnerDetail = 'parnterDetail';
  static const String partnerOwnProfile = 'parnterOwnProfile';
  static const String wallet = 'wallet';
  static const String topUp = 'topUp';
  static const String chatBox = 'chatBox';
  static const String callScreen = 'callScreen';
  static const String newUserSwiperPage = 'newUserSwiperPage';
  static const String termsAndConditionsPage = 'termsAndConditionsPage';
  static const String licenseAgreement = 'licenseAgreement';
  static const String blockedUsers = 'blockedUsers';
}

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteName.splash:
        return NoAnimRouteBuilder(SplashPage());
      case RouteName.newUserSwiperPage:
        return CupertinoPageRoute(builder: (_) => NewUserSwiperPage());
      case RouteName.termsAndConditionsPage:
        return CupertinoPageRoute(builder: (_) => TermsAndConditions());
      case RouteName.licenseAgreement:
        return CupertinoPageRoute(builder: (_) => LicenseAgreement());
      case RouteName.main:
        return NoAnimRouteBuilder(MainTabPage(
            initPage: settings.arguments != null ? settings.arguments : 0));
      case RouteName.userStatus:
        return NoAnimRouteBuilder(UserStatusPage());
      case RouteName.network:
        return NoAnimRouteBuilder(NetWorkPage());
      // case RouteName.comment:
      //   return CupertinoPageRoute(builder: (_) => CommentsPage());
      // case RouteName.search:
      //   return CupertinoPageRoute(builder: (_) => SearchPage());
      case RouteName.imagepick:
        return CupertinoPageRoute(builder: (_) => ImagePickerPage());
      case RouteName.otp:
        return CupertinoPageRoute(builder: (_) => OtpPage());
      // case RouteName.story:
      //   return CupertinoPageRoute(builder: (_) => StoriesPage());
      case RouteName.login:
        return CupertinoPageRoute(
            fullscreenDialog: true, builder: (_) => LoginPage());
      case RouteName.registerAsPartner:
        return CupertinoPageRoute(
            fullscreenDialog: true, builder: (_) => OtpPage());
      case RouteName.register:
        return CupertinoPageRoute(builder: (_) => RegisterPage());
      case RouteName.setting:
        return CupertinoPageRoute(builder: (_) => SettingsPage());
      case RouteName.partnerDetail:
        return CupertinoPageRoute(
            builder: (_) => PartnerDetailPage(settings.arguments));
      case RouteName.chatBox:
        return CupertinoPageRoute(
            builder: (_) => ChatBoxPage(settings.arguments));
      case RouteName.blockedUsers:
        return CupertinoPageRoute(
          builder: (_) => BlockedUserPage());
      /// [get some error to pass params in route name method, using simple push method first]
      // case RouteName.partnerDetail:
      //   // var posts = settings.arguments as PartnerUser;
      //   return CupertinoPageRoute(builder: (_) {
      //     return PartnerDetailPage();
      //   });
      case RouteName.partnerOwnProfile:
        return CupertinoPageRoute(builder: (_) => PartnerOwnProfilePage());
      case RouteName.setprofile:
        return CupertinoPageRoute(builder: (_) => SetPartnerProfilePage());

      case RouteName.updateprofile:
        return CupertinoPageRoute(
            builder: (_) => UpdatePartnerProfilePage(
                partnerUser: settings.arguments ?? 'Unknown data'));
      case RouteName.wallet:
        return CupertinoPageRoute(builder: (_) => WalletPage());
      case RouteName.callScreen:
        return CupertinoPageRoute(
            builder: (_) => VoiceCallWidget(
                channelName: settings.arguments != null
                    ? settings.arguments
                    : 'Unknown Channel'));
      default:
        return CupertinoPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                    child: Text('No route defined for ${settings.name}'),
                  ),
                ));
    }
  }
}

//Pop route
class PopRoute extends PopupRoute {
  final Duration _duration = Duration(milliseconds: 300);
  Widget child;

  PopRoute({@required this.child});

  @override
  Color get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  String get barrierLabel => null;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return child;
  }

  @override
  Duration get transitionDuration => _duration;
}
