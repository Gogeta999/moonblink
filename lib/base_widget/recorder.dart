import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:io' as io;
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:moonblink/base_widget/custom_bottom_sheet.dart';
import 'package:moonblink/global/resources_manager.dart';
import 'package:moonblink/services/chat_service.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scoped_model/scoped_model.dart';

class Voicemsg extends StatefulWidget {
  final LocalFileSystem localFileSystem;
  final id;
  final messages;
  @required
  final Function onDismiss;
  @required
  final Function onInit;

  Voicemsg(
      {localFileSystem, this.id, this.messages, this.onDismiss, this.onInit})
      : this.localFileSystem = localFileSystem ?? LocalFileSystem();

  @override
  _VoicemsgState createState() => _VoicemsgState();
}

class _VoicemsgState extends State<Voicemsg> {
  FlutterAudioRecorder _recorder;
  Recording _current;
  RecordingStatus _currentStatus = RecordingStatus.Unset;
  String filename;
  File _file;
  Uint8List bytes;
  ChatModel chatModel;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    if (_currentStatus == RecordingStatus.Recording) _recorder.stop();
    super.dispose();
  }

  _init() async {
    try {
      String customPath = '';
//     // io.Directory appDocDirectory;
//     io.Directory appDocDirectory = await getApplicationDocumentsDirectory();
//     // if (io.Platform.isIOS) {
//     //   appDocDirectory = await getApplicationDocumentsDirectory();
//     // } else {
//     //   appDocDirectory = await getExternalStorageDirectory();
//     // }
      io.Directory appDocDirectory;
//        io.Directory appDocDirectory = await getApplicationDocumentsDirectory();
      if (io.Platform.isAndroid) {
        appDocDirectory = await getTemporaryDirectory();
      } else if (io.Platform.isIOS) {
        appDocDirectory = await getTemporaryDirectory();
      } else {
        appDocDirectory = await getTemporaryDirectory();
      }

      // can add extension like ".mp4" ".wav" ".m4a" ".aac"
      String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
      customPath = appDocDirectory.absolute.path + '/' + currentTime;
      filename = widget.id.toString() + currentTime + ".wav";

      // .wav <---> AudioFormat.WAV
      // .mp4 .m4a .aac <---> AudioFormat.AAC
      // AudioFormat is optional, if given value, will overwrite path extension when there is conflicts.
      _recorder =
          FlutterAudioRecorder(customPath, audioFormat: AudioFormat.WAV);
      print(_recorder);

      await _recorder.initialized;
      // after initialization
      var current = await _recorder.current(channel: 0);
      print(current);
      // should be "Initialized", if all working fine
      setState(() {
        _current = current;
        _currentStatus = current.status;
        print(_currentStatus);
      });
    } catch (e) {
      print('Error ------ $e');
    }
  }

  _start() async {
    try {
      await _recorder.start();
      var recording = await _recorder.current(channel: 0);
      setState(() {
        _current = recording;
      });
    } catch (e) {
      print(e);
    }
  }

  _restart() async {
    var result = await _recorder.stop();
    if (result.path != null) {
      ///stop success
      await _init();
    } else {
      showToast('Something went wrong. Try again.');
    }
  }

  _send() async {
    var result = await _recorder.stop();
    print("Stop recording: ${result.path}");
    print(result.path);
    print("Stop recording: ${result.duration}");
    _file = widget.localFileSystem.file(result.path);
    print('${_file.path}');
    print("File length: ${await _file.length()}");
    bytes = _file.readAsBytesSync();
    print(filename);
    chatModel.sendaudio(
        filename, bytes, widget.id, 3, widget.messages, result.path);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<ChatModel>(builder: (context, child, model) {
      this.chatModel = model;
      return Container(
          height: 30,
          width: 30,
          child: GestureDetector(
            child: Icon(
              IconFonts.voieMsgIcon,
              color: Theme.of(context).accentColor,
            ),
            onTap: () async {
              await _init();
              CustomBottomSheet.showVoiceSheet(
                  buildContext: context,
                  send: () => _send(),
                  cancel: () {
                    _recorder.stop();
                  },
                  start: () => _start(),
                  restart: () => _restart(),
                  onInit: widget.onInit,
                  onDismiss: widget.onDismiss);
            },
          ));
    });
  }
}
