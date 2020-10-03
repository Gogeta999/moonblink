// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:moonblink/generated/l10n.dart';
// import 'package:moonblink/utils/platform_utils.dart';
// import 'package:oktoast/oktoast.dart';

// class PubgMobile extends StatelessWidget {
//   _showMaterialDialog(BuildContext context, TextEditingController controller) {
//     showDialog(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             title: Text(G.of(context).labelid, textAlign: TextAlign.center),
//             content: CupertinoTextField(
//               decoration:
//                   BoxDecoration(color: Theme.of(context).backgroundColor),
//               controller: controller,
//             ),
//             actions: <Widget>[
//               FlatButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: Text(G.of(context).cancel),
//               ),
//               FlatButton(
//                 onPressed: () {
//                   print(controller.text);
//                   Navigator.pop(context);
//                 },
//                 child: Text(G.of(context).submit),
//               )
//             ],
//           );
//         });
//   }

//   _showCupertinoDialog(BuildContext context, TextEditingController controller) {
//     showCupertinoDialog(
//         context: context,
//         builder: (context) {
//           return CupertinoAlertDialog(
//             title: Text(G.of(context).labelid, textAlign: TextAlign.center),
//             content: CupertinoTextField(
//               decoration:
//                   BoxDecoration(color: Theme.of(context).backgroundColor),
//               controller: controller,
//             ),
//             actions: <Widget>[
//               FlatButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: Text(G.of(context).cancel),
//               ),
//               FlatButton(
//                 onPressed: () {
//                   print(controller.text);
//                   Navigator.pop(context);
//                 },
//                 child: Text(G.of(context).submit),
//               )
//             ],
//           );
//         });
//   }

//   _showCupertinoBottomSheet(BuildContext context) {
//     showCupertinoModalPopup(
//         context: context,
//         builder: (context) {
//           return CupertinoActionSheet(
//             title: Text('Select Level'),
//             actions: <Widget>[
//               CupertinoActionSheetAction(
//                   onPressed: () {
//                     showToast('Bronze');
//                     Navigator.pop(context);
//                   },
//                   child: Text('Bronze',
//                       style: Theme.of(context).textTheme.bodyText1)),
//               CupertinoActionSheetAction(
//                   onPressed: () {
//                     showToast('Bronze');
//                     Navigator.pop(context);
//                   },
//                   child: Text('Silver',
//                       style: Theme.of(context).textTheme.bodyText1)),
//               CupertinoActionSheetAction(
//                   onPressed: () {
//                     showToast('Bronze');
//                     Navigator.pop(context);
//                   },
//                   child: Text('Gold',
//                       style: Theme.of(context).textTheme.bodyText1)),
//               CupertinoActionSheetAction(
//                   onPressed: () {
//                     showToast('Bronze');
//                     Navigator.pop(context);
//                   },
//                   child: Text('Platinum',
//                       style: Theme.of(context).textTheme.bodyText1)),
//               CupertinoActionSheetAction(
//                   onPressed: () {
//                     showToast('Bronze');
//                     Navigator.pop(context);
//                   },
//                   child: Text('Diamond',
//                       style: Theme.of(context).textTheme.bodyText1)),
//               CupertinoActionSheetAction(
//                   onPressed: () {
//                     showToast('Bronze');
//                     Navigator.pop(context);
//                   },
//                   child: Text('Crown',
//                       style: Theme.of(context).textTheme.bodyText1)),
//               CupertinoActionSheetAction(
//                   onPressed: () {
//                     showToast('Bronze');
//                     Navigator.pop(context);
//                   },
//                   child: Text('Ace',
//                       style: Theme.of(context).textTheme.bodyText1)),
//             ],
//             cancelButton: CupertinoButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text(G.of(context).cancel),
//             ),
//           );
//         });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('PUBG Mobile'),
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(10),
//         physics: ClampingScrollPhysics(),
//         children: <Widget>[
//           Text(G.of(context).skilldescription,
//               style: Theme.of(context).textTheme.bodyText1),
//           SizedBox(height: 20),
//           Text(G.of(context).pubg,
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w300,
//               )),
//           SizedBox(height: 20),
//           Text(G.of(context).qualificationrequire,
//               style: Theme.of(context).textTheme.bodyText1),
//           SizedBox(height: 20),
//           Text(G.of(context).pubgrequirement1,
//               style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300)),
//           Text(G.of(context).pubgrequirement2,
//               style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300)),
//           SizedBox(height: 20),
//           Divider(
//             thickness: 1,
//           ),
//           SizedBox(height: 20),
//           Text(G.of(context).fillskilllevel,
//               style: Theme.of(context).textTheme.bodyText1),
//           SizedBox(height: 20),
//           InkResponse(
//             onTap: () {
//               TextEditingController _controller = TextEditingController();
//               if (Platform.isAndroid) {
//                 _showMaterialDialog(context, _controller);
//               } else if (Platform.isIOS) {
//                 _showCupertinoDialog(context, _controller);
//               } else {
//                 showToast(G.of(context).toastplatformnotsupport);
//               }
//             },
//             child: Row(
//               children: <Widget>[
//                 Expanded(
//                   child: Text('Game ID'),
//                 ),
//                 Icon(Icons.arrow_forward_ios, size: 14)
//               ],
//             ),
//           ),
//           SizedBox(height: 20),
//           InkResponse(
//             onTap: () {
//               if (Platform.isAndroid) {
//                 _showCupertinoBottomSheet(context);
//               } else if (Platform.isIOS) {
//                 _showCupertinoBottomSheet(context);
//               } else {
//                 showToast(G.of(context).toastplatformnotsupport);
//               }
//             },
//             child: Row(
//               children: <Widget>[
//                 Expanded(
//                   child: Text('Level'),
//                 ),
//                 Icon(Icons.arrow_forward_ios, size: 14)
//               ],
//             ),
//           ),
//           SizedBox(height: 20),
//           Divider(thickness: 1),
//           SizedBox(height: 20),
//           Text(G.of(context).uploadskillcover,
//               style: Theme.of(context).textTheme.bodyText1),
//           SizedBox(height: 20),
//           Text(G.of(context).toastscreenshot,
//               style: TextStyle(color: Colors.deepOrangeAccent)),
//           SizedBox(height: 20),
//           Row(
//             children: <Widget>[
//               Expanded(
//                 child: Image.asset(
//                   'assets/logos/MoonBlink_logo.png',
//                   height: 70,
//                 ),
//               ),
//               Expanded(
//                   child: Icon(
//                 Icons.add_box,
//                 size: 150,
//                 color: Colors.grey,
//               ))
//             ],
//           ),
//           Row(
//             mainAxisSize: MainAxisSize.max,
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: <Widget>[
//               Text(G.of(context).samplephoto,
//                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300)),
//               Text(G.of(context).uploadcover,
//                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300)),
//             ],
//           ),
//           SizedBox(height: 20),
//           Divider(thickness: 1),
//           SizedBox(height: 20),
//           Text(G.of(context).recordskillaudio,
//               style: Theme.of(context).textTheme.bodyText1),
//           SizedBox(height: 20),
//           Text(G.of(context).rule1,
//               style: TextStyle(color: Colors.deepOrangeAccent)),
//           SizedBox(height: 20),
//           Text('00:00',
//               style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
//               textAlign: TextAlign.center),
//           SizedBox(height: 20),
//           Center(
//               child: Platform.isAndroid
//                   ? RaisedButton(
//                       onPressed: () {},
//                       padding: EdgeInsets.symmetric(
//                           vertical: 10,
//                           horizontal: MediaQuery.of(context).size.width * 0.2),
//                       child:
//                           Icon(Icons.mic_none, size: 32, color: Colors.white),
//                       color: Theme.of(context).primaryColor,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.all(Radius.circular(32.0)),
//                       ),
//                     )
//                   : CupertinoButton(
//                       onPressed: () {},
//                       padding: EdgeInsets.symmetric(
//                           vertical: 10,
//                           horizontal: MediaQuery.of(context).size.width * 0.2),
//                       child:
//                           Icon(Icons.mic_none, size: 32, color: Colors.white),
//                       color: Theme.of(context).primaryColor,
//                       borderRadius: BorderRadius.all(Radius.circular(32.0)),
//                     )),
//           SizedBox(height: 20),
//           Text(G.of(context).buttonstartrecord,
//               style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
//               textAlign: TextAlign.center),
//           SizedBox(height: 20),
//           Divider(thickness: 1),
//           SizedBox(height: 20),
//           Text('About order taking',
//               style: Theme.of(context).textTheme.bodyText1),
//           SizedBox(height: 20),
//           Text(
//               'Simply introduce your service features, and the time you can take orders.',
//               style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300))
//         ],
//       ),
//     );
//   }
// }
