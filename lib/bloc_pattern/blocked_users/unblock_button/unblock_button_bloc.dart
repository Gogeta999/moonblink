import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moonblink/bloc_pattern/blocked_users/unblock_button/bloc.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/utils/constants.dart';

class UnblockButtonBloc extends Bloc<UnblockButtonEvent, UnblockButtonState> {

  UnblockButtonBloc() : super(Initial());

  @override
  Stream<UnblockButtonState> mapEventToState(UnblockButtonEvent event) async* {
    if (event is Remove) {
      yield* _mapRemoveToState(event);
    }
    if (event is Reset) {
      yield Initial();
    }
  }

  Stream<UnblockButtonState> _mapRemoveToState(Remove event) async* {
    try {
      yield Loading();
      await MoonBlinkRepository.blockOrUnblock(event.blockUserId, UNBLOCK);
      yield Success();
    } catch(error) {
      yield Failed(error: error);
    }
  }
}