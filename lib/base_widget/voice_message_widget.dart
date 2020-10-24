import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_plugin_record/flutter_plugin_record.dart';
import 'package:file/local.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moonblink/services/chat_service.dart';
import 'package:moonblink/ui/helper/icons.dart';
import 'package:moonblink/utils/platform_utils.dart';

typedef startRecord = Future Function();
typedef stopRecord = Future Function();

class MoonGoVoiceWidget extends StatefulWidget {
  final LocalFileSystem localFileSystem;
  final id;
  final messages;
  final Function startRecord;
  final Function stopRecord;

  /// startRecord 开始录制回调  stopRecord回调
  const MoonGoVoiceWidget(
      {Key key,
      this.localFileSystem,
      this.id,
      this.messages,
      this.startRecord,
      this.stopRecord})
      : super(key: key);

  @override
  _MoonGoVoiceWidgetState createState() => _MoonGoVoiceWidgetState();
}

class _MoonGoVoiceWidgetState extends State<MoonGoVoiceWidget> {
  double starty = 0.0;
  double offset = 0.0;
  bool isUp = false;
  String textShow = "Long Press to talk";
  String toastShow = "Drag up to send, let go to send";
  String voiceIco = "assets/images/voice_volume_1.png";
  String filePath = "";
  String fileName = "";
  File _voiceFile;
  Uint8List bytes;
  ChatModel chatModel;

  ///Default is close
  bool voiceState = true;
  OverlayEntry overlayEntry;
  FlutterPluginRecord recordPlugin;

  @override
  void initState() {
    super.initState();
    recordPlugin = new FlutterPluginRecord();

    _init();

    ///Init Listening
    recordPlugin.responseFromInit.listen((data) {
      if (data) {
        print("Init Sucess");
      } else {
        print("Init Fails");
      }
    });
    String currentTime = DateTime.now().millisecondsSinceEpoch.toString();

    /// Start Record and End Record
    recordPlugin.response.listen((data) {
      if (data.msg == "onStop") {
        ///TODO: After End record
        print("onStop  " + data.path);
        fileName = widget.id.toString() + "SendAt" + currentTime;
        filePath = data.path;
        _voiceFile = widget.localFileSystem.file(filePath);
        widget.stopRecord(data.path, data.audioTimeLength);
      } else if (data.msg == "onStart") {
        print("onStart --");
        widget.startRecord();
      }
      // else {
      //   print("--" + data.msg);
      // }
    });

    ///Listening Vibration to change Voice Icon Message
    recordPlugin.responseFromAmplitude.listen((data) {
      var voiceData = double.parse(data.msg);
      setState(() {
        if (voiceData > 0 && voiceData < 0.1) {
          voiceIco = "assets/images/voice_volume_2.png";
        } else if (voiceData > 0.2 && voiceData < 0.3) {
          voiceIco = "assets/images/voice_volume_3.png";
        } else if (voiceData > 0.3 && voiceData < 0.4) {
          voiceIco = "assets/images/voice_volume_4.png";
        } else if (voiceData > 0.4 && voiceData < 0.5) {
          voiceIco = "assets/images/voice_volume_5.png";
        } else if (voiceData > 0.5 && voiceData < 0.6) {
          voiceIco = "assets/images/voice_volume_6.png";
        } else if (voiceData > 0.6 && voiceData < 0.7) {
          voiceIco = "assets/images/voice_volume_7.png";
        } else if (voiceData > 0.7 && voiceData < 1) {
          voiceIco = "assets/images/voice_volume_7.png";
        } else {
          voiceIco = "assets/images/voice_volume_1.png";
        }
        if (overlayEntry != null) {
          overlayEntry.markNeedsBuild();
        }
      });

      print("Vibration  " + voiceData.toString() + "  " + voiceIco);
    });
  }

  ///Show Voice Icons
  buildOverLayView(BuildContext context) {
    if (overlayEntry == null) {
      overlayEntry = new OverlayEntry(builder: (content) {
        return Positioned(
          top: MediaQuery.of(context).size.height * 0.5 - 80,
          left: MediaQuery.of(context).size.width * 0.5 - 80,
          child: Material(
            type: MaterialType.transparency,
            child: Center(
              child: Opacity(
                opacity: 0.8,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Color(0xff77797A),
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: new Image.asset(
                          voiceIco,
                          width: 100,
                          height: 100,
                          // package: 'flutter_plugin_record',
                        ),
                      ),
                      Container(
//                      padding: EdgeInsets.only(right: 20, left: 20, top: 0),
                        child: Text(
                          toastShow,
                          style: TextStyle(
                            fontStyle: FontStyle.normal,
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      });
      Overlay.of(context).insert(overlayEntry);
    }
  }

  showVoiceView() {
    setState(() {
      textShow = "Drag up to end";
      voiceState = false;
    });
    buildOverLayView(context);
    start();
  }

  hideVoiceView() {
    setState(() {
      textShow = "Long press to talk";
      voiceState = true;
    });

    stop();
    if (overlayEntry != null) {
      overlayEntry.remove();
      overlayEntry = null;
    }

    if (isUp) {
      print("Cancel");
    } else {
      print("Send");
      bytes = _voiceFile.readAsBytesSync();
      chatModel.sendaudio(
          fileName, bytes, widget.id, 3, widget.messages, filePath);
    }
  }

  moveVoiceView() {
    // print(offset - start);
    setState(() {
      isUp = starty - offset > 100 ? true : false;
      if (isUp) {
        textShow = "Drag up to cancel";
        toastShow = textShow;
        bytes = _voiceFile.readAsBytesSync();
        chatModel.sendaudio(
            fileName, bytes, widget.id, 3, widget.messages, filePath);
      } else {
        textShow = "Unpress to end";
        toastShow = "Drag up to cancel";
      }
    });
  }

  ///Init Voice Record
  void _init() async {
    recordPlugin.init();
    print('Inittttttttttttttt');
  }

  ///Start Voice Record
  void start() async {
    recordPlugin.start();
    print('Startttttttttttttttt');
  }

  ///Stop Voice
  void stop() {
    recordPlugin.stop();
    print('Stopppppppppppppppppppppppppp');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GestureDetector(
          onLongPressStart: (details) {
            starty = details.globalPosition.dy;
            showVoiceView();
          },
          onLongPressEnd: (details) {
            hideVoiceView();
          },
          onLongPressMoveUpdate: (details) {
            offset = details.globalPosition.dy;
            moveVoiceView();
          },
          child: SvgPicture.asset(
            microphone,
            color: Colors.black,
            semanticsLabel: 'mircophone',
            width: 30,
            height: 30,
          )),
    );
  }

  @override
  void dispose() {
    if (recordPlugin != null) {
      recordPlugin.dispose();
    }
    super.dispose();
  }
}
