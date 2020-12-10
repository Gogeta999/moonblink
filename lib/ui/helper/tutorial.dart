import 'package:moonblink/global/storage_manager.dart';

String hometuto = 'hometuto';
String userstatustuto = 'userstatustuto';
String bookingtuto = 'bookingtuto';
String userdetailtuto = 'userdetailtuto';
String chatboxtuto = 'chatboxtuto';
String boostingrequesttuto = 'boostingrequesttuto';

void tutorialOn() {
  StorageManager.sharedPreferences.setBool(hometuto, true);
  StorageManager.sharedPreferences.setBool(bookingtuto, true);
  StorageManager.sharedPreferences.setBool(userdetailtuto, true);
  StorageManager.sharedPreferences.setBool(chatboxtuto, true);
  StorageManager.sharedPreferences.setBool(boostingrequesttuto, true);
}
