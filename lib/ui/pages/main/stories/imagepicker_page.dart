import 'dart:io';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

import 'package:dio/dio.dart';
import 'package:moonblink/api/moonblink_api.dart';
import 'package:moonblink/api/moonblink_dio.dart';
import 'package:moonblink/base_widget/indicator/button_indicator.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/view_model/login_model.dart';


class ImagePickerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ImagePickerState();
  }
}

class _ImagePickerState extends State<ImagePickerPage> {
  final _picker = ImagePicker();
  File _chossingItem;
  bool _uploadDone = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Story', style: Theme.of(context).accentTextTheme.headline6),
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
                  child: Text('Camera', style: Theme.of(context).accentTextTheme.button.copyWith(wordSpacing: 5),),
                  onPressed: () {
                    _takePhoto();
                  })
              ),

              Container(
                // color: Colors.blue,
                child: FlatButton(
                  color: Theme.of(context).accentColor,
                  child: Text('Gallery', style: Theme.of(context).accentTextTheme.button.copyWith(wordSpacing: 5),),
                  onPressed: () {
                    _openGallery();
                  })
              ),

              Container(
                // color: Colors.blue,
                child: FlatButton(
                  color: Theme.of(context).accentColor,
                  child: Text('Video', style: Theme.of(context).accentTextTheme.button.copyWith(wordSpacing: 5),),
                  onPressed: (){
                    _pickVideo();
                  })
              ),

            ],
          ),
        ),

        //Row 2
        Container(
          padding: EdgeInsets.only(left: 50, right: 50),
          height: 80,
          child: Text('Choose your image or video to post')
        ),

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
            'media': await MultipartFile.fromFile(storyPath, filename: 'xxx.jpg'),
            'media_type': 1
          });
      
            var response = await DioUtils().postwithData(Api.POSTSTORY + '$partnerId/story', data: formData);
            if(response.errorCode == 1){
              setState(() {
                _uploadDone = !_uploadDone;
              });
              Navigator.of(context).pop();
              // Navigator.of(context).pushNamed(RouteName.network);
            }
            // return Story.fromMap(response.data);
            return response.data;

          },
          child: _uploadDone ? ButtonProgressIndicator() : Text('Upload', style: Theme.of(context).accentTextTheme.button,),
          ),

        ],
              
      ),

    );
  }

  _takePhoto() async {
    PickedFile image =
        await _picker.getImage(source: ImageSource.camera);
    setState(() {
      // this._uploadImage(image);
      _chossingItem = File(image.path);
    });
  }

  _openGallery() async {
    var image =
        await _picker.getImage(source: ImageSource.gallery, maxWidth: 300, maxHeight: 300);

    setState(() {
      // this._uploadImage(image);
      _chossingItem = File(image.path);
    });
  }

  _pickVideo() async{
    var video = await _picker.getVideo(source: ImageSource.gallery, maxDuration: Duration(seconds: 10));
  
    setState(() {
      _chossingItem = File(video.path);
    });
  }


}

class ShowImageWidget extends StatelessWidget {
  ShowImageWidget({this.file});
  final file;
  @override
  Widget build(BuildContext context) {
    if(this.file != null){
      return Container(
        height: 300,
        child: Image.file(file),
      );
    }
    return Container(
      
    );
  }
}

// class UploadButton extends StatelessWidget {
//   UploadButton({this.story});
//   // final body;
//   final story;
//   final uploadDone = false;
//   @override
//   Widget build(BuildContext context) {
    
//     return RaisedButton(
//       color: Theme.of(context).accentColor,
//       onPressed: () async {
//         // uploadDone = !uploadDone; 
//         var partnerId = StorageManager.sharedPreferences.getInt(mUserId);
//         var storyPath = story.path;
//         FormData formData = FormData.fromMap({
//           'body': '',
//           'media': await MultipartFile.fromFile(storyPath, filename: 'xxx.jpg'),
//           'media_type': 1
//         });
    
//           var response = await DioUtils().postwithData(Api.POSTSTORY + '$partnerId/story', data: formData);
//           if(response.errorCode == 1){
//             // Navigator.of(context).pop();
//             Navigator.of(context).pushNamed(RouteName.network);
//           }
//           // return Story.fromMap(response.data);
//           Navigator.of(context).pop();
//           return response.data;

//        },
//       child: uploadDone ? ButtonProgressIndicator() : Text('Upload', style: Theme.of(context).accentTextTheme.button,),
//     );

//   }
// }



