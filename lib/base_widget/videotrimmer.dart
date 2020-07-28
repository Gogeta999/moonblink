import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/api/moonblink_api.dart';
import 'package:moonblink/api/moonblink_dio.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/utils/platform_utils.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:video_trimmer/trim_editor.dart';
import 'package:video_trimmer/video_trimmer.dart';
import 'package:video_trimmer/video_viewer.dart';

class VideoTrimmer extends StatefulWidget {
  final Trimmer _trimmer;
  VideoTrimmer(this._trimmer);
  @override
  _VideoTrimmer createState() => _VideoTrimmer();
}

class _VideoTrimmer extends State<VideoTrimmer> {
  double _startValue = 0.0;
  double _endValue = 0.0;
  var duration = 0.0;
  File video;
  bool _uploadDone = false;
  bool _isPlaying = false;
  bool _progressVisibility = false;

  Future<String> _saveVideo() async {
    setState(() {
      _progressVisibility = true;
    });

    String _value;

    await widget._trimmer
        .saveTrimmedVideo(startValue: _startValue, endValue: _endValue)
        .then((value) async {
      //upload video
      setState(() {
        _progressVisibility = false;
        _value = value;
        video = File(_value);
        print(value);
        print("111111111111111111111111111111");
      });
      var partnerId = StorageManager.sharedPreferences.getInt(mUserId);
      var storyPath = video.path;
      print(storyPath);
      print("------------------------------------------------------------");
      FormData formData = FormData.fromMap({
        'body': '',
        'media': await MultipartFile.fromFile(storyPath, filename: 'video.mp4'),
        'media_type': 2
      });

      var response = await DioUtils()
          .postwithData(Api.POSTSTORY + '$partnerId/story', data: formData);
      if (response.errorCode == 1) {
        setState(() {
          _uploadDone = !_uploadDone;
        });
        Navigator.of(context)
            .pushNamedAndRemoveUntil(RouteName.main, (route) => false);
        // Navigator.of(context).pushNamed(RouteName.network);
      }
      // return Story.fromMap(response.data);
      return response.data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).trimYourVideo),
      ),
      body: Builder(
        builder: (context) => Center(
          child: Container(
            padding: EdgeInsets.only(bottom: 30.0),
            color: Colors.black,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Visibility(
                  visible: _progressVisibility,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.red,
                  ),
                ),
                RaisedButton(
                  onPressed: _progressVisibility
                      ? null
                      : () async {
                          _saveVideo().then((outputPath) {
                            print('OUTPUT PATH: $outputPath');
                            final snackBar = SnackBar(
                              content: Text('Video Saved successfully'),
                            );
                            Scaffold.of(context).showSnackBar(snackBar);
                          });
                        },
                  child: Text(S.of(context).upload),
                ),
                Expanded(
                  child: VideoViewer(),
                ),
                Center(
                  child: TrimEditor(
                    viewerHeight: 50.0,
                    viewerWidth: MediaQuery.of(context).size.width,
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
                      duration = _endValue - _startValue;
                      print(duration);
                      print("-------------------------------------------");
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
