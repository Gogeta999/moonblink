import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:io' as io;
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:moonblink/models/message.dart';
import 'package:moonblink/services/chat_service.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scoped_model/scoped_model.dart';

class Voicemsg extends StatefulWidget {
  final LocalFileSystem localFileSystem;
  final id;
  final messages;
  // final file;
  // final bytes;

  Voicemsg({localFileSystem, this.id, this.messages})
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
  @override
  void initState() { 
    super.initState();
    _init();
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
      } else {
        Scaffold.of(context).showSnackBar(
            new SnackBar(content: new Text("You must accept permissions")));
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

      const tick = const Duration(milliseconds: 50);
      new Timer.periodic(tick, (Timer t) async {
        if (_currentStatus == RecordingStatus.Stopped) {
          t.cancel();
        }

        var current = await _recorder.current(channel: 0);
        // print(current.status);
        setState(() {
          _current = current;
          _currentStatus = _current.status;
        });
      });
    } catch (e) {
      print(e);
    }
  }
  _stop(String filename, File file, Uint8List bytes, model) async {
    var result = await _recorder.stop();
    print("Stop recording: ${result.path}");
    print(result.path);
    filename = widget.id.toString() +DateTime.now().millisecondsSinceEpoch.toString() + ".wav"; 
    print("Stop recording: ${result.duration}");
    file = widget.localFileSystem.file(result.path);
    print("File length: ${await file.length()}");
    bytes = file.readAsBytesSync();
    print(filename);
    // print(files.runtimeType);
    model.sendaudio(filename, bytes, widget.id, 3, widget.messages);
    // setState(() {
    //   file = widget.localFileSystem.file(result.path);
    //   _current = result;
    //   _currentStatus = _current.status;
    // });
  }
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<ChatModel>(
    builder: (context,child, model) {
    return Container(
    height: 30,
    width: 30,
    child: GestureDetector(
      child: Icon(Icons.voicemail, color: Theme.of(context).accentColor,),
      onLongPressStart:(LongPressStartDetails details){
        _start();
        showToast("Start Recording Your message");
      },
      onLongPressUp: () {
        _stop(filename, _file, bytes, model);
        showToastWidget(Icon(Icons.error));
      },
      )
    );
    });
  }
}