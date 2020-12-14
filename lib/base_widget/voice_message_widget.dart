import 'package:flutter/material.dart';
import 'package:flutter_plugin_record/flutter_plugin_record.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moonblink/base_widget/custom_bottom_sheet.dart';
import 'package:moonblink/ui/helper/icons.dart';
import 'package:permission_handler/permission_handler.dart';

// final String microphone = 'assets/icons/microphone.svg';

class NewVoiceMessage extends StatefulWidget {
  @required
  final Function rotate;
  @required
  final Function onSend;
  @required
  final Function onDismiss;
  @required
  final Function onInit;
  NewVoiceMessage({this.onSend, this.onDismiss, this.onInit, this.rotate});

  @override
  _NewVoiceMessageState createState() => _NewVoiceMessageState();
}

class _NewVoiceMessageState extends State<NewVoiceMessage> {
  FlutterPluginRecord recordPlugin = FlutterPluginRecord();
  String filePath = "";
  bool sent = true;

  @override
  void dispose() {
    recordPlugin.dispose();
    super.dispose();
  }

  ///Init Voice Record
  void _init() async {
    Permission.microphone.request();
    recordPlugin.init();
  }

  ///Start Voice Record
  void _start() async {
    recordPlugin.start();

  }

  _restart() async {
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
    return InkResponse(
      onTap: () {
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
              filePath = data.path;
            });
            if (sent == false) {
              widget.onSend(filePath);
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
        // CustomBottomSheet.showNewVoiceSheet(
        //     buildContext: context,
        //     send: () {
        //       _send();
        //     },
        //     cancel: () {
        //       recordPlugin.stop();
        //     },
        //     start: () => _start(),
        //     restart: () => _restart(),
        //     onInit: widget.onInit,
        //     onDismiss: widget.onDismiss);
      },
      child: SvgPicture.asset(
        microphone,
        color: Colors.black,
        semanticsLabel: 'mircophone',
      ),
    );
  }
}
