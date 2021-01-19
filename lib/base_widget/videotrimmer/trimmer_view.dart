import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:rxdart/rxdart.dart';
import 'package:video_trimmer/video_trimmer.dart';

class TrimmerView extends StatefulWidget {
  final Trimmer _trimmer;
  final int vipLevel;
  TrimmerView(this._trimmer, this.vipLevel)
      : assert(vipLevel != null || vipLevel < 2);
  @override
  _TrimmerViewState createState() => _TrimmerViewState();
}

class _TrimmerViewState extends State<TrimmerView> {
  double _startValue = 0.0;
  double _endValue = 0.0;

  bool _isPlaying = false;
  bool _progressVisibility = false;

  final _saveSubject = BehaviorSubject.seeded(false);

  @override
  void dispose() {
    _saveSubject.close();
    super.dispose();
  }

  Future<String> _saveVideo() async {
    setState(() {
      _progressVisibility = true;
    });
    String _value;
    final bitrate = widget.vipLevel == 3 ? "5M" : "2.5M";
    await widget._trimmer
        .saveTrimmedVideo(
      startValue: _startValue,
      endValue: _endValue,
      ffmpegCommand:
          "-vf \"scale='trunc(min(1,min(480/iw,720/ih))*iw/2)*2':'trunc(min(1,min(480/iw,720/ih))*ih/2)*2'\" -r 30 -vcodec libx264 -b:v $bitrate -b:a 48000 -ac 2 -ar 22050",
      customVideoFormat: ".mp4",
      storageDir: StorageDir.temporaryDirectory,
      outputFormat: FileFormat.mp4,
    )
        .then((value) {
      setState(() {
        _progressVisibility = false;
        _value = value;
      });
    });
    // if (Platform.isAndroid) {
    //   await widget._trimmer
    //       .saveTrimmedVideo(
    //     startValue: _startValue,
    //     endValue: _endValue,
    //     //ffmpegCommand: "-vcodec copy -acodec aac",-s 1080x640
    //     ffmpegCommand:
    //         "-vf \"scale='trunc(min(1,min(480/iw,720/ih))*iw/2)*2':'trunc(min(1,min(480/iw,720/ih))*ih/2)*2'\" -r 30 -vcodec libx264 -b:v 5M -b:a 48000 -ac 2 -ar 22050",
    //     customVideoFormat: ".mp4",
    //     outputFormat: FileFormat.mp4,
    //   )
    //       .then((value) {
    //     setState(() {
    //       _progressVisibility = false;
    //       _value = value;
    //     });
    //   });
    // } else {
    //   await widget._trimmer
    //       .saveTrimmedVideo(
    //     startValue: _startValue,
    //     endValue: _endValue,
    //     outputFormat: FileFormat.mp4,
    //   )
    //       .then((value) async {
    //     MediaInfo mediaInfo = await VideoCompress.compressVideo(
    //       value,
    //       quality: VideoQuality.DefaultQuality,
    //       deleteOrigin: true,
    //       includeAudio: true,
    //     );
    //     setState(() {
    //       _progressVisibility = false;
    //       _value = mediaInfo.file.path;
    //     });
    //   });
    // }

    return _value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Video Trimmer"),
      ),
      body: Builder(
        builder: (context) => Center(
          child: Container(
            padding: EdgeInsets.only(bottom: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Visibility(
                  visible: _progressVisibility,
                  child: LinearProgressIndicator(
                    backgroundColor: Theme.of(context).accentColor,
                  ),
                ),
                RaisedButton(
                  onPressed: () async {
                    if (await _saveSubject.first) return;
                    _saveSubject.add(true);
                    showToast(
                        'This would take about 1 or 3 minutes. Please wait patiently.');
                    _saveVideo().then((outputPath) {
                      print('OUTPUT PATH: $outputPath');
                      _saveSubject.add(false);
                      showToast('Video save successfully');
                      final trimmedCompressedFile = File(outputPath);
                      print("TrimmedCompressed: " +
                          trimmedCompressedFile.lengthSync().toString());
                      Navigator.pop(context, trimmedCompressedFile);
                    }, onError: (e) {
                      _saveSubject.add(false);
                      showToast(e.toString());
                    });
                  },
                  child: StreamBuilder<bool>(
                      initialData: false,
                      stream: this._saveSubject,
                      builder: (context, snapshot) {
                        if (snapshot.data) {
                          return CupertinoActivityIndicator();
                        }
                        return Text("SAVE");
                      }),
                ),
                Expanded(
                  child: VideoViewer(),
                ),
                Center(
                  child: TrimEditor(
                    viewerHeight: 50.0,
                    viewerWidth: MediaQuery.of(context).size.width,
                    maxVideoLength: Duration(minutes: 1),
                    onChangeStart: (value) {
                      _startValue = value;
                    },
                    onChangeEnd: (value) {
                      _endValue = value;
                    },
                    onChangePlaybackState: (value) {
                      setState(() {
                        _isPlaying = value;
                      });
                    },
                  ),
                ),
                FlatButton(
                  child: _isPlaying
                      ? Icon(
                          Icons.pause,
                          size: 80.0,
                          color: Colors.white,
                        )
                      : Icon(
                          Icons.play_arrow,
                          size: 80.0,
                          color: Colors.white,
                        ),
                  onPressed: () async {
                    bool playbackState =
                        await widget._trimmer.videPlaybackControl(
                      startValue: _startValue,
                      endValue: _endValue,
                    );
                    setState(() {
                      _isPlaying = playbackState;
                    });
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
