import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moonblink/api/moonblink_dio.dart';
import 'package:moonblink/bloc_pattern/update_game_profile/bloc/update_game_profile_bloc.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/user_play_game.dart';
import 'package:moonblink/services/locator.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/services/navigation_service.dart';
import 'package:moonblink/ui/pages/game_profile/update_game_profile_page.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:oktoast/oktoast.dart';
import 'package:rxdart/subjects.dart';

part 'game_profile_event.dart';
part 'game_profile_state.dart';

enum DeselectState { initial, loading }

class GameProfileBloc extends Bloc<GameProfileEvent, GameProfileState> {
  GameProfileBloc() : super(GameProfileInitial());

  final userPlayGameListSubject =
      BehaviorSubject<UserPlayGameList>.seeded(null);

  final deselectSubject = BehaviorSubject.seeded(DeselectState.initial);

  void dispose() {
    userPlayGameListSubject.close();
    deselectSubject.close();
    this.close();
    if (isDev) print('Disposing GameProfileBloc Success');
  }

  @override
  Stream<GameProfileState> mapEventToState(
    GameProfileEvent event,
  ) async* {}

  get context => locator<NavigationService>().navigatorKey.currentContext;

  void fetchGameProfile() {
    MoonBlinkRepository.getUserPlayGameList().then((value) {
      userPlayGameListSubject.add(value);
    }, onError: (e) => userPlayGameListSubject.addError(e));
  }

  void onTapDeselect(UserPlayGame item) {
    ///call delete api
    deselectSubject.add(DeselectState.loading);
    MoonBlinkRepository.deleteGameProfile(item.gameProfile.gameId).then(
        (value) {
      deselectSubject.add(DeselectState.initial);
      StorageManager.sharedPreferences.setInt(mgameprofile,
          StorageManager.sharedPreferences.getInt(mgameprofile) - 1);

      ///After delete, fetch data from server again
      this.fetchGameProfile();
    }, onError: (err) {
      deselectSubject.add(DeselectState.initial);
      showToast(err.toString());
    });
  }

  void onTapListTile(UserPlayGame item, GameProfileBloc bloc) {
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => BlocProvider(
                  create: (_) => UpdateGameProfileBloc(item.gameProfile),
                  child: UpdateGameProfilePage(),
                ))).then((value) {
      if (value != null && value) this.fetchGameProfile();
    });
  }
}
