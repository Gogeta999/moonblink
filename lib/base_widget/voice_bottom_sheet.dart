import 'dart:async';

import 'package:flutter/material.dart';

class VoiceBottomSheet extends StatefulWidget {
  @required final Function send;
  @required final Function cancel;
  @required final Function start;

  const VoiceBottomSheet({Key key, this.send, this.cancel, this.start}) : super(key: key);

  @override
  _VoiceBottomSheetState createState() => _VoiceBottomSheetState();
}

class _VoiceBottomSheetState extends State<VoiceBottomSheet> with WidgetsBindingObserver{
  bool _isRecording = false;
  StreamSubscription<int> _tickerSubscription;
  String minutesStr = '0';
  String secondsStr = '00';

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if(_tickerSubscription != null) {
      _tickerSubscription.cancel();
    }
    widget.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _tickerSubscription.pause();
    }
    if (state == AppLifecycleState.resumed) {
      _tickerSubscription.resume();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          margin: EdgeInsets.all(5),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                alignment: Alignment.centerRight,
                child: FlatButton(
                  onPressed: _cancel,
                  child: Text('Cancel', style: Theme.of(context).textTheme.bodyText1),
                ),
              ),
              Container(
                  alignment: Alignment.center,
                  child: Column(
                    children: <Widget>[
                      Text('Voice Message', style: Theme.of(context).textTheme.bodyText1),
                      SizedBox(height: 5),
                      Text('Maximum one minute')
                    ],
                  ))
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Center(
            child: Text(
              '$minutesStr:$secondsStr', style: TextStyle(fontSize: 60),
            ),
          ),
        ),
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              if(_isRecording)
                Positioned(
                  bottom: 20,
                  left: 20,
                  width: MediaQuery.of(context).size.width * 0.425,
                  child: RaisedButton(
                    onPressed: _cancel,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('Cancel', style: TextStyle(fontSize: 16)),
                    padding: EdgeInsets.symmetric(vertical: 15),
                    color: Theme.of(context).accentColor,
                  ),
                ),
              if(_isRecording)
                Positioned(
                  bottom: 20,
                  right: 20,
                  width: MediaQuery.of(context).size.width * 0.425,
                  child: RaisedButton(
                    onPressed: _send,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('Send', style: TextStyle(fontSize: 16)),
                    padding: EdgeInsets.symmetric(vertical: 15),
                    color: Theme.of(context).accentColor,
                  ),
                ),
              if(!_isRecording)
              Positioned(
                bottom: 20,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: RaisedButton(
                    onPressed: _startRecord,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('Start Record', style: TextStyle(fontSize: 16)),
                    padding: EdgeInsets.symmetric(vertical: 15),
                    color: Theme.of(context).accentColor,
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  _startRecord() {
    widget.start();
    setState(() {
      _isRecording = true;
    });
    _tickerSubscription = Stream.periodic(Duration(seconds: 1), (x) => x + 1)
        .listen((duration) {
          print(duration);
          setState(() {
            if (duration >= 60) {
              minutesStr = (duration / 60)
                  .floor().toString().padLeft(1, '0');
              secondsStr = '00';
              _tickerSubscription.cancel();
              _send();
              return;
            }
            secondsStr = (duration <= 59 ? duration : duration % 60)
                .floor().toString().padLeft(2, '0');
          });
    });
  }

  _cancel() {
    Navigator.pop(context);
    widget.cancel();
  }

  _send() {
    ///do something
    widget.send();
    Navigator.pop(context);
  }
}