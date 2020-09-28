import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'package:dio/dio.dart';
import 'package:moonblink/api/moonblink_api.dart';
import 'package:moonblink/api/moonblink_dio.dart';
import 'package:moonblink/base_widget/appbar/appbar.dart';
import 'package:moonblink/base_widget/container/shadedContainer.dart';
import 'package:moonblink/base_widget/custom_bottom_sheet.dart';
import 'package:moonblink/base_widget/indicator/button_indicator.dart';
import 'package:moonblink/base_widget/videotrimmer.dart';
import 'package:moonblink/base_widget/videotrimmer/video_trimmer.dart';
import 'package:moonblink/base_widget/videotrimmer/video_viewer.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/utils/constants.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:photo_manager/photo_manager.dart';

class ImagePickerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ImagePickerState();
  }
}

class _ImagePickerState extends State<ImagePickerPage> {
  final FlutterFFprobe detail = new FlutterFFprobe();
  FlutterFFmpeg trim = new FlutterFFmpeg();
  Trimmer trimv = Trimmer();
  final _picker = ImagePicker();
  File _chossingItem;
  String _filePath;
  int _fileType;
  bool _uploadDone = false;
  int duration;

  @override
  void dispose() {
    _chossingItem = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(),
      body: Column(
        children: <Widget>[
          // Row 1
          Container(
            height: 75,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ShadedContainer(
                  color: Theme.of(context).accentColor,
                  ontap: () {
                    _takePhoto();
                  },
                  child: Text(
                    G.of(context).imagePickerCamera,
                    style: Theme.of(context)
                        .accentTextTheme
                        .button
                        .copyWith(wordSpacing: 5),
                  ),
                ),
                ShadedContainer(
                  color: Theme.of(context).accentColor,
                  ontap: () {
                    _openGallery();
                  },
                  child: Text(
                    G.of(context).imagePickerGallery,
                    style: Theme.of(context)
                        .accentTextTheme
                        .button
                        .copyWith(wordSpacing: 5),
                  ),
                ),
                ShadedContainer(
                  color: Theme.of(context).accentColor,
                  child: Text(
                    G.of(context).imagePickerVideo,
                    style: Theme.of(context)
                        .accentTextTheme
                        .button
                        .copyWith(wordSpacing: 5),
                  ),
                  ontap: () {
                    _pickVideo();
                  },
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          //Row 2
          if (_fileType == null)
            Container(
              padding: EdgeInsets.only(left: 50, right: 50),
              height: 50,
              child: Text(G.of(context).imagePickerChooseSome),
            ),
          if (_fileType == 1) ShowImageWidget(file: _chossingItem),

          if (_fileType == 2)
            VideoPlayBack(
              trimv: trimv,
            ),

          SizedBox(
            height: 20,
          ),
          ShadedContainer(
            color: Theme.of(context).accentColor,
            ontap: () async {
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
                    G.of(context).imagePickerUploadButton,
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

  Future<File> _cropImage(File imageFile) async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: imageFile.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 90,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(showCancelConfirmationDialog: true));
    if (croppedFile != null) {
      return croppedFile;
    } else {
      return null;
    }
  }

  _takePhoto() async {
    PickedFile pickedFile = await _picker.getImage(source: ImageSource.camera);
    File croppedImage = await _cropImage(File(pickedFile.path));
    File temporaryImage = await _getLocalFile();
    File compressedImage =
        await _compressAndGetFile(croppedImage, temporaryImage.absolute.path);
    if (compressedImage != null) {
      setState(() {
        _chossingItem = compressedImage;
        _fileType = 1;
      });
    }
  }

  _openGallery() async {
/*    PickedFile pickedFile = await _picker.getImage(
        source: ImageSource.gallery, maxWidth: 300, maxHeight: 600);*/
/*    File image = File(pickedFile.path);
    File temporaryImage = await _getLocalFile();
    File compressedImage =
        await _compressAndGetFile(image, temporaryImage.absolute.path);*/
    CustomBottomSheet.show(
        buildContext: context,
        limit: 1,
        body: G.of(context).pickimage,
        onPressed: (File file) {
          setState(() {
            _chossingItem = file;
            _fileType = 1;
          });
        },
        buttonText: 'Pick',
        popAfterBtnPressed: true,
        requestType: RequestType.image,
        willCrop: true,
        compressQuality: NORMAL_COMPRESS_QUALITY);
    /*setState(() {
      // this._uploadImage(image);
      _chossingItem = compressedImage;
      _fileType = 1;
    });*/
  }

  _pickVideo() async {
    PickedFile video = await _picker.getVideo(
        source: ImageSource.gallery, maxDuration: Duration(seconds: 10));
    //Getting info of video
    detail.getMediaInformation(video.path).then((info) async {
      print("Getting info of video");
      await trimv.loadVideo(videoFile: File(video.path));
      print(info["duration"]);
      duration = info['duration'];
      if (duration > 10500) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoTrimmer(trimv),
            ));
      } else {
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) => VideoTrimmer(trimv),
        //     ));
        setState(() {
          _chossingItem = File(video.path);
          _fileType = 2;
        });
      }
    });
  }
}

class ShowImageWidget extends StatelessWidget {
  ShowImageWidget({this.file});
  final file;
  @override
  Widget build(BuildContext context) {
    if (this.file != null) {
      return Container(
        height: 400,
        child: Image.file(file),
      );
    }
    return Container();
  }
}

class VideoPlayBack extends StatefulWidget {
  VideoPlayBack({this.trimv});
  final Trimmer trimv;

  @override
  _VideoPlayBackState createState() => _VideoPlayBackState();
}

class _VideoPlayBackState extends State<VideoPlayBack> {
  bool isPlaying = false;
  double _startValue = 0.0;
  double _endValue = 0.0;

  @override
  void dispose() {
    super.dispose();
    widget.trimv
        .videPlaybackControl(startValue: _startValue, endValue: _endValue);
    print("Exit");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      child: GestureDetector(
        child: VideoViewer(),
        onTap: () async {
          bool playbackState = await widget.trimv.videPlaybackControl(
            startValue: _startValue,
            endValue: _endValue,
          );
          setState(() {
            print("-------------------------------------------");
            isPlaying = playbackState;
          });
        },
      ),
    );
  }
}
