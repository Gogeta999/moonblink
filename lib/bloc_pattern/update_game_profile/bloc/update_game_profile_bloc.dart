import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/game_profile.dart';
import 'package:moonblink/services/locator.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/services/navigation_service.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:oktoast/oktoast.dart';
import 'package:rxdart/subjects.dart';

part 'update_game_profile_event.dart';
part 'update_game_profile_state.dart';

enum UpdateOrSubmitButtonState { initial, loading }

class UpdateGameProfileBloc
    extends Bloc<UpdateGameProfileEvent, UpdateGameProfileState> {
  UpdateGameProfileBloc(this.gameProfile) : super(UpdateGameProfileInitial());

  final GameProfile gameProfile;

  ///will send back to server
  ///Booking
  final TextEditingController gameIdController = TextEditingController();
  final bookingSwitchSubject = BehaviorSubject.seeded(false);
  final levelSubject = BehaviorSubject<String>.seeded('');
  final gameModeSubject = BehaviorSubject<String>.seeded('');
  final gameModeListSubject = BehaviorSubject<List<GameMode>>.seeded(null);
  final List<Map<String, int>> selectedGameModeIndex = [];
  final skillCoverPhotoSubject = BehaviorSubject<File>.seeded(null);

  ///Boosting
  final boostingSwitchSubject = BehaviorSubject.seeded(false);
  final boostingLevelSubject = BehaviorSubject.seeded('');

  ///Up_To_Rank

  ///UI properties
  bool isUILocked = false;
  final submitOrUpdateSubject =
      BehaviorSubject.seeded(UpdateOrSubmitButtonState.initial);
  List<Widget> cupertinoActionSheet = [];
  List<Widget> cupertinoActionSheetForBoosting = [];
  TextStyle textStyle;

  void dispose() {
    gameIdController.clear();
    levelSubject.close();
    gameModeSubject.close();
    gameModeListSubject.close();
    skillCoverPhotoSubject.close();
    submitOrUpdateSubject.close();
    bookingSwitchSubject.close();
    boostingSwitchSubject.close();
    boostingLevelSubject.close();
    this.close();
    print('Disposing UpdateGameProfile Success');
  }

  @override
  Stream<UpdateGameProfileState> mapEventToState(
    UpdateGameProfileEvent event,
  ) async* {}

  get context => locator<NavigationService>().navigatorKey.currentContext;

  void onChangedBookingSwitch(bool value) {
    if (isUILocked) return;
    bookingSwitchSubject.add(value);
  }

  void onChangedBoostingSwitch(bool value) {
    if (isUILocked) return;
    boostingSwitchSubject.add(value);
  }

  void initWithRemoteData() {
    gameModeListSubject.add(gameProfile.gameModeList);
    gameIdController.text = gameProfile.playerId;
    levelSubject.add(gameProfile.level);
    boostingLevelSubject.add(gameProfile.upToRank);

    ///booking level
    if (gameProfile.isPlay == 1) bookingSwitchSubject.add(true);
    //boosting
    if (gameProfile.boostable == 1) boostingSwitchSubject.add(true);

    gameModeListSubject.first.then((value) {
      for (int i = 0; i < value.length; ++i) {
        if (value[i].selected == 1) {
          selectedGameModeIndex.add({value[i].id.toString(): value[i].price});
        }
      }

      updateGameMode();

      gameProfile.gameRankList.forEach((element) {
        cupertinoActionSheet.add(
          CupertinoActionSheetAction(
              onPressed: () {
                levelSubject.add(element);
                Navigator.pop(context);
              },
              child: Text(element, style: textStyle)),
        );

        cupertinoActionSheetForBoosting.add(
          CupertinoActionSheetAction(
              onPressed: () {
                boostingLevelSubject.add(element);
                Navigator.pop(context);
              },
              child: Text(element, style: textStyle)),
        );
      });
    });
  }

  void updateGameMode() {
    gameModeListSubject.first.then((gameModeList) {
      String newGameMode = '';
      gameModeList.asMap().forEach((index, element) {
        selectedGameModeIndex.forEach((e) {
          if (e.containsKey(element.id.toString())) {
            newGameMode += element.mode;
            if (index < selectedGameModeIndex.length - 1) {
              newGameMode += ', ';
            }
            return;
          }
        });
      });
      gameModeSubject.add(newGameMode);
    });
  }

  void onSubmitOrUpdate() async {
    if (gameIdController.text.isEmpty) {
      showToast('Game ID ${G.of(context).cannotblank}');
      return;
    }
    final level = await levelSubject.first;
    if (level.isEmpty) {
      showToast('Level ${G.of(context).cannotblank}');
      return;
    }

    final skillCoverPhoto = await skillCoverPhotoSubject.first;
    if ((gameProfile.isPlay == 0 && gameProfile.boostable == 0) && skillCoverPhoto == null) {
      showToast('ScreenShot ${G.of(context).cannotblank}');
      return;
    }

    MultipartFile skillCoverImage;
    if (skillCoverPhoto != null) {
      skillCoverImage = await MultipartFile.fromFile(skillCoverPhoto.path);
    }

    final bool bookable = await bookingSwitchSubject.first;
    final bool boostable = await boostingSwitchSubject.first;

    //No service provided show error
    if (!bookable && !boostable) {
      showToast('You need to provide at least one service');
      return;
    }

    ///Will provide only booking service
    if (bookable && !boostable) {
      if (selectedGameModeIndex.isEmpty) {
        showToast('Game Mode ${G.of(context).cannotblank} for Booking service');
        return;
      }

      ///validation success. send data to server.
      _freezeUI();
      List<String> mapKeys = [
        'game_id',
        'player_id',
        'level',
        if (skillCoverImage != null) 'skill_cover_image',
        'about_order_taking',
        'types',
        'boostable',
        'is_play',
        'up_to_rank'
      ];
      List<dynamic> mapValues = [
        gameProfile.gameId,
        gameIdController.text,
        level,
        if (skillCoverImage != null) skillCoverImage,
        '',
        selectedGameModeIndex,
        boostable ? 1 : 0,
        bookable ? 1 : 0,
        ''
      ];
      Map<String, dynamic> gameProfileMap =
          Map.fromIterables(mapKeys, mapValues);
      gameProfileMap.forEach((key, value) {
        print(key + ': ' + '$value');
      });
      MoonBlinkRepository.updateGameProfile(gameProfileMap).then((value) {
        showToast(G.of(context).toastsuccess);
        if (gameProfile.isPlay == 0) {
          StorageManager.sharedPreferences.setInt(mgameprofile,
              StorageManager.sharedPreferences.getInt(mgameprofile) + 1);
          print("GAMEPROFILE COUNT IS " +
              StorageManager.sharedPreferences.getInt(mgameprofile).toString());
        }
        Navigator.pop(context, true);
      }, onError: (e) => {showToast(e.toString()), _unfreezeUI()});
    }

    ///Will provide only boosting service
    if (!bookable && boostable) {
      final boostingLevel = await boostingLevelSubject.first;
      if (boostingLevel == null || boostingLevel.isEmpty) {
        showToast(
            'Highest Rank ${G.of(context).cannotblank} for Boosting service');
        return;
      }

      ///validation success. send data to server.
      _freezeUI();
      List<String> mapKeys = [
        'game_id',
        'player_id',
        'level',
        if (skillCoverImage != null) 'skill_cover_image',
        'about_order_taking',
        'types',
        'boostable',
        'is_play',
        'up_to_rank'
      ];
      List<dynamic> mapValues = [
        gameProfile.gameId,
        gameIdController.text,
        level,
        if (skillCoverImage != null) skillCoverImage,
        '',
        [],
        boostable ? 1 : 0,
        bookable ? 1 : 0,
        boostingLevel
      ];
      Map<String, dynamic> gameProfileMap =
          Map.fromIterables(mapKeys, mapValues);
      gameProfileMap.forEach((key, value) {
        print(key + ': ' + '$value');
      });
      MoonBlinkRepository.updateGameProfile(gameProfileMap).then((value) {
        showToast(G.of(context).toastsuccess);
        if (gameProfile.isPlay == 0) {
          StorageManager.sharedPreferences.setInt(mgameprofile,
              StorageManager.sharedPreferences.getInt(mgameprofile) + 1);
          print("GAMEPROFILE COUNT IS " +
              StorageManager.sharedPreferences.getInt(mgameprofile).toString());
        }
        Navigator.pop(context, true);
      }, onError: (e) => {showToast(e.toString()), _unfreezeUI()});
    }
    //Will provide both services
    if (bookable && boostable) {
      if (selectedGameModeIndex.isEmpty) {
        showToast('Game Mode ${G.of(context).cannotblank} for Booking service');
        return;
      }
      final boostingLevel = await boostingLevelSubject.first;
      if (boostingLevel == null || boostingLevel.isEmpty) {
        showToast(
            'Highest Rank ${G.of(context).cannotblank} for Boosting service');
        return;
      }

      ///validation success. send data to server.
      _freezeUI();
      List<String> mapKeys = [
        'game_id',
        'player_id',
        'level',
        if (skillCoverImage != null) 'skill_cover_image',
        'about_order_taking',
        'types',
        'boostable',
        'is_play',
        'up_to_rank'
      ];
      List<dynamic> mapValues = [
        gameProfile.gameId,
        gameIdController.text,
        level,
        if (skillCoverImage != null) skillCoverImage,
        '',
        selectedGameModeIndex,
        boostable ? 1 : 0,
        bookable ? 1 : 0,
        boostingLevel
      ];
      Map<String, dynamic> gameProfileMap =
          Map.fromIterables(mapKeys, mapValues);
      gameProfileMap.forEach((key, value) {
        print(key + ': ' + '$value');
      });
      MoonBlinkRepository.updateGameProfile(gameProfileMap).then((value) {
        showToast(G.of(context).toastsuccess);
        if (gameProfile.isPlay == 0) {
          StorageManager.sharedPreferences.setInt(mgameprofile,
              StorageManager.sharedPreferences.getInt(mgameprofile) + 1);
          print("GAMEPROFILE COUNT IS " +
              StorageManager.sharedPreferences.getInt(mgameprofile).toString());
        }
        Navigator.pop(context, true);
      }, onError: (e) => {showToast(e.toString()), _unfreezeUI()});
    }
  }

  _freezeUI() {
    isUILocked = true;
    submitOrUpdateSubject.add(UpdateOrSubmitButtonState.loading);
  }

  _unfreezeUI() {
    isUILocked = false;
    submitOrUpdateSubject.add(UpdateOrSubmitButtonState.initial);
  }
}
