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

  /// `Check App Update`
  String get appUpdateCheck {
    return Intl.message(
      'Check App Update',
      name: 'appUpdateCheck',
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
  String get confirmBook {
    return Intl.message(
      'Book',
      name: 'confirmBook',
      desc: '',
      args: [],
    );
  }

  /// `Dark Mode`
  String get darkMode {
    return Intl.message(
      'Dark Mode',
      name: 'darkMode',
      desc: '',
      args: [],
    );
  }

  /// `favorite`
  String get favorites {
    return Intl.message(
      'favorite',
      name: 'favorites',
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

  /// `Search`
  String get search {
    return Intl.message(
      'Search',
      name: 'search',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
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

  /// `Theme`
  String get theme {
    return Intl.message(
      'Theme',
      name: 'theme',
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

  /// `hello`
  String get hello {
    return Intl.message(
      'hello',
      name: 'hello',
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