import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_plugin_record/index.dart';
import 'package:moonblink/api/moonblink_dio.dart';
import 'package:moonblink/generated/l10n.dart';

class VoiceBottomSheet extends StatefulWidget {
  @required
  final Function(File file) send;

  const VoiceBottomSheet({Key key, this.send}) : super(key: key);

  @override
  _VoiceBottomSheetState createState() => _VoiceBottomSheetState();
}

class _VoiceBottomSheetState extends State<VoiceBottomSheet>
/*with WidgetsBindingObserver*/ {
  FlutterPluginRecord _flutterPluginRecord = FlutterPluginRecord()..init();
  bool _isRecording = false;
  bool _pressedSend = false;
  StreamSubscription<int> _tickerSubscription;
  String minutesStr = '0';
  String secondsStr = '00';

  @override
  void initState() {
    _flutterPluginRecord.response.listen((data) {
      if (data.msg == "onStop") {
        if (_pressedSend) {
          if (isDev) print("onStop  " + data.path);
          widget.send(File(data.path));
          Navigator.pop(context);
        }
      } else if (data.msg == "onStart") {
        if (isDev) print("onStart --");
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _tickerSubscription?.cancel();
    _flutterPluginRecord.stop();
    _flutterPluginRecord.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(5),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  alignment: Alignment.centerRight,
                  child: CupertinoButton(
                    onPressed: _cancel,
                    child: Text(G.of(context).cancel,
                        style: TextStyle(color: Theme.of(context).accentColor)),
                  ),
                ),
                Container(
                    alignment: Alignment.center,
                    child: Column(
                      children: <Widget>[
                        Text(G.of(context).labelvoicemsg,
                            style: TextStyle(
                                color: Theme.of(context).accentColor)),
                        SizedBox(height: 5),
                        Text(G.of(context).maxtime,
                            style:
                                TextStyle(color: Theme.of(context).accentColor))
                      ],
                    ))
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                '$minutesStr:$secondsStr',
                style: TextStyle(fontSize: 60),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                if (_isRecording)
                  Positioned(
                    bottom: 20,
                    left: 20,
                    width: MediaQuery.of(context).size.width * 0.425,
                    child: RaisedButton(
                      onPressed: _restart,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(G.of(context).buttonrestart,
                          style: TextStyle(fontSize: 16)),
                      padding: EdgeInsets.symmetric(vertical: 15),
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                if (_isRecording)
                  Positioned(
                    bottom: 20,
                    right: 20,
                    width: MediaQuery.of(context).size.width * 0.425,
                    child: RaisedButton(
                      onPressed: _send,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(G.of(context).sendbutton,
                          style: TextStyle(fontSize: 16)),
                      padding: EdgeInsets.symmetric(vertical: 15),
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                if (!_isRecording)
                  Positioned(
                    bottom: 20,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: RaisedButton(
                        onPressed: _startRecord,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(G.of(context).buttonstartrecord,
                            style: TextStyle(fontSize: 16)),
                        padding: EdgeInsets.symmetric(vertical: 15),
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  )
              ],
            ),
          )
        ],
      ),
    );
  }

  _startRecord() {
    _flutterPluginRecord.start();
    setState(() {
      _isRecording = true;
    });
    _tickerSubscription =
        Stream.periodic(Duration(seconds: 1), (x) => x + 1).listen((duration) {
      setState(() {
        if (duration >= 60) {
          minutesStr = (duration / 60).floor().toString().padLeft(1, '0');
          secondsStr = '00';
          _tickerSubscription.cancel();
          _send();
          return;
        }
        secondsStr = (duration <= 59 ? duration : duration % 60)
            .floor()
            .toString()
            .padLeft(2, '0');
      });
    });
  }

  _restart() {
    _flutterPluginRecord.stop();
    _tickerSubscription.cancel();
    setState(() {
      _isRecording = false;
      minutesStr = '0';
      secondsStr = '00';
    });
  }

  _cancel() {
    Navigator.pop(context);
  }

  _send() {
    _flutterPluginRecord.stop();
    _pressedSend = true;
  }
}