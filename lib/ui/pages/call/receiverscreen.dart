// import 'package:flutter/material.dart';
// import 'package:moonblink/global/resources_manager.dart';

// class ReceiverScreen extends StatefulWidget {
//   @override
//   _ReceiverScreen createState() => _ReceiverScreen();
// }

// class _ReceiverScreen extends State<ReceiverScreen> {
//   // Timer _timmerInstance;
//   // int _start = 0;
//   // String _timmer = '';

//   // void startTimmer() {
//   //   var oneSec = Duration(seconds: 1);
//   //   _timmerInstance = Timer.periodic(
//   //       oneSec,
//   //       (Timer timer) => setState(() {
//   //             if (_start < 0) {
//   //               _timmerInstance.cancel();
//   //             } else {
//   //               _start = _start + 1;
//   //               _timmer = getTimerTime(_start);
//   //             }
//   //           }));
//   // }

//   // String getTimerTime(int start) {
//   //   int minutes = (start ~/ 60);
//   //   String sMinute = '';
//   //   if (minutes.toString().length == 1) {
//   //     sMinute = '0' + minutes.toString();
//   //   } else
//   //     sMinute = minutes.toString();

//   //   int seconds = (start % 60);
//   //   String sSeconds = '';
//   //   if (seconds.toString().length == 1) {
//   //     sSeconds = '0' + seconds.toString();
//   //   } else
//   //     sSeconds = seconds.toString();

//   //   return sMinute + ':' + sSeconds;
//   // }

//   // @override
//   // void initState() {
//   //   super.initState();
//   //   startTimmer();
//   // }

//   // @override
//   // void dispose() {
//   //   _timmerInstance.cancel();
//   //   super.dispose();
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Container(
//           height: MediaQuery.of(context).size.height,
//           width: MediaQuery.of(context).size.width,
//           decoration: BoxDecoration(
//             color: Colors.white,
//           ),
//           padding: EdgeInsets.all(50.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             mainAxisSize: MainAxisSize.max,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: <Widget>[
//               SizedBox(
//                 height: 10.0,
//               ),
//               Text(
//                 'In Coming Call',
//                 style: TextStyle(
//                     color: Colors.deepPurpleAccent,
//                     fontWeight: FontWeight.w300,
//                     fontSize: 15),
//               ),
//               SizedBox(
//                 height: 20.0,
//               ),
//               Text(
//                 'Someone',
//                 style: TextStyle(
//                     color: Colors.deepPurpleAccent,
//                     fontWeight: FontWeight.w900,
//                     fontSize: 20),
//               ),
//               SizedBox(
//                 height: 20.0,
//               ),
//               Text(
//                 "Ringing",
//                 style: TextStyle(
//                     color: Colors.deepPurpleAccent,
//                     fontWeight: FontWeight.w300,
//                     fontSize: 15),
//               ),
//               SizedBox(
//                 height: 20.0,
//               ),
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(200.0),
//                 child: Image.asset(
//                   ImageHelper.wrapAssetsImage("busy.gif"),
//                   height: 200.0,
//                   width: 200.0,
//                 ),
//               ),
//               SizedBox(
//                 height: 50.0,
//               ),
//               Row(
//                 mainAxisSize: MainAxisSize.max,
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: <Widget>[
//                   FloatingActionButton(
//                     onPressed: () {
//                       //to Accept call
//                     },
//                     elevation: 20.0,
//                     shape: CircleBorder(side: BorderSide(color: Colors.green)),
//                     mini: false,
//                     child: Icon(
//                       Icons.call,
//                       color: Colors.green,
//                     ),
//                     backgroundColor: Colors.green[100],
//                   ),
//                   FloatingActionButton(
//                     onPressed: () {
//                       //to Reject call
//                     },
//                     elevation: 20.0,
//                     shape: CircleBorder(side: BorderSide(color: Colors.red)),
//                     mini: false,
//                     child: Icon(
//                       Icons.call_end,
//                       color: Colors.red,
//                     ),
//                     backgroundColor: Colors.red[100],
//                   )
//                 ],
//               ),
//               SizedBox(
//                 height: 120.0,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
