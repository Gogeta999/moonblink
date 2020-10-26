import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/api/voice_call_id.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/resources_manager.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/videoUserSession.dart';
import 'dart:async';

import 'package:moonblink/services/push_notification_manager.dart';
import 'package:moonblink/utils/constants.dart';

class VoiceCallWidget extends StatefulWidget {
  //passFrom last Place
  final String channelName;
  final String otherUserProfile;
  VoiceCallWidget({Key key, @required this.channelName, this.otherUserProfile})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AudioCallPageState();
  }
}

class AudioCallPageState extends State<VoiceCallWidget> {
  Timer _timer;
  String minutesStr = '00';
  String secondsStr = '00';
  StreamSubscription<int> _tickerSubscription;
  int _countdownTime = 30;
  bool _closeAgora = true;

  static final _userSessions = List<VideoUserSession>();
  //muted or Not
  bool muted = false;

  //started
  bool started = false;

  //open Speaker or Not
  bool speakPhone = false;

  //OtherPeople's userId
  int anotherUserId;
  RtcEngine _engine;

  @override
  void initState() {
    PushNotificationsManager().showVoiceCallNotification();
    super.initState();
    StorageManager.sharedPreferences.setBool(isUserAtVoiceCallPage, true);
    timerCountDown();
    initAgoraSdk();
  }

  _start() {
    _tickerSubscription =
        Stream.periodic(Duration(seconds: 1), (x) => x + 1).listen((duration) {
      print(duration);
      setState(() {
        if (duration >= 60) {
          minutesStr = (duration / 60).floor().toString().padLeft(1, '0');
          secondsStr = '00';
        }
        secondsStr = (duration <= 59 ? duration : duration % 60)
            .floor()
            .toString()
            .padLeft(2, '0');
      });
    });
  }

  //After this page Close
  @override
  void dispose() {
    try {
      _timer.cancel();
      // _countdownController.dispose();
      _userSessions.clear();
      // TODO:
      // _engine.leaveChannel();
      _engine.destroy();
    } catch (e) {
      print(e);
    }
    PushNotificationsManager().cancelVoiceCallNotification();
    StorageManager.sharedPreferences.setBool(isUserAtVoiceCallPage, false);
    super.dispose();
  }

  Future<void> timerCountDown() async {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_countdownTime < 1 && _closeAgora == true) {
            //TODO:
            timer.cancel();
            _onExit(context);
          } else if (_closeAgora == false) {
            timer.cancel();
          } else {
            _countdownTime = _countdownTime - 1;
          }
        },
      ),
    );
  }

  Future<void> initAgoraSdk() async {
    if (Agora_AppId.isEmpty) {
      print('APP_ID missing, please provide your APP_ID in settings.dart');
      print('Agora Engine is not starting');
      return;
    }
//init AgoraInstance
    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();

    // await engine.enableWebSdkInteroperability(true);
    await _engine.joinChannel(null, widget.channelName, null, 0);
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(Agora_AppId);
    await _engine.enableAudio();
    await _engine.setAudioProfile(
        AudioProfile.SpeechStandard, AudioScenario.ChatRoomGaming);
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(error: (code) {
      setState(() {
        print('onError: $code');
      });
    }, joinChannelSuccess: (channel, uid, elapsed) {
      setState(() {
        print('onJoinChannel: $channel, uid: $uid');
      });
    }, userJoined: (uid, elapsed) {
      print('userJoined: $uid');
      setState(() {
        _createRendererView(uid);
        anotherUserId = uid;
      });
    }, userOffline: (uid, elapsed) {
      setState(() {
        print('userOffline: $uid');
        _removeRenderView(uid);
        _onExit(context);
      });
    }, leaveChannel: (stats) {
      print("User is leaving Channel");
    }, firstRemoteVideoFrame: (uid, width, height, elapsed) {
      setState(() {
        print('None Uses');
      });
    }));
  }

  //TODO:
  // Mute
  void _isMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }

  //Speaker
  void _isSpeakPhone() {
    setState(() {
      speakPhone = !speakPhone;
    });
    _engine.setEnableSpeakerphone(speakPhone);
  }

  //Exit Channel
  void _onExit(BuildContext context) {
    _engine.leaveChannel();
    if (_tickerSubscription != null) {
      _tickerSubscription.cancel();
    }
    PushNotificationsManager().cancelVoiceCallNotification();
    Navigator.pop(context);
  }

//   // Render View For Profile
  void _createRendererView(int uid) {
    //to join Voice Channel, need to pass ChannelName and UserId
    setState(() {
      _engine.joinChannel(null, widget.channelName, null, uid);
    });

    VideoUserSession videoUserSession = VideoUserSession(uid);
    _userSessions.add(videoUserSession);
    print("UserSessionSize" + _userSessions.length.toString());
  }

//   //get UserId from Session
  VideoUserSession _getVideoUidSession(int uid) {
    //pass userId to Channel
    return _userSessions.firstWhere((userSession) {
      return userSession.uid == uid;
    });
  }

  //return renderViews by list
  List<int> _getRenderViews() {
    return _userSessions.map((session) => session.uid).toList();
  }

//   //Auto remove RenderView with close
  void _removeRenderView(int uid) {
    //Remove with UserId
    VideoUserSession videoUserSession = _getVideoUidSession(uid);

    if (videoUserSession != null) {
      _userSessions.remove(videoUserSession);
    }
  }

  ///Profile Showing
  Widget _viewAudio() {
    //check Chennel user number first
    List<int> views = _getRenderViews();
    switch (views.length) {
      //Only You
      case 0:
        return Positioned(
          //Show User Name in Container
          top: 80,
          left: 30,
          right: 30,
          child: Container(
            height: 260,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    alignment: Alignment.center,
                    width: 140,
                    height: 140,
                    color: Colors.green,
                    child: Text(
                      G.of(context).voiceCallWaitAnotherToJoin,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Text(
                  '${G.of(context).waiting}.........$_countdownTime',
                  style: TextStyle(color: Colors.white),
                )
              ],
            ),
          ),
        );
      //Two user
      case 1:
        setState(() {
          _closeAgora = !_closeAgora;
        });
        if (started == false) {
          started = true;
          _start();
        }
        return Positioned(
          //Show User Name in Container
          top: 80,
          left: 30,
          right: 30,
          child: Container(
            height: 260,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    alignment: Alignment.center,
                    width: 140,
                    height: 140,
                    // color: Colors.red,
                    child: widget.otherUserProfile == null
                        ? Image.asset(
                            ImageHelper.wrapAssetsImage('MoonBlinkProfile.jpg'))
                        : Image.network(widget.otherUserProfile),
                  ),
                ),
                Text(
                  '$minutesStr:$secondsStr',
                  style: TextStyle(color: Colors.white),
                )
              ],
            ),
          ),
        );

      default:
    }
    return Container();
  }

  // bottomToolBar
  Widget _bottomToolBar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          //Mute Button
          RawMaterialButton(
            onPressed: () {
              return _isMute();
            },
            child: Icon(
              muted ? Icons.mic_off : Icons.mic_off,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),

          //Close Button
          RawMaterialButton(
            onPressed: () {
              return _onExit(context);
            },
            child: Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),

          //Open Speaker or Not
          RawMaterialButton(
            onPressed: () => _isSpeakPhone(),
            child: Icon(
              speakPhone ? Icons.volume_up : Icons.volume_up,
              color: speakPhone ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: speakPhone ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        // appBar: AppBar(
        //   title: Text(widget.channelName),
        // ),
        backgroundColor: Colors.black,
        body: Center(
          child: Stack(
            children: <Widget>[
              _viewAudio(),
              _bottomToolBar(),
            ],
          ),
        ),
      ),
    );
  }
}
