import 'dart:async';

import 'package:flutter/material.dart';

class BookingTimeLeft extends StatefulWidget {
  final String createat;
  BookingTimeLeft({this.createat});

  @override
  _BookingTimeLeftState createState() => _BookingTimeLeftState();
}

class _BookingTimeLeftState extends State<BookingTimeLeft> {
  Timer _timer;
  int lefttime;
  String min = '';
  String sec = '';

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  void initState() {
    super.initState();
    var now = DateTime.now().millisecondsSinceEpoch;
    var at = DateTime.parse(widget.createat).millisecondsSinceEpoch;
    int nowsec = (now / 1000).round();
    int atsec = (at / 1000).round();
    int left = nowsec - atsec;
    setState(() {
      lefttime = 300 - left;
      print(lefttime);
    });
    timerCountDown(lefttime);
    print("=======================================================");
  }

  Future<void> timerCountDown(countdown) async {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (countdown < 1) {
            timer.cancel();
          } else {
            countdown = countdown - 1;
            setState(() {
              lefttime = countdown - 1;
              if (lefttime >= 60) {
                min = (lefttime / 60).floor().toString().padLeft(1, '0');
                sec = '00';
              } else {
                min = '0';
              }
              sec = (lefttime <= 59 ? lefttime : lefttime % 60)
                  .floor()
                  .toString()
                  .padLeft(2, '0');
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("$min:$sec"),
    );
  }
}
