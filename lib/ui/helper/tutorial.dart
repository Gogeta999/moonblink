import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/utils/constants.dart';

String hometuto = 'hometuto';
String userstatustuto = 'userstatustuto';
String bookingtuto = 'bookingtuto';
String userdetailtuto = 'userdetailtuto';
String partnerBoostDetail = 'partnerBoostDetail';
String chatboxtuto = 'chatboxtuto';
String boostingrequesttuto = 'boostingrequesttuto';
String firsttuto = 'first tuto';

void tutorialOn() {
  StorageManager.sharedPreferences.setBool(hometuto, true);
  StorageManager.sharedPreferences.setBool(bookingtuto, true);
  StorageManager.sharedPreferences.setBool(userdetailtuto, true);
  StorageManager.sharedPreferences.setBool(chatboxtuto, true);
  StorageManager.sharedPreferences.setBool(boostingrequesttuto, true);
  StorageManager.sharedPreferences.setBool(partnerBoostDetail, true);
  StorageManager.sharedPreferences.setBool(kNewToBoosting, true);
}
