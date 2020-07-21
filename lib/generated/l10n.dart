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

  /// `Follow`
  String get detailPageFollow {
    return Intl.message(
      'Follow',
      name: 'detailPageFollow',
      desc: '',
      args: [],
    );
  }

  /// `Following`
  String get detailPageFollowing {
    return Intl.message(
      'Following',
      name: 'detailPageFollowing',
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

  /// `Favorite`
  String get userStatusFavorite {
    return Intl.message(
      'Favorite',
      name: 'userStatusFavorite',
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