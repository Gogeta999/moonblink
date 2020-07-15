import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moonblink/api/moonblink_api.dart';
import 'package:moonblink/api/moonblink_dio.dart';
import 'package:moonblink/base_widget/audiorecorder.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/user.dart';
import 'package:moonblink/ui/pages/call/voice_call_page.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:oktoast/oktoast.dart';
import 'package:moonblink/base_widget/indicator/button_indicator.dart';

class NetWorkPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PageState();
}

class PageState extends State<NetWorkPage> {
  String channelName = '';
  bool isOpen = false;
  var resultJson = "";
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Testing Page"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          MaterialButton(
            color: Colors.red,
            child: Text("Audio recorder"),
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Recorder()));
            },
          ),
          GestureDetector(
            child: Container(
              alignment: Alignment.center,
              height: 35,
              width: 80,
              decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.all(Radius.circular(15))),
              child:
                  isOpen ? ButtonProgressIndicator() : Text('False show this'),
            ),
            onTap: isOpen
                ? () {
                    print('True to False');
                    setState(() {
                      isOpen = !isOpen;
                    });
                  }
                : () {
                    print('False to True');
                    setState(() {
                      isOpen = !isOpen;
                    });
                  },
          ),
          SizedBox(
            height: 30,
          ),
          GestureDetector(
            child: Container(
              alignment: Alignment.center,
              height: 35,
              width: 80,
              decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.all(Radius.circular(15))),
              child: Text('TestButton'),
            ),
            onTap: () async {
              String key = 'abc';
              var userId = StorageManager.sharedPreferences.getInt(mUserId);
              var response = await DioUtils().get(
                  Api.SimpleRequestApi + '$userId/search',
                  queryParameters: {
                    'name': key,
                  });
              return response.data['data']
                  .map<User>((item) => User.fromJsonMap(item))
                  .toList();
            },
          ),
          SizedBox(
            height: 30,
          ),
          Container(
            // alignment: Alignment.center,
            // padding: EdgeInsets.all(50),
            margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
            height: 100,
            width: 50,
            decoration: BoxDecoration(
              border: Border.all(width: 2.0, color: Colors.grey),
              // color: Colors.grey,
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.black,
                ),
                IconButton(
                    icon: Icon(
                      FontAwesomeIcons.phoneSlash,
                      color: Colors.red[500],
                    ),
                    onPressed: () {
                      print('Decline');
                    }),
                IconButton(
                    icon: Icon(
                      FontAwesomeIcons.phone,
                      color: Colors.green[300],
                    ),
                    onPressed: joinChannel),
              ],
            ),
          ),
          Expanded(
              child: Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: resultJson.length <= 0
                  ? Text("数据加载中...")
                  : Text(
                      resultJson,
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ))
        ],
      ),
    );
  }

  ///Here is for voicCall
  Future<void> joinChannel() async {
    if (channelName.isNotEmpty) {
      await _handleVoiceCall();
    } else if (channelName.isEmpty) {
      showToast('Developer error');
    }
  }

  Future<void> _handleVoiceCall() async {
    await [Permission.microphone].request();
    if (await Permission.camera.request().isGranted) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VoiceCallWidget(
              channelName: channelName,
            ),
          ));
    } else if (await Permission.camera.request().isDenied) {
      showDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: Text(
                "Please allow Microphone",
                textAlign: TextAlign.center,
              ),
              content: Text(
                  "You need to allow Microphone permission to enable voice call"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    } else if (await Permission.camera.request().isPermanentlyDenied) {
      print('Permanently being denied,user need to allow in app setting');
      showDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: Text(
                "Please allow Microphone to",
                textAlign: TextAlign.center,
              ),
              content: Text(
                  "You need to allow Microphone permission at App Settings"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Text("Ok"),
                  onPressed: () {
                    openAppSettings();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    }
  }
}
