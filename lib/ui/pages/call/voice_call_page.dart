import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/api/voice_call_id.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/models/videoUserSession.dart';
import 'package:moonblink/services/locator.dart';
import 'package:moonblink/services/navigation_service.dart';
import 'package:moonblink/ui/pages/main/chat/chatbox_page.dart';

class VoiceCallWidget extends StatefulWidget {
  //passFrom last Place
  final String channelName;
  //get partnerId to pop back to chatbox page
  final int partnerId;
  VoiceCallWidget({Key key, this.channelName, this.partnerId})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AudioCallPageState();
  }
}

class AudioCallPageState extends State<VoiceCallWidget>
    with TickerProviderStateMixin {
  // Animation<int> _timeCoundown;
  AnimationController _countdownController;
  //Check User Session for Moonblink
  static final _userSessions = List<VideoUserSession>();
  //muted or Not
  bool muted = false;

  //open Speaker or Not
  bool speakPhone = false;

  //OtherPeople's userId
  int anotherUserId;

  @override
  void initState() {
    super.initState();
    //initAgora
    _countdownController =
        AnimationController(vsync: this, duration: Duration(seconds: 10));
    _countdownController.forward();
    initAgoraSdk();
  }

  //After this page Close
  @override
  void dispose() {
    _countdownController.dispose();
    _userSessions.clear();
    AgoraRtcEngine.leaveChannel();
    AgoraRtcEngine.destroy();
    super.dispose();
  }

  // Render View For Profile
  void _createRendererView(int uid) {
    //to join Voice Channel, need to pass ChannelName and UserId
    setState(() {
      AgoraRtcEngine.joinChannel(null, widget.channelName, null, uid);
    });

    VideoUserSession videoUserSession = VideoUserSession(uid);
    _userSessions.add(videoUserSession);
    print("UserSessionSize" + _userSessions.length.toString());
  }

  //get UserId from Session
  VideoUserSession _getVideoUidSession(int uid) {
    //pass userId to Channel
    return _userSessions.firstWhere((userSession) {
      return userSession.uid == uid;
    });
  }

  //Auto remove RenderView with close
  void _removeRenderView(int uid) {
    //Remove with UserId
    VideoUserSession videoUserSession = _getVideoUidSession(uid);

    if (videoUserSession != null) {
      _userSessions.remove(videoUserSession);
    }
  }

  Future<void> _initAgoraRtcEngine() async {
    //init AgoraInstance
    await AgoraRtcEngine.create(Agora_AppId);
    await AgoraRtcEngine.enableAudio();
    await AgoraRtcEngine.setAudioProfile(
        AudioProfile.SpeechStandard, AudioScenario.ChatRoomGaming);
    _createRendererView(0);
  }

  Future<void> initAgoraSdk() async {
    if (Agora_AppId.isEmpty) {
      print('APP_ID missing, please provide your APP_ID in settings.dart');
      print('Agora Engine is not starting');
      return;
    }

    await _initAgoraRtcEngine();
    _addAgoraEventListener();
    await AgoraRtcEngine.enableWebSdkInteroperability(true);
    await AgoraRtcEngine.joinChannel(null, widget.channelName, null, 0);
  }

  void _addAgoraEventListener() {
    //Debug Error
    AgoraRtcEngine.onError = (dynamic code) {
      print('onError: $code');
    };
    //JoinSuccesss
    AgoraRtcEngine.onJoinChannelSuccess =
        (String channel, int uid, int elapsed) {
      print('JoinSuccess, onJoinChannel: $channel, uid: $uid');
    };

    //Listen User Join or not
    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
      print("UserId: $uid");

      setState(() {
        _createRendererView(uid);
        anotherUserId = uid;
      });
    };

    //Listen User exit or not
    AgoraRtcEngine.onUserOffline = (int uid, int reason) {
      print("Leaving UserId:$uid");
      setState(() {
        _removeRenderView(uid);
      });
    };

    //ListenUserLeaveChannel Or not
    AgoraRtcEngine.onLeaveChannel = () {
      print("User is leaving Channel");
    };
  }

  //return renderViews by list
  List<int> _getRenderViews() {
    return _userSessions.map((session) => session.uid).toList();
  }

  //Mute
  void _isMute() {
    setState(() {
      muted = !muted;
    });
    AgoraRtcEngine.muteLocalAudioStream(muted);
  }

  //Speaker
  void _isSpeakPhone() {
    setState(() {
      speakPhone = !speakPhone;
    });
    AgoraRtcEngine.setEnableSpeakerphone(speakPhone);
  }

  //Exit Channel
  void _onExit(BuildContext context) {
    AgoraRtcEngine.leaveChannel();

    Navigator.pop(context);
  }

  ///Profile Showing
  Widget _viewAudio() {
    //check Chennel user number first
    List<int> views = _getRenderViews();
    switch (views.length) {
      //Only You
      case 1:
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
                      S.of(context).voiceCallWaitAnotherToJoin,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                VoiceCallCoundown(
                  context: context,
                  timeCoundown: StepTween(begin: 10, end: 0)
                      .animate(_countdownController),
                  pop: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      //Two user
      case 2:
        return Positioned(
          //Show User Name in Container
          top: 180,
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
                    color: Colors.red,
                    child: Text(
                      "Other side's name{$anotherUserId}",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

      default:
    }
    return Container();
  }

  //bottomToolBar
  Widget _bottomToolBar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          //Mute Button
          RawMaterialButton(
            onPressed: () {
              return _isMute();
            },
            child: Icon(
              muted ? Icons.mic : Icons.mic_off,
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
              speakPhone ? Icons.leak_remove : Icons.leak_add,
              color: Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}

class VoiceCallCoundown extends AnimatedWidget {
  final Animation<int> timeCoundown;
  final int partnerId;
  final Function pop;
  VoiceCallCoundown({key, this.timeCoundown, this.partnerId, this.pop, context})
      : super(key: key, listenable: timeCoundown) {
    this.timeCoundown.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        AgoraRtcEngine.leaveChannel();
        pop();
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    var value = timeCoundown.value + 1;
    return Text(
      (value == 0 ? '' : '$value '),
      style: TextStyle(color: Colors.white),
    );
  }
}
