import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/models/BoostGame.dart';
import 'package:moonblink/services/locator.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/services/navigation_service.dart';
import 'package:oktoast/oktoast.dart';
import 'package:rxdart/rxdart.dart';

part 'boosting_game_detail_event.dart';
part 'boosting_game_detail_state.dart';

class BoostingGameDetailBloc extends Bloc<BoostingGameDetailEvent, BoostingGameDetailState> {
  final int id;
  BoostingGameDetailBloc(this.id) : super(BoostingGameDetailInitial());

  final gameListSubject = BehaviorSubject<List<BoostGame>>.seeded(null);
  final submitButtonSubject = BehaviorSubject.seeded(false);

  void init() {
    MoonBlinkRepository.getBoostGame(id).then((value) {
      gameListSubject.add(value);
    }, onError: (e) => gameListSubject.addError(e));
  }

  void dispose() {
    gameListSubject.close();

    this.close();
  }

  BuildContext get context => locator<NavigationService>().navigatorKey.currentContext;

  @override
  Stream<BoostingGameDetailState> mapEventToState(
    BoostingGameDetailEvent event,
  ) async* {}

  void submit() {
    submitButtonSubject.add(true);
    gameListSubject.first.then((value) {
      bool valid = false;
      List<Map<String, dynamic>> jsonList = [];
      value.forEach((element) {
        if(!valid) {
          valid = element.estimateCost > 0 && (element.estimateDay > 0 || element.estimateHour > 0);
        }
        jsonList.add(element.toJson());
      });
      if (!valid) {
        showToast('At leat one rank need to proceed');
        submitButtonSubject.add(false);
        return;
      }
      MoonBlinkRepository.setBoostGameProfile(jsonList, id).then((value) {
        showToast('Upload Success');
        submitButtonSubject.add(false);
        Navigator.pop(context, true);
      }, onError: (e) {
        submitButtonSubject.add(false);
        showToast('$e');
      });
    });
  }
}