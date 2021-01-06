import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:visibility_detector/visibility_detector.dart';

class Player extends StatefulWidget {
  final String url;
  final int id;
  final int index;
  final void Function(int height) maxHeightCallBack;

  const Player({Key key, this.url, this.id, this.index, this.maxHeightCallBack}) : super(key: key);

  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  CachedVideoPlayerController _controller;
  final _leftDuration = BehaviorSubject.seeded("");
  final _muteSubject = BehaviorSubject.seeded(false);
  bool didUserPause = false;

  @override
  void initState() {
    _controller = CachedVideoPlayerController.network(widget.url);
    _controller.addListener(() {
      if (_controller.value.duration == null) return;
      if (_controller.value.duration.inSeconds == _controller.value.position.inSeconds) {
        _controller.seekTo(Duration(milliseconds: 50));
        return;
      }
      int left = ((_controller.value.duration?.inMilliseconds ?? 0) -
          (_controller.value.position.inMilliseconds)) ~/ 1000;
      String leftSeconds = (left % 60).toString().padLeft(2, '0');
      int leftMinutes = left ~/ 60;
      _leftDuration.add("$leftMinutes:$leftSeconds");
    });
    _muteSubject.add(_controller.value.volume == 0.0);
    _controller.initialize().then((_) {
      _controller.setLooping(true);
      widget.maxHeightCallBack(_controller.value.size.height.toInt());
      _controller.seekTo(Duration(milliseconds: 50));
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _muteSubject.close();
    _leftDuration.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: VisibilityDetector(
        key: Key('${widget.id + widget.index}-${widget.url}'),
        onVisibilityChanged: (visibilityInfo) {
          if (visibilityInfo.visibleFraction >= 0.9) {
            if (!(_controller?.value?.isPlaying ?? true) && !didUserPause)
              _controller?.play();
          } else {
            if ((_controller?.value?.isPlaying ?? false)) _controller?.pause();
          }
        },
        child: Stack(
          children: [
            Center(
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  if (!_controller.value.initialized) return;
                  if (_controller.value.isPlaying) {
                    _controller.pause();
                    didUserPause = true;
                  } else {
                    _controller.play();
                    didUserPause = false;
                  }
                },
                child: _controller.value != null && _controller.value.initialized
                    ? CachedVideoPlayer(_controller)
                    : CircularProgressIndicator(),
              ),
            ),
            StreamBuilder<String>(
                initialData: '',
                stream: this._leftDuration,
                builder: (context, snapshot) {
                  if (!_controller.value.initialized) return Container();
                  return Positioned(
                      top: 35,
                      right: 6,
                      child: Row(
                        children: [
                          Text(
                            '${snapshot.data}',
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                          SizedBox(width: 5),
                          CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                this._muteSubject.first.then((value) {
                                  if (value) {
                                    _controller.setVolume(1.0);
                                  } else {
                                    _controller.setVolume(0.0);
                                  }
                                  this._muteSubject.add(!value);
                                });
                              },
                              child: StreamBuilder<bool>(
                                  initialData: false,
                                  stream: this._muteSubject,
                                  builder: (context, snapshot) {
                                    return Icon(
                                      snapshot.data
                                          ? Icons.volume_off
                                          : Icons.volume_up,
                                      color: Colors.white,
                                    );
                                  }))
                        ],
                      ));
                }),
          ],
        ),
      ),
    );
  }
}
