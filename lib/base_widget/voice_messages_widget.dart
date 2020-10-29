import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter_plugin_record/flutter_plugin_record.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moonblink/base_widget/custom_bottom_sheet.dart';
import 'package:moonblink/services/chat_service.dart';
import 'package:moonblink/ui/helper/icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scoped_model/scoped_model.dart';

// final String microphone = 'assets/icons/microphone.svg';

class Voicemsg extends StatefulWidget {
  final LocalFileSystem localFileSystem;
  final id;
  final messages;
  final Function rotate;
  @required
  final Function onDismiss;
  @required
  final Function onInit;
  final Function startRecord;
  final Function stopRecord;
  Voicemsg(
      {localFileSystem,
      this.id,
      this.messages,
      this.onDismiss,
      this.rotate,
      this.onInit,
      this.startRecord,
      this.stopRecord})
      : this.localFileSystem = localFileSystem ?? LocalFileSystem();

  @override
  _VoicemsgState createState() => _VoicemsgState();
}

class _VoicemsgState extends State<Voicemsg> {
  String filename;
  File _file;
  Uint8List bytes;
  // ChatModel chatModel;
  FlutterPluginRecord recordPlugin = new FlutterPluginRecord();
  String filePath = "";
  bool sent = true;
  // @override
  // void initState() {
  //   super.initState();
  //   _init();
  // }

  @override
  void dispose() {
    recordPlugin.dispose();
    super.dispose();
  }

  ///Init Voice Record
  void _init() async {
    Permission.microphone.request();
    recordPlugin.init();
    print('Inittttttttttttttt');
  }

  ///Start Voice Record
  void _start() async {
    recordPlugin.start();
    print('Startttttttttttttttt');
  }

  _restart() async {
    recordPlugin.stop();

    ///stop success
    _init();
  }

  ///Stop Voice
  void _send() {
    recordPlugin.stop();
    setState(() {
      sent = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: ChatModel()..init(),
      child: ScopedModelDescendant<ChatModel>(builder: (context, child, model) {
        // this.chatModel = model;
        return IconButton(
          icon: SvgPicture.asset(
            microphone,
            color: Colors.black,
            semanticsLabel: 'mircophone',
            width: 30,
            height: 30,
          ),
          onPressed: () async {
            widget.rotate();
            _init();

            ///Init Listening
            recordPlugin.responseFromInit.listen((data) {
              if (data) {
                print("Init Sucess");
              } else {
                print("Init Fails");
              }
            });

            /// Start Record and End Record
            recordPlugin.response.listen((data) {
              if (data.msg == "onStart") {
                print("onStart --");
              } else if (data.msg == "onStop") {
                print("onStop  Path" + data.path);
                print("++++++++++++++++++++++++++++++++++++++++++++++++R");
                setState(() {
                  String currentTime =
                      DateTime.now().millisecondsSinceEpoch.toString();

                  filePath = data.path;
                  print("filePath + $filePath ");
                  // filePath = appDocDirectory.absolute.path + '/' + currentTime;
                  filename = widget.id.toString() + currentTime + ".wav";
                  _file = widget.localFileSystem.file(filePath);

                  bytes = _file.readAsBytesSync();
                  // print("File Bytes: $bytes");
                  // print(bytes);
                });
                // print("onStop " + data.audioTimeLength.toString());
                print("NOT SENT YET +++++++++++++++++++++++++++++++");
                print(sent);
                if (sent == false) {
                  model.sendaudio(
                      filename, bytes, widget.id, 3, widget.messages, filePath);
                  print(filePath);
                  print(filename);
                  print("Sent ___________________________________");
                  // recordPlugin.dispose();
                  sent = true;
                }
              } else {
                print("--" + data.msg);
              }
            });

            ///Vibration Response
            recordPlugin.responseFromAmplitude.listen((data) {
              // var voiceData = double.parse(data.msg);
              // // print("Vibration----------" + voiceData.toString());
            });
            // recordPlugin.responsePlayStateController.listen((data) {
            //   print("PlayPath   " + data.playPath);
            //   print("PlayState   " + data.playState);
            // });
            CustomBottomSheet.showNewVoiceSheet(
                buildContext: context,
                send: () => _send(),
                cancel: () {
                  recordPlugin.stop();
                },
                start: () => _start(),
                restart: () => _restart(),
                onInit: widget.onInit,
                onDismiss: widget.onDismiss);
          },
        );
      }),
    );
  }
}
