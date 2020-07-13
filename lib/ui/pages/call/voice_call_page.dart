import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/api/voice_call_id.dart';
import 'package:oktoast/oktoast.dart';

class VoiceCallWidget extends StatefulWidget {
  /// createChannel to let users get a room to chat
  final String channelName;
  const VoiceCallWidget({Key key, this.channelName}) : super(key: key);
  @override
  _VoiceCallWidgetState createState() => _VoiceCallWidgetState();
}

class _VoiceCallWidgetState extends State<VoiceCallWidget> {
  final _voiceInfoString = <String>[];
  static final _users = <int>[];

  @override
  void initState() {
    super.initState();
    initializeVoiceService();
  }

  @override
  void dispose() {
    //clear User
    _users.clear();
    AgoraRtcEngine.leaveChannel();
    AgoraRtcEngine.destroy();
    super.dispose();
  }

  Future<void> initializeVoiceService() async {
    if (Agora_AppId.isEmpty) {
      showToast('Agora Engine is not starting');
    }
    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    await AgoraRtcEngine.enableWebSdkInteroperability(true);
    await AgoraRtcEngine.enableLocalAudio(true);
    await AgoraRtcEngine.joinChannel(null, widget.channelName, null, 0);
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    await AgoraRtcEngine.create(Agora_AppId);
    await AgoraRtcEngine.enableAudio();
    await AgoraRtcEngine.setAudioProfile(
        AudioProfile.SpeechStandard, AudioScenario.ChatRoomGaming);
  }

  void _addAgoraEventHandlers() {
    AgoraRtcEngine.onError = (dynamic code) {
      setState(() {
        final info = 'onError: $code';
        _voiceInfoString.add(info);
      });
    };

    AgoraRtcEngine.onJoinChannelSuccess = (
      String channel,
      int uid,
      int elapsed,
    ) {
      setState(() {
        final info = 'onJoinChannel: $channel, uid: $uid';
        _voiceInfoString.add(info);
      });
    };

    AgoraRtcEngine.onLeaveChannel = () {
      setState(() {
        _voiceInfoString.add('onLeaveChannel');
        _users.clear();
      });
    };

    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
      setState(() {
        final info = 'userJoined: $uid';
        _voiceInfoString.add(info);
        _users.add(uid);
      });
    };

    AgoraRtcEngine.onUserOffline = (int uid, int reason) {
      setState(() {
        final info = 'userOffline: $uid';
        _voiceInfoString.add(info);
        _users.remove(uid);
      });
    };

    AgoraRtcEngine.onFirstRemoteVideoFrame = (
      int uid,
      int width,
      int height,
      int elapsed,
    ) {
      setState(() {
        final info = 'firstRemoteVideo: $uid ${width}x $height';
        _voiceInfoString.add(info);
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
