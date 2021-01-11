import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:moonblink/ui/pages/booking_page/booking_page.dart';
import 'package:moonblink/ui/pages/boosting_page/boosting_game_detail_page.dart';
import 'package:moonblink/ui/pages/boosting_page/boosting_game_list_page.dart';
import 'package:moonblink/ui/pages/boosting_page/boosting_request_page.dart';
import 'package:moonblink/ui/pages/call/voice_call_page.dart';
import 'package:moonblink/ui/pages/fb_login_error_page.dart';
import 'package:moonblink/ui/pages/game_profile/choose_user_play_game_page.dart';
import 'package:moonblink/ui/pages/main/chat/chat_box_page.dart';
import 'package:moonblink/ui/pages/main/newfeed/comment_page.dart';
import 'package:moonblink/ui/pages/main/newfeed/create_post_page.dart';
import 'package:moonblink/ui/pages/main/newfeed/my_new_feed_page.dart';
import 'package:moonblink/ui/pages/main/notifications/user_booking_notification_page.dart';
import 'package:moonblink/ui/pages/main/notifications/user_message_notification_page.dart';
import 'package:moonblink/ui/pages/main/notifications/user_new_notification_page.dart';
import 'package:moonblink/ui/pages/settings/allsetting/license_agreement.dart';
import 'package:moonblink/ui/pages/main/main_tab.dart';
import 'package:moonblink/ui/pages/main/stories/imagepicker_page.dart';
import 'package:moonblink/ui/pages/settings/allsetting/new_upgrade_vip.dart';
import 'package:moonblink/ui/pages/settings/allsetting/otp_page.dart';
import 'package:moonblink/ui/pages/settings/allsetting/blocklist.dart';
import 'package:moonblink/ui/pages/settings/allsetting/languages.dart';
import 'package:moonblink/ui/pages/settings/allsetting/unverify_partner_otp_page.dart';
import 'package:moonblink/ui/pages/settings/allsetting/upgrade_vip_page.dart';
import 'package:moonblink/ui/pages/settings/allsetting/vip_effect_demo.dart';
import 'package:moonblink/ui/pages/settings/settings_page.dart';
import 'package:moonblink/ui/pages/signIO/DebugDio_Network_page.dart';
import 'package:moonblink/ui/pages/signIO/resetpassword_page.dart';
import 'package:moonblink/ui/pages/signIO/login_page.dart';
import 'package:moonblink/ui/pages/signIO/register_page.dart';
import 'package:moonblink/ui/pages/splash_page.dart';
import 'package:moonblink/ui/pages/user/partner_detail_page.dart';
import 'package:moonblink/ui/pages/user/partner_ownProfile_page.dart';
import 'package:moonblink/ui/pages/user/setpartner_profile_page.dart';
import 'package:moonblink/ui/pages/user/update_partner_profile_page.dart';
import 'package:moonblink/ui/pages/user/user_rating_page.dart';
import 'package:moonblink/ui/pages/wallet/topup_page.dart';
import 'package:moonblink/ui/pages/wallet/wallet_page.dart';
import 'package:moonblink/utils/page_route_animation.dart';
import '../ui/pages/settings/allsetting/terms_and_conditions_page.dart';

class RouteName {
  static const String splash = 'splash';
  static const String main = '/';
  static const String booking = 'booking';
  static const String userStatus = '/userStatus';
  // static const String comment = 'comment';
  static const String network = 'network';
  static const String notiPage = 'notiPage';
  // static const String error = 'error';
  static const String imagepick = 'imagepick';
  static const String takepicture = 'takepicture';
  static const String story = 'story';
  static const String setprofile = 'setprofile';
  static const String updateprofile = 'updateprofile';
  static const String otp = 'otp';
  static const String type5otp = 'type5otp';
  static const String login = 'login';
  static const String resetpassword = 'resetpassword';
  static const String register = 'register';
  static const String registerAsPartner = 'registerAsPartner';
  static const String search = 'search';
  static const String setting = 'setting';
  static const String language = 'language';
  static const String partnerDetail = 'parnterDetail';
  static const String partnerOwnProfile = 'parnterOwnProfile';
  static const String upgradeVip = 'upgradeVip';
  static const String vipDemo = 'vipDemo';
  static const String wallet = 'wallet';
  static const String topUp = 'topUp';
  static const String chatBox = 'chatBox';
  static const String callScreen = 'callScreen';
  static const String termsAndConditionsPage = 'termsAndConditionsPage';
  static const String licenseAgreement = 'licenseAgreement';
  static const String blockedUsers = 'blockedUsers';
  static const String applyForQualification = 'applyForQualification';
  static const String pubgMobile = 'pubgMobile';
  static const String chooseUserPlayGames = 'chooseUserPlayGames';
  static const String updateGameProfile = 'updateGameProfile';
  static const String userRating = 'userRating';
  static const String userMessageHistory = 'userMessageHistory';
  static const String userBookingHistory = 'userBookingHistory';
  static const String facebookLoginError = 'facebookLoginError';
  static const String boostingPage = "boostingPage";
  static const String boostingGameListPage = 'BoostingGameListPage';
  static const String boostingGameDetailPage = 'BoostingGameDetailPage';
  static const String createPostPage = 'CreatePostPage';
  static const String managePostsPage = 'ManagePostsPage';
  static const String nfCommentPage = 'NFCommentPage';
}

class MoonGoRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteName.splash:
        return NoAnimRouteBuilder(SplashPage());
      case RouteName.createPostPage:
        return CupertinoPageRoute(builder: (_) => CreatePostPage());
      case RouteName.managePostsPage:
        return CupertinoPageRoute(builder: (_) => MyNewFeedPage());
      case RouteName.booking:
        return CupertinoPageRoute(
            builder: (_) => BookingPage(
                // partnerUser: settings.arguments,
                // partnerId: settings.arguments,
                // partnerBios: settings.arguments,
                // partnerName: settings.arguments,
                // partnerProfile: settings.arguments,
                ));
      case RouteName.nfCommentPage:
        return CupertinoPageRoute(
            builder: (_) => CommentPage(settings.arguments));
      case RouteName.boostingGameListPage:
        return CupertinoPageRoute(builder: (_) => BoostingGameListPage());
      case RouteName.boostingGameDetailPage:
        return CupertinoPageRoute(
            builder: (_) => BoostingGameDetailPage(data: settings.arguments));
      case RouteName.boostingPage:
        return CupertinoPageRoute(builder: (_) => BoostingRequestPage());
      case RouteName.termsAndConditionsPage:
        return CupertinoPageRoute(
            builder: (_) =>
                TermsAndConditions(showAccept: settings.arguments ?? true));
      case RouteName.licenseAgreement:
        return CupertinoPageRoute(
            builder: (_) =>
                LicenseAgreement(showAccept: settings.arguments ?? true));
      case RouteName.vipDemo:
        return CupertinoPageRoute(builder: (_) => VipDemo());
      case RouteName.main:
        return NoAnimRouteBuilder(MainTabPage(
            initPage: settings.arguments != null ? settings.arguments : 0));
      // case RouteName.userStatus:
      //   return NoAnimRouteBuilder(UserStatusPage());
      case RouteName.network:
        return NoAnimRouteBuilder(NetWorkPage());
      case RouteName.notiPage:
        return NoAnimRouteBuilder(UserNewNotificationPage());
      case RouteName.imagepick:
        return CupertinoPageRoute(builder: (_) => ImagePickerPage());
      case RouteName.otp:
        return CupertinoPageRoute(builder: (_) => OtpPage());
      case RouteName.upgradeVip:
        return CupertinoPageRoute(
            builder: (_) => UpgradeVIP(data: settings.arguments));
      case RouteName.type5otp:
        return CupertinoPageRoute(builder: (_) => Type5PartnerOtpPage());
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
      case RouteName.language:
        return CupertinoPageRoute(builder: (_) => LanguagePage());
      case RouteName.resetpassword:
        return CupertinoPageRoute(builder: (_) => ResetPasswordPage());
      case RouteName.partnerDetail:
        return CupertinoPageRoute(
            builder: (_) => PartnerDetailPage(settings.arguments));
      case RouteName.chatBox:
        return CupertinoPageRoute(
            builder: (_) => NewChatBoxPage(settings.arguments));
      case RouteName.blockedUsers:
        return CupertinoPageRoute(builder: (_) => BlockedUserPage());

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
      case RouteName.chooseUserPlayGames:
        return CupertinoPageRoute(builder: (_) => ChooseUserPlayGamePage());
      //case RouteName.updateGameProfile:
      //  return CupertinoPageRoute(
      //      builder: (_) =>
      //          UpdateGameProfilePage(gameProfile: settings.arguments ?? null));
      // case RouteName.applyForQualification:
      //   return CupertinoPageRoute(builder: (_) => ApplyForQualification());
      // case RouteName.pubgMobile:
      //   return CupertinoPageRoute(builder: (_) => PubgMobile());

      case RouteName.topUp:
        return CupertinoPageRoute(builder: (_) => NewTopUpPage());

      case RouteName.userRating:
        return CupertinoPageRoute(
            builder: (_) => UserRatingPage(userId: settings.arguments ?? 0));
      case RouteName.userMessageHistory:
        return CupertinoPageRoute(
            builder: (_) => UserMessageNotificationPage());
      case RouteName.userBookingHistory:
        return CupertinoPageRoute(
            builder: (_) => UserBookingNotificationPage());
      case RouteName.facebookLoginError:
        return CupertinoPageRoute(builder: (_) => FbLoginErrorPage());
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
