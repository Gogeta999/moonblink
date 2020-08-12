import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:io' as io;
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:moonblink/base_widget/photo_bottom_sheet.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/resources_manager.dart';
import 'package:moonblink/services/chat_service.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';

class Voicemsg extends StatefulWidget {
  final LocalFileSystem localFileSystem;
  final id;
  final messages;
  @required final Function onDismiss;
  @required final Function onInit;

  Voicemsg({localFileSystem, this.id, this.messages, this.onDismiss, this.onInit})
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
    if (_recorder != null) _recorder.stop();
    super.dispose();
  }

  _init() async {
    try {
      if (await FlutterAudioRecorder.hasPermissions) {
        String customPath = '';
        io.Directory appDocDirectory;
//        io.Directory appDocDirectory = await getApplicationDocumentsDirectory();
        if (io.Platform.isIOS) {
          appDocDirectory = await getApplicationDocumentsDirectory();
        } else {
          appDocDirectory = await getExternalStorageDirectory();
        }

        // can add extension like ".mp4" ".wav" ".m4a" ".aac"
        customPath = appDocDirectory.path +
            customPath +
            DateTime.now().millisecondsSinceEpoch.toString();

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
        CustomBottomSheet.showVoiceSheet(
            buildContext: context,
            send: () => _send(),
            cancel: () => {
              if (_recorder != null) {
                _recorder.stop()
              }
            },
            start: () => _start(),
            onDismiss: widget.onDismiss);
      } else {
        Scaffold.of(context).showSnackBar(new SnackBar(
            content: new Text(S.of(context).youMustAcceptPermission)));
      }
    } catch (e) {
      print(e);
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

  _send() async {
    var result = await _recorder.stop();
    print("Stop recording: ${result.path}");
    print(result.path);
    filename = widget.id.toString() +
        DateTime.now().millisecondsSinceEpoch.toString() +
        ".wav";
    print("Stop recording: ${result.duration}");
    _file = widget.localFileSystem.file(result.path);
    print("File length: ${await _file.length()}");
    bytes = _file.readAsBytesSync();
    print(filename);
    chatModel.sendaudio(filename, bytes, widget.id, 3, widget.messages);
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
              widget.onInit();
              await _init();
            },
          ));
    });
  }
}
