import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/chat_models/booking_status.dart';
import 'package:moonblink/models/chat_models/last_message.dart';
import 'package:moonblink/models/partner.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/utils/constants.dart';
import 'package:moonblink/utils/platform_utils.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:rxdart/rxdart.dart';
import 'package:moonblink/services/web_socket_service.dart';
import 'package:intl/intl.dart';

part 'chat_box_event.dart';
part 'chat_box_state.dart';

const int _limit = 20;
const int _buttonSeconds = 300;

class ChatBoxBloc extends Bloc<ChatBoxEvent, ChatBoxState> {
  ChatBoxBloc(this.partnerId) : super(ChatBoxInitial());

  ChatBoxBloc.initNormal(this.partnerId) : super(ChatBoxInitial()) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final firstBefore =
        (StorageManager.sharedPreferences.getInt(firstKey) ?? 0) ~/ 1000;
    final firstLeftTime =
        StorageManager.sharedPreferences.getInt(firstLeftKey) ?? 0;
    print(
        'Disposing - now-firstBefore: ${now - firstBefore} firstLeftTime:$firstLeftTime');
    if (firstLeftTime > now - firstBefore) {
      _firstTotal = firstLeftTime - (now - firstBefore);
      _firstStartCounting();
    } else {
      firstButtonSubject.add('');
    }

    final secondBefore =
        (StorageManager.sharedPreferences.getInt(secondKey) ?? 0) ~/ 1000;
    final secondLeftTime =
        StorageManager.sharedPreferences.getInt(secondLeftKey) ?? 0;
    print(
        'Disposing - now-secondBefore: ${now - secondBefore} secondLeftTime:$secondLeftTime');
    if (secondLeftTime > now - secondBefore) {
      _secondTotal = secondLeftTime - (now - secondBefore);
      _secondStartCounting();
    } else {
      secondButtonSubject.add('');
    }

    final thirdBefore =
        (StorageManager.sharedPreferences.getInt(thirdKey) ?? 0) ~/ 1000;
    final thirdLeftTime =
        StorageManager.sharedPreferences.getInt(thirdLeftKey) ?? 0;
    print(
        'Disposing - now-thidBefore: ${now - thirdBefore} thirdLeftTime:$thirdLeftTime');
    if (thirdLeftTime > now - thirdBefore) {
      _thirdTotal = thirdLeftTime - (now - thirdBefore);
      _thirdStartCounting();
    } else {
      thirdButtonSubject.add('');
    }
  }

  /// it's also other user id
  final int partnerId;
  final int myId = StorageManager.sharedPreferences.getInt(mUserId);

  final bookingStatusSubject = BehaviorSubject<BookingStatus>.seeded(null);
  final partnerUserSubject = BehaviorSubject<PartnerUser>.seeded(null);

  ///Button State
  final bookingCancelButtonSubject = BehaviorSubject.seeded(false);
  final callButtonSubject = BehaviorSubject.seeded(false);
  final rejectButtonSubject = BehaviorSubject.seeded(false);
  final acceptButtonSubject = BehaviorSubject.seeded(false);
  final firstButtonSubject = BehaviorSubject<String>.seeded(null);
  final secondButtonSubject = BehaviorSubject<String>.seeded(null);
  final thirdButtonSubject = BehaviorSubject<String>.seeded(null);
  Timer _firstTimer;
  Timer _secondTimer;
  Timer _thirdTimer;

  int _firstTotal = -1;
  int _secondTotal = -1;
  int _thirdTotal = -1;

  final TextEditingController messageController = TextEditingController();

  //Staring time
  String get firstKey => 'first_' + kPartnerId + '_$partnerId';
  //Remaining time
  String get firstLeftKey => 'first_left' + kPartnerId + '_$partnerId';
  String get secondKey => 'second_' + kPartnerId + '_$partnerId';
  String get secondLeftKey => 'second_left' + kPartnerId + '_$partnerId';
  String get thirdKey => 'third_' + kPartnerId + '_$partnerId';
  String get thirdLeftKey => 'third_left' + kPartnerId + '_$partnerId';

  void dispose() {
    List<Future> futures = [
      bookingStatusSubject.close(),
      partnerUserSubject.close(),
      bookingCancelButtonSubject.close(),
      callButtonSubject.close(),
      rejectButtonSubject.close(),
      acceptButtonSubject.close(),
      firstButtonSubject.close(),
      secondButtonSubject.close(),
      thirdButtonSubject.close(),
      this.close()
    ];
    _firstTimer?.cancel();
    _secondTimer?.cancel();
    _thirdTimer?.cancel();
    messageController.dispose();
    Future.wait(futures);
    saveTimer();
    print('Disposing ChatBoxBloc Success');
  }

  void saveTimer() {
    if (_firstTotal > 0) {
      StorageManager.sharedPreferences
          .setInt(firstKey, DateTime.now().millisecondsSinceEpoch);
      StorageManager.sharedPreferences.setInt(firstLeftKey, _firstTotal);
    } else {
      StorageManager.sharedPreferences
          .setInt(firstKey, DateTime.now().millisecondsSinceEpoch);
      StorageManager.sharedPreferences.setInt(firstLeftKey, -1);
    }
    if (_secondTotal > 0) {
      StorageManager.sharedPreferences
          .setInt(secondKey, DateTime.now().millisecondsSinceEpoch);
      StorageManager.sharedPreferences.setInt(secondLeftKey, _secondTotal);
    } else {
      StorageManager.sharedPreferences
          .setInt(secondKey, DateTime.now().millisecondsSinceEpoch);
      StorageManager.sharedPreferences.setInt(secondLeftKey, -1);
    }
    if (_thirdTotal > 0) {
      StorageManager.sharedPreferences
          .setInt(thirdKey, DateTime.now().millisecondsSinceEpoch);
      StorageManager.sharedPreferences.setInt(thirdLeftKey, _thirdTotal);
    } else {
      StorageManager.sharedPreferences
          .setInt(thirdKey, DateTime.now().millisecondsSinceEpoch);
      StorageManager.sharedPreferences.setInt(thirdLeftKey, -1);
    }
  }

  @override
  Stream<ChatBoxState> mapEventToState(
    ChatBoxEvent event,
  ) async* {
    final currentState = state;
    if (event is ChatBoxFetched) {
      yield* _mapFetchedToState(currentState);
    }
    if (event is ChatBoxFetchedMore && !_hasReachedMax(currentState)) {
      yield* _mapFetchedMoreToState(currentState);
    }
    if (event is ChatBoxCancelBooking)
      yield* _mapCancelBookingToState(currentState);
    if (event is ChatBoxCall)
      yield* _mapCallToState(currentState, event.channel, event.receiverId);
    if (event is ChatBoxEndBooking) yield* _mapEndBookingToState(currentState);
    if (event is ChatBoxRejectBooking)
      yield* _mapRejectBookingToState(currentState);
    if (event is ChatBoxAcceptBooking)
      yield* _mapAcceptBookingToState(currentState);
    if (event is ChatBoxSendMessage)
      yield* _mapSendMessageToState(currentState);
    if (event is ChatBoxSendImage)
      yield* _mapSendImageToState(currentState, event.image);
    if (event is ChatBoxSendAudio)
      yield* _mapSendAudioToState(currentState, event.audio);
    if (event is ChatBoxReceiveMessage)
      yield* _mapReceiveMessageToState(
          currentState,
          event.message,
          event.senderId,
          event.receiverId,
          event.time,
          event.attach,
          event.type);
    if (event is ChatBoxCheckAvailable)
      yield* _mapCheckAvailableToState(currentState);
    if (event is ChatBoxSecondButton)
      yield* _mapSecondButtonToState(currentState);
    if (event is ChatBoxThirdButton)
      yield* _mapThirdButtonToState(currentState);
  }

  Stream<ChatBoxState> _mapFetchedToState(ChatBoxState currentState) async* {
    List<LastMessage> data = [];
    MoonBlinkRepository.fetchPartner(partnerId)
        .then((value) => partnerUserSubject.add(value), onError: (e) async* {
      yield ChatBoxFailure(error: e);
    });
    try {
      data = await _fetchLastMessages(limit: _limit, page: 1);
      bool hasReachedMax = data.length < _limit ? true : false;
      yield ChatBoxSuccess(data: data, hasReachedMax: hasReachedMax, page: 1);
    } catch (e) {
      yield ChatBoxSuccess(data: data, hasReachedMax: true, page: 1);
    }
  }

  Stream<ChatBoxState> _mapFetchedMoreToState(
      ChatBoxState currentState) async* {
    if (currentState is ChatBoxSuccess) {
      final nextPage = currentState.page + 1;
      try {
        List<LastMessage> data =
            await _fetchLastMessages(limit: _limit, page: nextPage);
        bool hasReachedMax = data.length < _limit ? true : false;
        yield data.isEmpty
            ? currentState.copyWith(hasReachedMax: true)
            : ChatBoxSuccess(
                data: currentState.data + data,
                hasReachedMax: hasReachedMax,
                page: nextPage);
      } catch (error) {
        yield ChatBoxFailure(error: error);
      }
    }
  }

  Stream<ChatBoxState> _mapCancelBookingToState(
      ChatBoxState currentState) async* {
    if (currentState is ChatBoxSuccess) {
      try {
        bookingCancelButtonSubject.add(true);
        final bookingStatus = await bookingStatusSubject.first;
        await MoonBlinkRepository.endbooking(
            myId, bookingStatus.bookingId, CANCEL);
        yield ChatBoxCancelBookingSuccess();
        bookingCancelButtonSubject.add(false);
        yield currentState.copyWith();
      } catch (e) {
        yield ChatBoxCancelBookingFailure(e);
        bookingCancelButtonSubject.add(false);
        yield currentState.copyWith();
      }
    }
  }

  Stream<ChatBoxState> _mapEndBookingToState(ChatBoxState currentState) async* {
    if (currentState is ChatBoxSuccess) {
      try {
        final bookingStatus = await bookingStatusSubject.first;
        await MoonBlinkRepository.endbooking(
            myId, bookingStatus.bookingId, DONE);
        yield ChatBoxEndBookingSuccess();
        yield currentState.copyWith();
      } catch (e) {
        yield ChatBoxEndBookingFailure(e);
        yield currentState.copyWith();
      }
    }
  }

  Stream<ChatBoxState> _mapRejectBookingToState(
      ChatBoxState currentState) async* {
    if (currentState is ChatBoxSuccess) {
      try {
        rejectButtonSubject.add(true);
        final bookingStatus = await bookingStatusSubject.first;
        await MoonBlinkRepository.bookingAcceptOrDecline(
            myId, bookingStatus.bookingId, REJECT);
        yield ChatBoxRejectBookingSuccess();
        rejectButtonSubject.add(false);
        yield currentState.copyWith();
      } catch (e) {
        yield ChatBoxRejectBookingFailure(e);
        rejectButtonSubject.add(false);
        yield currentState.copyWith();
      }
    }
  }

  Stream<ChatBoxState> _mapAcceptBookingToState(
      ChatBoxState currentState) async* {
    if (currentState is ChatBoxSuccess) {
      try {
        acceptButtonSubject.add(true);
        final bookingStatus = await bookingStatusSubject.first;
        await MoonBlinkRepository.bookingAcceptOrDecline(
            myId, bookingStatus.bookingId, ACCEPTED);
        yield ChatBoxAcceptBookingSuccess();
        acceptButtonSubject.add(false);
        yield currentState.copyWith();
      } catch (e) {
        yield ChatBoxAcceptBookingFailure(e);
        acceptButtonSubject.add(false);
        yield currentState.copyWith();
      }
    }
  }

  Stream<ChatBoxState> _mapCallToState(
      ChatBoxState currentState, String channel, int id) async* {
    if (currentState is ChatBoxSuccess) {
      try {
        callButtonSubject.add(true);
        await MoonBlinkRepository.call(channel, id);
        yield ChatBoxCallSuccess(channel);
        callButtonSubject.add(false);
        yield currentState.copyWith();
      } catch (e) {
        yield ChatBoxCallFailure(e);
        callButtonSubject.add(false);
        yield currentState.copyWith();
      }
    }
  }

  Stream<ChatBoxState> _mapSendMessageToState(
      ChatBoxState currentState) async* {
    if (currentState is ChatBoxSuccess && messageController.text.isNotEmpty) {
      final text = messageController.text;
      messageController.clear();
      WebSocketService().sendMessage(text, partnerId);
      DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
      final now = dateFormat.format(DateTime.now());
      // final id =
      //     currentState.data.isNotEmpty ? currentState.data.last.id + 1 : 1;
      // final roomId =
      //     currentState.data.isNotEmpty ? currentState.data.last.roomId : 0;
      final senderId = myId;
      final receiverId = partnerId;
      final newMessage = text;
      final type = MESSAGE;
      final attach = '';
      final createdAt = now;
      final updatedAt = now;
      final lastMessage = LastMessage(1, 0, senderId, receiverId, newMessage,
          type, attach, createdAt, updatedAt);
      final List<LastMessage> data = List.from(currentState.data);
      data.insert(0, lastMessage);
      yield currentState.copyWith(data: data);
    }
  }

  Stream<ChatBoxState> _mapSendImageToState(
      ChatBoxState currentState, File image) async* {
    if (currentState is ChatBoxSuccess) {
      messageController.clear();
      final now = DateTime.now().millisecondsSinceEpoch.toString();
      String fileName = myId.toString() + now + ".jpg";
      WebSocketService()
          .sendImage(fileName, image.readAsBytesSync(), partnerId);
      // final id =
      //     currentState.data.isNotEmpty ? currentState.data.last.id + 1 : 1;
      // final roomId =
      //     currentState.data.isNotEmpty ? currentState.data.last.roomId : 0;
      final lastMessage = LastMessage(
          1, 0, myId, partnerId, '', IMAGE, image.absolute.path, now, now);
      final List<LastMessage> data = List.from(currentState.data);
      data.insert(0, lastMessage);
      yield currentState.copyWith(data: data);
    }
  }

  Stream<ChatBoxState> _mapSendAudioToState(
      ChatBoxState currentState, File audio) async* {
    if (currentState is ChatBoxSuccess) {
      messageController.clear();
      final now = DateTime.now().millisecondsSinceEpoch.toString();
      String fileName = myId.toString() + now + ".wav";
      WebSocketService()
          .sendAudio(fileName, audio.readAsBytesSync(), partnerId);
      // final id =
      //     currentState.data.isNotEmpty ? currentState.data.last.id + 1 : 1;
      // final roomId =
      //     currentState.data.isNotEmpty ? currentState.data.last.roomId : 0;
      final lastMessage = LastMessage(
          1, 0, myId, partnerId, '', AUDIO, audio.absolute.path, now, now);
      final List<LastMessage> data = List.from(currentState.data);
      data.insert(0, lastMessage);
      yield currentState.copyWith(data: data);
    }
  }

  Stream<ChatBoxState> _mapReceiveMessageToState(
      ChatBoxState currentState,
      String message,
      int senderId,
      int receiverId,
      String time,
      String attach,
      int type) async* {
    if (currentState is ChatBoxSuccess) {
      // final id =
      //     currentState.data.isNotEmpty ? currentState.data.last.id + 1 : 1;
      // final roomId =
      //     currentState.data.isNotEmpty ? currentState.data.last.roomId : 0;
      final lastMessage = LastMessage(
          1, 0, senderId, receiverId, message, type, attach, time, time);
      final List<LastMessage> data = List.from(currentState.data);
      data.insert(0, lastMessage);
      yield currentState.copyWith(data: data);
    }
  }

  Stream<ChatBoxState> _mapCheckAvailableToState(
      ChatBoxState currentState) async* {
    if (currentState is ChatBoxSuccess) {
      final newMessage = 'Are you available?';
      WebSocketService().sendMessage(newMessage, partnerId);

      _firstTotal = _buttonSeconds;
      firstButtonSubject.add('5 : 00');
      _firstStartCounting();

      DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
      final now = dateFormat.format(DateTime.now());
      // final id =
      //     currentState.data.isNotEmpty ? currentState.data.last.id + 1 : 1;
      // final roomId =
      //     currentState.data.isNotEmpty ? currentState.data.last.roomId : 0;
      final senderId = myId;
      final receiverId = partnerId;
      final type = MESSAGE;
      final attach = '';
      final createdAt = now;
      final updatedAt = now;
      print('%id');
      final lastMessage = LastMessage(1, 0, senderId, receiverId, newMessage,
          type, attach, createdAt, updatedAt);
      final List<LastMessage> data = List.from(currentState.data);
      data.insert(0, lastMessage);
      yield currentState.copyWith(data: data);
    }
  }

  Stream<ChatBoxState> _mapSecondButtonToState(
      ChatBoxState currentState) async* {
    if (currentState is ChatBoxSuccess) {
      _secondTotal = _buttonSeconds;
      secondButtonSubject.add('5 : 00');
      _secondStartCounting();

      DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
      final now = dateFormat.format(DateTime.now());
      final newMessage =
          'Auto-Reply\nကျေးဇူးပြု၍ အောက်ကLink ကိုနှိပ်ပြီး Moon Go pageမှ ဝယ်ယူပါ။\nPlease go to MoonGo page and buy coin.\nhttps://www.facebook.com/MoonblinkUniverse/videos/3552024048229706/';
      // final id =
      //     currentState.data.isNotEmpty ? currentState.data.last.id + 1 : 1;
      // final roomId =
      //     currentState.data.isNotEmpty ? currentState.data.last.roomId : 0;
      final senderId = partnerId;
      final receiverId = myId;
      final type = MESSAGE;
      final attach = '';
      final createdAt = now;
      final updatedAt = now;
      final lastMessage = LastMessage(1, 0, senderId, receiverId, newMessage,
          type, attach, createdAt, updatedAt);
      final List<LastMessage> data = List.from(currentState.data);
      data.insert(0, lastMessage);
      yield currentState.copyWith(data: data);
    }
  }

  Stream<ChatBoxState> _mapThirdButtonToState(
      ChatBoxState currentState) async* {
    if (currentState is ChatBoxSuccess) {
      _thirdTotal = _buttonSeconds;
      thirdButtonSubject.add('5 : 00');
      _thirdStartCounting();

      DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
      final now = dateFormat.format(DateTime.now());
      final newMessage =
          'Auto-Reply\nကျေးဇူးပြု၍ အောက်ကLink ကိုနှိပ်ပြီး Moon Go pageမှ လေ့လာပေးပါ။\nPlease go to MoonGo page and check how to book.\nhttps://www.facebook.com/MoonblinkUniverse/videos/1359862744362719/';
      // final id =
      //     currentState.data.isNotEmpty ? currentState.data.last.id + 1 : 1;
      // final roomId =
      //     currentState.data.isNotEmpty ? currentState.data.last.roomId : 0;
      final senderId = partnerId;
      final receiverId = myId;
      final type = MESSAGE;
      final attach = '';
      final createdAt = now;
      final updatedAt = now;
      final lastMessage = LastMessage(1, 0, senderId, receiverId, newMessage,
          type, attach, createdAt, updatedAt);
      final List<LastMessage> data = List.from(currentState.data);
      data.insert(0, lastMessage);
      yield currentState.copyWith(data: data);
    }
  }

  void _firstStartCounting() {
    _firstTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _firstTotal--;
      int minutes = _firstTotal ~/ 60;
      String seconds = (_firstTotal % 60).toString().padLeft(2, '0');
      if (_firstTotal < 0) {
        _firstTotal = -1;
        _firstTimer.cancel();
        firstButtonSubject.add('');
      } else
        firstButtonSubject.add('$minutes : $seconds');
    });
  }

  void _secondStartCounting() {
    _secondTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _secondTotal--;
      int minutes = _secondTotal ~/ 60;
      String seconds = (_secondTotal % 60).toString().padLeft(2, '0');
      if (_secondTotal < 0) {
        _secondTotal = -1;
        _secondTimer.cancel();
        secondButtonSubject.add('');
      } else
        secondButtonSubject.add('$minutes : $seconds');
    });
  }

  void _thirdStartCounting() {
    _thirdTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _thirdTotal--;
      int minutes = _thirdTotal ~/ 60;
      String seconds = (_thirdTotal % 60).toString().padLeft(2, '0');
      if (_thirdTotal < 0) {
        _thirdTotal = -1;
        _thirdTimer.cancel();
        thirdButtonSubject.add('');
      } else
        thirdButtonSubject.add('$minutes : $seconds');
    });
  }

  bool _hasReachedMax(ChatBoxState state) =>
      state is ChatBoxSuccess && state.hasReachedMax;

  Future<List<LastMessage>> _fetchLastMessages({int limit, int page}) async {
    return MoonBlinkRepository.getLastMessages(
        id: partnerId, limit: limit, page: page);
  }
}
