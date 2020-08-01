// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars

class S {
  S();
  
  static S current;
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name); 
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      S.current = S();
      
      return S.current;
    });
  } 

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Accept`
  String get accept {
    return Intl.message(
      'Accept',
      name: 'accept',
      desc: '',
      args: [],
    );
  }

  /// `MoonBlink`
  String get appName {
    return Intl.message(
      'MoonBlink',
      name: 'appName',
      desc: '',
      args: [],
    );
  }

  /// `Auto with system`
  String get autoBySystem {
    return Intl.message(
      'Auto with system',
      name: 'autoBySystem',
      desc: '',
      args: [],
    );
  }

  /// `'s average rating is `
  String get averageRatingIs {
    return Intl.message(
      '\'s average rating is ',
      name: 'averageRatingIs',
      desc: '',
      args: [],
    );
  }

  /// `Booking request`
  String get bookingRequest {
    return Intl.message(
      'Booking request',
      name: 'bookingRequest',
      desc: '',
      args: [],
    );
  }

  /// `Book`
  String get bookingBook {
    return Intl.message(
      'Book',
      name: 'bookingBook',
      desc: '',
      args: [],
    );
  }

  /// `Choose game type to play with our partner`
  String get bookingChooseGameType {
    return Intl.message(
      'Choose game type to play with our partner',
      name: 'bookingChooseGameType',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get bookingCancel {
    return Intl.message(
      'Cancel',
      name: 'bookingCancel',
      desc: '',
      args: [],
    );
  }

  /// `Booking End`
  String get bookingEnded {
    return Intl.message(
      'Booking End',
      name: 'bookingEnded',
      desc: '',
      args: [],
    );
  }

  /// `Player is currently unavailable to Play`
  String get bookingPlayerBusy {
    return Intl.message(
      'Player is currently unavailable to Play',
      name: 'bookingPlayerBusy',
      desc: '',
      args: [],
    );
  }

  /// `Booking Dialog`
  String get bookingDialog {
    return Intl.message(
      'Booking Dialog',
      name: 'bookingDialog',
      desc: '',
      args: [],
    );
  }

  /// `want to play with you`
  String get bookingDialogSomeoneBook {
    return Intl.message(
      'want to play with you',
      name: 'bookingDialogSomeoneBook',
      desc: '',
      args: [],
    );
  }

  /// `Reject`
  String get bookingDialogReject {
    return Intl.message(
      'Reject',
      name: 'bookingDialogReject',
      desc: '',
      args: [],
    );
  }

  /// `Accept`
  String get bookingDialogAccept {
    return Intl.message(
      'Accept',
      name: 'bookingDialogAccept',
      desc: '',
      args: [],
    );
  }

  /// `Burmese`
  String get burmese {
    return Intl.message(
      'Burmese',
      name: 'burmese',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message(
      'Confirm',
      name: 'confirm',
      desc: '',
      args: [],
    );
  }

  /// `Chinese`
  String get china {
    return Intl.message(
      'Chinese',
      name: 'china',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `End`
  String get end {
    return Intl.message(
      'End',
      name: 'end',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get english {
    return Intl.message(
      'English',
      name: 'english',
      desc: '',
      args: [],
    );
  }

  /// `Enter Call`
  String get enterCall {
    return Intl.message(
      'Enter Call',
      name: 'enterCall',
      desc: '',
      args: [],
    );
  }

  /// `You need to login first`
  String get forceLoginTitle {
    return Intl.message(
      'You need to login first',
      name: 'forceLoginTitle',
      desc: '',
      args: [],
    );
  }

  /// `You need to login and contiue to use our  app`
  String get forceLoginContent {
    return Intl.message(
      'You need to login and contiue to use our  app',
      name: 'forceLoginContent',
      desc: '',
      args: [],
    );
  }

  /// `Sorry we don't support this version`
  String get forceUpdateTitle {
    return Intl.message(
      'Sorry we don\'t support this version',
      name: 'forceUpdateTitle',
      desc: '',
      args: [],
    );
  }

  /// `Please download our app on AppStore`
  String get forceUpdateContent {
    return Intl.message(
      'Please download our app on AppStore',
      name: 'forceUpdateContent',
      desc: '',
      args: [],
    );
  }

  /// `Follow`
  String get follow {
    return Intl.message(
      'Follow',
      name: 'follow',
      desc: '',
      args: [],
    );
  }

  /// `Following`
  String get following {
    return Intl.message(
      'Following',
      name: 'following',
      desc: '',
      args: [],
    );
  }

  /// `Feedback`
  String get feedback {
    return Intl.message(
      'Feedback',
      name: 'feedback',
      desc: '',
      args: [],
    );
  }

  /// `Can't be empty`
  String get fieldNotEmpty {
    return Intl.message(
      'Can\'t be empty',
      name: 'fieldNotEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Upload Your Story`
  String get imagePickerAppBar {
    return Intl.message(
      'Upload Your Story',
      name: 'imagePickerAppBar',
      desc: '',
      args: [],
    );
  }

  /// `Choose your image or video to your story`
  String get imagePickerChooseSome {
    return Intl.message(
      'Choose your image or video to your story',
      name: 'imagePickerChooseSome',
      desc: '',
      args: [],
    );
  }

  /// `Camera`
  String get imagePickerCamera {
    return Intl.message(
      'Camera',
      name: 'imagePickerCamera',
      desc: '',
      args: [],
    );
  }

  /// `Gallery`
  String get imagePickerGallery {
    return Intl.message(
      'Gallery',
      name: 'imagePickerGallery',
      desc: '',
      args: [],
    );
  }

  /// `Video`
  String get imagePickerVideo {
    return Intl.message(
      'Video',
      name: 'imagePickerVideo',
      desc: '',
      args: [],
    );
  }

  /// `Upload`
  String get imagePickerUploadButton {
    return Intl.message(
      'Upload',
      name: 'imagePickerUploadButton',
      desc: '',
      args: [],
    );
  }

  /// `Login First`
  String get loginFirst {
    return Intl.message(
      'Login First',
      name: 'loginFirst',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get loginMail {
    return Intl.message(
      'Email',
      name: 'loginMail',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get loginPassword {
    return Intl.message(
      'Password',
      name: 'loginPassword',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get logout {
    return Intl.message(
      'Logout',
      name: 'logout',
      desc: '',
      args: [],
    );
  }

  /// `Myanmar`
  String get myanmar {
    return Intl.message(
      'Myanmar',
      name: 'myanmar',
      desc: '',
      args: [],
    );
  }

  /// `No this account`
  String get noAccount {
    return Intl.message(
      'No this account',
      name: 'noAccount',
      desc: '',
      args: [],
    );
  }

  /// `Please rate our app`
  String get ratingApp {
    return Intl.message(
      'Please rate our app',
      name: 'ratingApp',
      desc: '',
      args: [],
    );
  }

  /// `Release to enter user setting page`
  String get refreshTwoLevel {
    return Intl.message(
      'Release to enter user setting page',
      name: 'refreshTwoLevel',
      desc: '',
      args: [],
    );
  }

  /// `Reject`
  String get reject {
    return Intl.message(
      'Reject',
      name: 'reject',
      desc: '',
      args: [],
    );
  }

  /// `Get your otp code`
  String get otpGetCode {
    return Intl.message(
      'Get your otp code',
      name: 'otpGetCode',
      desc: '',
      args: [],
    );
  }

  /// `Welcome to be our partner`
  String get otpWelcomePartner {
    return Intl.message(
      'Welcome to be our partner',
      name: 'otpWelcomePartner',
      desc: '',
      args: [],
    );
  }

  /// `Sign As Partner`
  String get otpSignAsPartnerButton {
    return Intl.message(
      'Sign As Partner',
      name: 'otpSignAsPartnerButton',
      desc: '',
      args: [],
    );
  }

  /// `Please rating for this game`
  String get pleaseRatingForThisGame {
    return Intl.message(
      'Please rating for this game',
      name: 'pleaseRatingForThisGame',
      desc: '',
      args: [],
    );
  }

  /// `Please allow Microphone`
  String get pleaseAllowMicroPhone {
    return Intl.message(
      'Please allow Microphone',
      name: 'pleaseAllowMicroPhone',
      desc: '',
      args: [],
    );
  }

  /// `Refreshing`
  String get pullDownToRefresh {
    return Intl.message(
      'Refreshing',
      name: 'pullDownToRefresh',
      desc: '',
      args: [],
    );
  }

  /// `Loading`
  String get pullTopToLoad {
    return Intl.message(
      'Loading',
      name: 'pullTopToLoad',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get search {
    return Intl.message(
      'Search',
      name: 'search',
      desc: '',
      args: [],
    );
  }

  /// `History`
  String get searchHistory {
    return Intl.message(
      'History',
      name: 'searchHistory',
      desc: '',
      args: [],
    );
  }

  /// `Clear`
  String get searchClear {
    return Intl.message(
      'Clear',
      name: 'searchClear',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get searchRetry {
    return Intl.message(
      'Retry',
      name: 'searchRetry',
      desc: '',
      args: [],
    );
  }

  /// `Setup your profile`
  String get setPartnerProfile {
    return Intl.message(
      'Setup your profile',
      name: 'setPartnerProfile',
      desc: '',
      args: [],
    );
  }

  /// `Please fill all your informations first`
  String get setPartnerFillInformations {
    return Intl.message(
      'Please fill all your informations first',
      name: 'setPartnerFillInformations',
      desc: '',
      args: [],
    );
  }

  /// `Upload Profile`
  String get setPartnerButton {
    return Intl.message(
      'Upload Profile',
      name: 'setPartnerButton',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settingsSettings {
    return Intl.message(
      'Settings',
      name: 'settingsSettings',
      desc: '',
      args: [],
    );
  }

  /// `Register as our partner`
  String get settingsSignAsPartner {
    return Intl.message(
      'Register as our partner',
      name: 'settingsSignAsPartner',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get settingLanguage {
    return Intl.message(
      'Language',
      name: 'settingLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Someone is calling you`
  String get someoneCallingYou {
    return Intl.message(
      'Someone is calling you',
      name: 'someoneCallingYou',
      desc: '',
      args: [],
    );
  }

  /// `Sign in First`
  String get showToastSignInFirst {
    return Intl.message(
      'Sign in First',
      name: 'showToastSignInFirst',
      desc: '',
      args: [],
    );
  }

  /// `Sign In`
  String get signIn {
    return Intl.message(
      'Sign In',
      name: 'signIn',
      desc: '',
      args: [],
    );
  }

  /// `Mail`
  String get signInMail {
    return Intl.message(
      'Mail',
      name: 'signInMail',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get signInPassword {
    return Intl.message(
      'Password',
      name: 'signInPassword',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up`
  String get signUp {
    return Intl.message(
      'Sign Up',
      name: 'signUp',
      desc: '',
      args: [],
    );
  }

  /// `Mail`
  String get signUpMail {
    return Intl.message(
      'Mail',
      name: 'signUpMail',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get signUpName {
    return Intl.message(
      'Name',
      name: 'signUpName',
      desc: '',
      args: [],
    );
  }

  /// `Last Name`
  String get signUpLastName {
    return Intl.message(
      'Last Name',
      name: 'signUpLastName',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get signUpPassword {
    return Intl.message(
      'Password',
      name: 'signUpPassword',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get splashSkip {
    return Intl.message(
      'Skip',
      name: 'splashSkip',
      desc: '',
      args: [],
    );
  }

  /// `Submit`
  String get submit {
    return Intl.message(
      'Submit',
      name: 'submit',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get tabHome {
    return Intl.message(
      'Home',
      name: 'tabHome',
      desc: '',
      args: [],
    );
  }

  /// `Chat`
  String get tabChat {
    return Intl.message(
      'Chat',
      name: 'tabChat',
      desc: '',
      args: [],
    );
  }

  /// `Following`
  String get tabFollowing {
    return Intl.message(
      'Following',
      name: 'tabFollowing',
      desc: '',
      args: [],
    );
  }

  /// `User`
  String get tabUser {
    return Intl.message(
      'User',
      name: 'tabUser',
      desc: '',
      args: [],
    );
  }

  /// `Term and Conditions`
  String get termAndConditions {
    return Intl.message(
      'Term and Conditions',
      name: 'termAndConditions',
      desc: '',
      args: [],
    );
  }

  /// `Third Login`
  String get thirdLogin {
    return Intl.message(
      'Third Login',
      name: 'thirdLogin',
      desc: '',
      args: [],
    );
  }

  /// `Sign In`
  String get toSignIn {
    return Intl.message(
      'Sign In',
      name: 'toSignIn',
      desc: '',
      args: [],
    );
  }

  /// `Please Sign Up`
  String get toSignUp {
    return Intl.message(
      'Please Sign Up',
      name: 'toSignUp',
      desc: '',
      args: [],
    );
  }

  /// `Trim your video`
  String get trimYourVideo {
    return Intl.message(
      'Trim your video',
      name: 'trimYourVideo',
      desc: '',
      args: [],
    );
  }

  /// `Update Your Profile`
  String get updatePartnerProfile {
    return Intl.message(
      'Update Your Profile',
      name: 'updatePartnerProfile',
      desc: '',
      args: [],
    );
  }

  /// `Update`
  String get updatePartnerButton {
    return Intl.message(
      'Update',
      name: 'updatePartnerButton',
      desc: '',
      args: [],
    );
  }

  /// `Wallet`
  String get userStatusWallet {
    return Intl.message(
      'Wallet',
      name: 'userStatusWallet',
      desc: '',
      args: [],
    );
  }

  /// `Customer Service`
  String get userStatusCustomerService {
    return Intl.message(
      'Customer Service',
      name: 'userStatusCustomerService',
      desc: '',
      args: [],
    );
  }

  /// `Dark Mode`
  String get userStatusDarkMode {
    return Intl.message(
      'Dark Mode',
      name: 'userStatusDarkMode',
      desc: '',
      args: [],
    );
  }

  /// `Theme`
  String get userStatusTheme {
    return Intl.message(
      'Theme',
      name: 'userStatusTheme',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get userStatusSettings {
    return Intl.message(
      'Settings',
      name: 'userStatusSettings',
      desc: '',
      args: [],
    );
  }

  /// `Check App Update`
  String get userStatusCheckAppUpdate {
    return Intl.message(
      'Check App Update',
      name: 'userStatusCheckAppUpdate',
      desc: '',
      args: [],
    );
  }

  /// `Upload`
  String get upload {
    return Intl.message(
      'Upload',
      name: 'upload',
      desc: '',
      args: [],
    );
  }

  /// `Waiting another to join`
  String get voiceCallWaitAnotherToJoin {
    return Intl.message(
      'Waiting another to join',
      name: 'voiceCallWaitAnotherToJoin',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get viewStateButtonRetry {
    return Intl.message(
      'Retry',
      name: 'viewStateButtonRetry',
      desc: '',
      args: [],
    );
  }

  /// `Refresh`
  String get viewStateButtonRefresh {
    return Intl.message(
      'Refresh',
      name: 'viewStateButtonRefresh',
      desc: '',
      args: [],
    );
  }

  /// `Sign In`
  String get viewStateButtonLogin {
    return Intl.message(
      'Sign In',
      name: 'viewStateButtonLogin',
      desc: '',
      args: [],
    );
  }

  /// `Empty`
  String get viewStateMessageEmpty {
    return Intl.message(
      'Empty',
      name: 'viewStateMessageEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Not Sign in yet`
  String get viewStateMessageUnAuth {
    return Intl.message(
      'Not Sign in yet',
      name: 'viewStateMessageUnAuth',
      desc: '',
      args: [],
    );
  }

  /// `Network Error`
  String get viewStateMessageNetworkError {
    return Intl.message(
      'Network Error',
      name: 'viewStateMessageNetworkError',
      desc: '',
      args: [],
    );
  }

  /// `Load Failed`
  String get viewStateMessageError {
    return Intl.message(
      'Load Failed',
      name: 'viewStateMessageError',
      desc: '',
      args: [],
    );
  }

  /// `You must accept permissions`
  String get youMustAcceptPermission {
    return Intl.message(
      'You must accept permissions',
      name: 'youMustAcceptPermission',
      desc: '',
      args: [],
    );
  }

  /// `You need to allow Microphone permission to enable voice call`
  String get youNeedToAllowMicroPermission {
    return Intl.message(
      'You need to allow Microphone permission to enable voice call',
      name: 'youNeedToAllowMicroPermission',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'my'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    if (locale != null) {
      for (var supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}