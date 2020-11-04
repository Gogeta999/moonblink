import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum PlayerState { stopped, playing, paused }
enum PlayingRouteState { speakers, earpiece }

class PlayerWidget extends StatefulWidget {
  final String url;
  final PlayerMode mode;
  final isLocal;

  PlayerWidget(
      {Key key,
      @required this.url,
      this.mode = PlayerMode.MEDIA_PLAYER,
      this.isLocal})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PlayerWidgetState(url, mode);
  }
}

class _PlayerWidgetState extends State<PlayerWidget> {
  String url;
  PlayerMode mode;

  AudioPlayer _audioPlayer;
  // ignore: unused_field
  AudioPlayerState _audioPlayerState;
  Duration _duration = Duration(seconds: 0);
  Duration _position = Duration(seconds: 0);

  PlayerState _playerState = PlayerState.stopped;
  PlayingRouteState _playingRouteState = PlayingRouteState.speakers;
  StreamSubscription _durationSubscription;
  StreamSubscription _positionSubscription;
  StreamSubscription _playerCompleteSubscription;
  StreamSubscription _playerErrorSubscription;
  StreamSubscription _playerStateSubscription;

  bool _isLoading = false;
  bool _isFirstTime = true;
  bool _isFailed = false;

  get _isPlaying => _playerState == PlayerState.playing;
  // ignore: unused_element
  get _isPaused => _playerState == PlayerState.paused;
  // ignore: unused_element
  get _durationText =>
      _duration?.inSeconds?.toString()?.split('.')?.first ?? '';
  // ignore: unused_element
  get _positionText => _position?.toString()?.split('.')?.first ?? '';

  // ignore: unused_element
  get _isPlayingThroughEarpiece =>
      _playingRouteState == PlayingRouteState.earpiece;

  _PlayerWidgetState(this.url, this.mode);

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerErrorSubscription?.cancel();
    _playerStateSubscription?.cancel();
    if (_playerState == PlayerState.playing) {
      _stop();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        (() {
          if (_isPlaying == true && _isLoading == false) {
            return CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _pause(),
              child: Icon(Icons.pause),
            );
          } else if (_isLoading == true) {
            return CupertinoButton(
              padding: EdgeInsets.zero,
              child: CupertinoActivityIndicator(),
              onPressed: () {},
            );
          } else if (_isFailed) {
            return CupertinoButton(
              padding: EdgeInsets.zero,
              child: Text(
                'failed',
                style: TextStyle(fontSize: 10),
              ),
              onPressed: () {},
            );
          } else if (_isPlaying == false) {
            return CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _play(),
              child: Icon(Icons.play_arrow),
            );
          } else {
            return Container(height: 0, width: 0);
          }
        }()),
        Container(
          width: 100,
          child: LinearProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black54),
            value: (_position != null &&
                    _duration != null &&
                    _position.inMilliseconds > 0 &&
                    _position.inMilliseconds < _duration.inMilliseconds)
                ? _position.inMilliseconds / _duration.inMilliseconds
                : 0.0,
          ),
        ),

        /// can't get max duration at start
        Padding(
          padding: const EdgeInsets.all(10.0),
        ),
      ],
    );
  }

  void _initAudioPlayer() async {
    _audioPlayer = AudioPlayer(mode: mode);
    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _duration = duration;
        _isLoading = false;
      });
    });

    _positionSubscription =
        _audioPlayer.onAudioPositionChanged.listen((p) => setState(() {
              _position = p;
            }));

    _playerCompleteSubscription =
        _audioPlayer.onPlayerCompletion.listen((event) {
      _onComplete();
      setState(() {
        _position = _duration;
      });
    });

    _playerErrorSubscription = _audioPlayer.onPlayerError.listen((msg) {
      print('audioPlayer error : $msg');
      setState(() {
        _playerState = PlayerState.stopped;
        _isFailed = true;
        _duration = Duration(seconds: 0);
        _position = Duration(seconds: 0);
      });
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        _audioPlayerState = state;
      });
    });

    _audioPlayer.onNotificationPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() => _audioPlayerState = state);
    });

    _playingRouteState = PlayingRouteState.speakers;
  }

  Future<int> _play() async {
    if (_isFirstTime) {
      setState(() {
        _isLoading = true;
        _isFirstTime = false;
      });
    }

    final playPosition = (_position != null &&
            _duration != null &&
            _position.inMilliseconds > 0 &&
            _position.inMilliseconds < _duration.inMilliseconds)
        ? _position
        : null;

    final result = await _audioPlayer.play(url,
        position: playPosition, isLocal: widget.isLocal);
    if (result == 1) {
      _playerState = PlayerState.playing;
    }

    // default playback rate is 1.0
    // this should be called after _audioPlayer.play() or _audioPlayer.resume()
    // this can also be called everytime the user wants to change playback rate in the UI
    _audioPlayer.setPlaybackRate(playbackRate: 1.0);

    return result;
  }

  Future<int> _pause() async {
    final result = await _audioPlayer.pause();
    if (result == 1) setState(() => _playerState = PlayerState.paused);
    return result;
  }

  // ignore: unused_element
  Future<int> _earpieceOrSpeakersToggle() async {
    final result = await _audioPlayer.earpieceOrSpeakersToggle();
    if (result == 1)
      setState(() => _playingRouteState =
          _playingRouteState == PlayingRouteState.speakers
              ? PlayingRouteState.earpiece
              : PlayingRouteState.speakers);
    return result;
  }

  // ignore: unused_element
  Future<int> _stop() async {
    final result = await _audioPlayer.stop();
    if (result == 1) {
      setState(() {
        _playerState = PlayerState.stopped;
        _position = Duration();
      });
    }
    return result;
  }

  void _onComplete() {
    setState(() => _playerState = PlayerState.stopped);
  }
}

class LocalPlayerWidget extends StatefulWidget {
  final String path;
  final PlayerMode mode;

  LocalPlayerWidget(
      {Key key, @required this.path, this.mode = PlayerMode.MEDIA_PLAYER})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _LocalPlayerWidgetState(this.mode);
  }
}

class _LocalPlayerWidgetState extends State<LocalPlayerWidget> {
  // String path;
  PlayerMode mode;

  AudioPlayer _audioPlayer;
  // ignore: unused_field
  AudioPlayerState _audioPlayerState;
  Duration _duration = Duration(seconds: 0);
  Duration _position = Duration(seconds: 0);

  PlayerState _playerState = PlayerState.stopped;
  PlayingRouteState _playingRouteState = PlayingRouteState.speakers;
  StreamSubscription _durationSubscription;
  StreamSubscription _positionSubscription;
  StreamSubscription _playerCompleteSubscription;
  StreamSubscription _playerErrorSubscription;
  StreamSubscription _playerStateSubscription;

  get _isPlaying => _playerState == PlayerState.playing;
  // ignore: unused_element
  get _isPaused => _playerState == PlayerState.paused;
  // ignore: unused_element
  get _durationText =>
      _duration?.inSeconds?.toString()?.split('.')?.first ?? '';
  // ignore: unused_element
  get _positionText => _position?.toString()?.split('.')?.first ?? '';

  // ignore: unused_element
  get _isPlayingThroughEarpiece =>
      _playingRouteState == PlayingRouteState.earpiece;

  _LocalPlayerWidgetState(this.mode);

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerErrorSubscription?.cancel();
    _playerStateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).accentColor
            // ? Theme.of(context).scaffoldBackgroundColor
            : Theme.of(context).accentColor,
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          (() {
            if (_isPlaying == true) {
              return IconButton(
                padding: EdgeInsets.zero,
                onPressed: () => _pause(),
                icon: Icon(Icons.pause),
                iconSize: 20.0,
              );
            } else if (_isPlaying == false) {
              return IconButton(
                padding: EdgeInsets.zero,
                onPressed: () => _play(),
                icon: Icon(Icons.play_arrow),
                iconSize: 20.0,
              );
            } else {
              return Container(height: 0, width: 0);
            }
          }()),
          Container(
            width: 100,
            child: LinearProgressIndicator(
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black54),
              value: (_position != null &&
                      _duration != null &&
                      _position.inMilliseconds > 0 &&
                      _position.inMilliseconds < _duration.inMilliseconds)
                  ? _position.inMilliseconds / _duration.inMilliseconds
                  : 0.0,
            ),
          ),

          /// can't get max duration at start
          Padding(
            padding: const EdgeInsets.all(10.0),
          ),
        ],
      ),
    );
  }

  void _initAudioPlayer() async {
    _audioPlayer = AudioPlayer(mode: mode);
    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);
    });

    _positionSubscription =
        _audioPlayer.onAudioPositionChanged.listen((p) => setState(() {
              _position = p;
            }));

    _playerCompleteSubscription =
        _audioPlayer.onPlayerCompletion.listen((event) {
      _onComplete();
      setState(() {
        _position = _duration;
      });
    });

    _playerErrorSubscription = _audioPlayer.onPlayerError.listen((msg) {
      print('audioPlayer error : $msg');
      setState(() {
        _playerState = PlayerState.stopped;
        _duration = Duration(seconds: 0);
        _position = Duration(seconds: 0);
      });
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        _audioPlayerState = state;
      });
    });

    _audioPlayer.onNotificationPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() => _audioPlayerState = state);
    });

    _playingRouteState = PlayingRouteState.speakers;
  }

  Future<int> _play() async {
    print(widget.path);
    print(
        'Playing this FIle ++++++++++++++++++++++++++++++++++++++++++++++++++++');
    final playPosition = (_position != null &&
            _duration != null &&
            _position.inMilliseconds > 0 &&
            _position.inMilliseconds < _duration.inMilliseconds)
        ? _position
        : null;
    final result = await _audioPlayer.play(widget.path,
        position: playPosition, isLocal: true);
    if (result == 1) setState(() => _playerState = PlayerState.playing);

    // default playback rate is 1.0
    // this should be called after _audioPlayer.play() or _audioPlayer.resume()
    // this can also be called everytime the user wants to change playback rate in the UI
    _audioPlayer.setPlaybackRate(playbackRate: 1.0);

    return result;
  }

  Future<int> _pause() async {
    final result = await _audioPlayer.pause();
    if (result == 1) setState(() => _playerState = PlayerState.paused);
    return result;
  }

  // ignore: unused_element
  Future<int> _earpieceOrSpeakersToggle() async {
    final result = await _audioPlayer.earpieceOrSpeakersToggle();
    if (result == 1)
      setState(() => _playingRouteState =
          _playingRouteState == PlayingRouteState.speakers
              ? PlayingRouteState.earpiece
              : PlayingRouteState.speakers);
    return result;
  }

  // ignore: unused_element
  Future<int> _stop() async {
    final result = await _audioPlayer.stop();
    if (result == 1) {
      setState(() {
        _playerState = PlayerState.stopped;
        _position = Duration();
      });
    }
    return result;
  }

  void _onComplete() {
    setState(() => _playerState = PlayerState.stopped);
  }
}
