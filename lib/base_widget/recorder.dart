import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:io' as io;
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:path_provider/path_provider.dart';

class Voicemsg extends StatefulWidget {
  final LocalFileSystem localFileSystem;
  final model;

  Voicemsg({localFileSystem, this.model})
      : this.localFileSystem = localFileSystem ?? LocalFileSystem();

  @override
  _VoicemsgState createState() => _VoicemsgState();
}

class _VoicemsgState extends State<Voicemsg> {
  FlutterAudioRecorder _recorder;
  Recording _current;
  RecordingStatus _currentStatus = RecordingStatus.Unset;
  @override
  void initState() { 
    super.initState();
    _init();
  }
  _init() async {
    try {
      if (await FlutterAudioRecorder.hasPermissions) {
        String customPath = '/flutter_audio_recorder_';
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
  _stop() async {
    var result = await _recorder.stop();
    print("Stop recording: ${result.path}");
    print(result.path.runtimeType);
    print("Stop recording: ${result.duration}");
    File file = widget.localFileSystem.file(result.path);
    print("File length: ${await file.length()}");
    print(file.runtimeType);
    setState(() {
      _current = result;
      _currentStatus = _current.status;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
    height: 20,
    width: 20,
    child: GestureDetector(
      child: Icon(Icons.voice_chat, color: Theme.of(context).accentColor,),
      onLongPressStart:(LongPressStartDetails details)=> _start(),
      onLongPressUp: ()=> _stop(),
    )
    );
  }
}