import 'dart:async';

import 'package:flutter/material.dart';
import 'package:moonblink/api/moonblink_dio.dart';

class BookingTimeLeft extends StatefulWidget {
  final String upadateat;
  final int count;
  final int timeleft;
  BookingTimeLeft({this.upadateat, this.count, this.timeleft});

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
    var at = DateTime.parse(widget.upadateat).millisecondsSinceEpoch;
    int nowsec = (now / 1000).round();
    int atsec = (at / 1000).round();
    int left = nowsec - atsec;
    setState(() {
      lefttime = (widget.timeleft * 60 * widget.count) - left;
      if (isDev) print(lefttime);
    });
    timerCountDown(lefttime);
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
            setState(
              () {
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
              },
            );
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
