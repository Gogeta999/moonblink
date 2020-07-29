import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'package:image_picker/image_picker.dart';

import 'package:dio/dio.dart';
import 'package:moonblink/api/moonblink_api.dart';
import 'package:moonblink/api/moonblink_dio.dart';
import 'package:moonblink/base_widget/indicator/button_indicator.dart';
import 'package:moonblink/base_widget/videotrimmer.dart';
import 'package:moonblink/base_widget/videotrimmer/video_trimmer.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

class ImagePickerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ImagePickerState();
  }
}

class _ImagePickerState extends State<ImagePickerPage> {
  final FlutterFFprobe detail = new FlutterFFprobe();
  final FlutterFFmpeg trim = new FlutterFFmpeg();
  final Trimmer trimv = Trimmer();
  final _picker = ImagePicker();
  File _chossingItem;
  String _filePath;
  int _fileType;
  bool _uploadDone = false;
  int duration;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).imagePickerAppBar,
            style: Theme.of(context).accentTextTheme.headline6),
      ),
      body: Column(
        children: <Widget>[
          // Row 1
          Container(
            height: 75,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                    // color: Colors.blue,
                    child: FlatButton(
                        color: Theme.of(context).accentColor,
                        child: Text(
                          S.of(context).imagePickerCamera,
                          style: Theme.of(context)
                              .accentTextTheme
                              .button
                              .copyWith(wordSpacing: 5),
                        ),
                        onPressed: () {
                          _takePhoto();
                        })),
                Container(
                    // color: Colors.blue,
                    child: FlatButton(
                        color: Theme.of(context).accentColor,
                        child: Text(
                          S.of(context).imagePickerGallery,
                          style: Theme.of(context)
                              .accentTextTheme
                              .button
                              .copyWith(wordSpacing: 5),
                        ),
                        onPressed: () {
                          _openGallery();
                        })),
                Container(
                    // color: Colors.blue,
                    child: FlatButton(
                        color: Theme.of(context).accentColor,
                        child: Text(
                          S.of(context).imagePickerVideo,
                          style: Theme.of(context)
                              .accentTextTheme
                              .button
                              .copyWith(wordSpacing: 5),
                        ),
                        onPressed: () {
                          _pickVideo();
                        })),
              ],
            ),
          ),

          //Row 2
          Container(
              padding: EdgeInsets.only(left: 50, right: 50),
              height: 80,
              child: Text(S.of(context).imagePickerChooseSome)),

          ShowImageWidget(file: _chossingItem),

          RaisedButton(
            color: Theme.of(context).accentColor,
            onPressed: () async {
              setState(() {
                _uploadDone = !_uploadDone;
              });
              var partnerId = StorageManager.sharedPreferences.getInt(mUserId);
              var storyPath = _chossingItem.path;
              FormData formData = FormData.fromMap({
                'body': '',
                'media': await MultipartFile.fromFile(storyPath,
                    filename: 'xxx.jpg'),
                'media_type': _fileType
              });

              var response = await DioUtils().postwithData(
                  Api.POSTSTORY + '$partnerId/story',
                  data: formData);
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
            },
            child: _uploadDone
                ? ButtonProgressIndicator()
                : Text(
                    S.of(context).imagePickerUploadButton,
                    style: Theme.of(context).accentTextTheme.button,
                  ),
          ),
        ],
      ),
    );
  }

  // 2. compress file and get file.
  Future<File> _compressAndGetFile(File file, String targetPath) async {
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 80,
    );

    print(file.lengthSync());
    print(result.lengthSync());

    return result;
  }

  Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    _filePath =
        '$path/' + DateTime.now().millisecondsSinceEpoch.toString() + '.jpeg';
    return File(_filePath);
  }

  _takePhoto() async {
    PickedFile pickedFile = await _picker.getImage(source: ImageSource.camera);
    File image = File(pickedFile.path);
    File temporaryImage = await _getLocalFile();
    File compressedImage =
        await _compressAndGetFile(image, temporaryImage.absolute.path);
    setState(() {
      _chossingItem = compressedImage;
      _fileType = 1;
    });
  }

  _openGallery() async {
    PickedFile pickedFile = await _picker.getImage(
        source: ImageSource.gallery, maxWidth: 300, maxHeight: 600);
    File image = File(pickedFile.path);
    File temporaryImage = await _getLocalFile();
    File compressedImage =
        await _compressAndGetFile(image, temporaryImage.absolute.path);
    setState(() {
      // this._uploadImage(image);
      _chossingItem = compressedImage;
      _fileType = 1;
    });
  }

  _pickVideo() async {
    PickedFile video = await _picker.getVideo(
        source: ImageSource.gallery, maxDuration: Duration(seconds: 10));
    // var video = await _picker.getVideo(
    //     source: ImageSource.gallery, maxDuration: Duration(seconds: 2));
    await trimv.loadVideo(videoFile: File(video.path));
    detail.getMediaInformation(video.path).then((info) {
      print("Getting info of video");
      print(info["duration"]);
      duration = info['duration'];
      if (duration > 10500) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoTrimmer(trimv),
            ));
      } else {
        setState(() {
          _chossingItem = File(video.path);
          _fileType = 2;
        });
      }
    });

    // final uint8list = await VideoThumbnail.thumbnailFile(
    //   video:
    //       "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4",
    //   thumbnailPath: (await getTemporaryDirectory()).path,
    //   imageFormat: ImageFormat.WEBP,
    //   maxHeight:
    //       64, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
    //   quality: 75,
    // );
  }
}

class ShowImageWidget extends StatelessWidget {
  ShowImageWidget({this.file});
  final file;
  @override
  Widget build(BuildContext context) {
    if (this.file != null) {
      return Container(
        height: 300,
        child: Image.file(file),
      );
    }
    return Container();
  }
}
