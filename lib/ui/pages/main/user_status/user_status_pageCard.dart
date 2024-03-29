// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:clipboard/clipboard.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:moonblink/base_widget/BottomClipper.dart';
// import 'package:moonblink/base_widget/appbar/appbarlogo.dart';
// import 'package:moonblink/base_widget/curvepanel.dart';
// import 'package:moonblink/generated/l10n.dart';
// import 'package:moonblink/global/resources_manager.dart';
// import 'package:moonblink/global/router_manager.dart';
// import 'package:moonblink/global/storage_manager.dart';
// import 'package:moonblink/models/wallet.dart';
// import 'package:moonblink/provider/provider_widget.dart';
// import 'package:moonblink/services/moonblink_repository.dart';
// import 'package:moonblink/ui/helper/encrypt.dart';
// import 'package:moonblink/ui/helper/icons.dart';
// import 'package:moonblink/ui/helper/openfacebook.dart';
// import 'package:moonblink/ui/helper/openstore.dart';
// import 'package:moonblink/utils/platform_utils.dart';
// import 'package:moonblink/view_model/login_model.dart';
// import 'package:moonblink/view_model/theme_model.dart';
// import 'package:moonblink/view_model/user_model.dart';
// import 'package:oktoast/oktoast.dart';
// import 'package:provider/provider.dart';

// class UserStatusPage extends StatefulWidget {
//   @override
//   _UserStatusPageState createState() => _UserStatusPageState();
// }

// class _UserStatusPageState extends State<UserStatusPage> {
//   Wallet wallet = Wallet(value: 0);
//   bool hasUser = false;

//   @override
//   void initState() {
//     // PushNotificationsManager().showgameprofilenoti();
//     if (StorageManager.sharedPreferences.getString(token) != null) init();
//     print('token: ${StorageManager.sharedPreferences.getString(token)}');
//     super.initState();
//   }

//   init() async {
//     Wallet wallet = await MoonBlinkRepository.getUserWallet();
//     setState(() {
//       this.wallet = wallet;
//       hasUser = true;
//     });
//   }

//   Widget userinfo() {
//     var userName = StorageManager.sharedPreferences.getString(mLoginName);
//     int userid = StorageManager.sharedPreferences.getInt(mUserId);
//     return Container(
//       padding: EdgeInsets.symmetric(vertical: 10),
//       decoration: BoxDecoration(
//         border: Border.all(width: 2, color: Colors.black),
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: Column(
//         children: [
//           Center(
//             child: Text(
//               userName,
//               style: TextStyle(
//                   fontSize: 26,
//                   color: Theme.of(context).brightness == Brightness.dark
//                       ? Colors.white
//                       : Colors.black),
//             ),
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               IconButton(
//                 icon: Icon(Icons.content_copy),
//                 iconSize: 18,
//                 color: Theme.of(context).brightness == Brightness.dark
//                     ? Colors.white
//                     : Colors.black,
//                 onPressed: () {
//                   String id = encrypt(userid);
//                   FlutterClipboard.copy(id).then((value) {
//                     showToast(G.of(context).toastcopy);
//                     print('copied');
//                   });
//                 },
//               ),
//               Text("copy ID")
//             ],
//           ),
//           if (hasUser)
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 Icon(
//                   FontAwesomeIcons.coins,
//                   color: Colors.amber[500],
//                   size: 20,
//                 ),
//                 SizedBox(width: 5.0),
//                 Text(
//                     '${G.of(context).currentcoin} : ${wallet.value} ${wallet.value > 1 ? 'coins' : 'coin'}',
//                     style: TextStyle(fontSize: 16)),
//               ],
//             ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     // int usertype = StorageManager.sharedPreferences.getInt(mUserType);
//     return Scaffold(
//       body: CustomScrollView(
//         slivers: <Widget>[
//           SliverAppBar(
//             ///[Appbar]
//             backgroundColor: Colors.black,
//             pinned: true,
//             // toolbarHeight: kToolbarHeight - 5,
//             // expandedHeight: kToolbarHeight,
//             // brightness: Theme.of(context).brightness == Brightness.light
//             //     ? Brightness.light
//             //     : Brightness.dark,
//             actions: <Widget>[
//               AppbarLogo(),
//             ],
//             flexibleSpace: null,
//             bottom: PreferredSize(
//                 child: Container(
//                   height: 10,
//                   color: Theme.of(context).accentColor,
//                 ),
//                 preferredSize: Size.fromHeight(10)),
//           ),
//           SliverToBoxAdapter(
//             child: Container(
//               height: MediaQuery.of(context).size.height / 2.7,
//               child: Stack(
//                 children: [
//                   UserStatusCurve(),
//                   // Padding(
//                   //   padding: EdgeInsets.only(
//                   //       top: MediaQuery.of(context).size.height * 0.1),
//                   //   child: UserHeaderWidget(),
//                   // ),
//                   Align(
//                     alignment: Alignment.center,
//                     child: UserHeaderWidget(),
//                   )
//                 ],
//               ),
//             ),
//           ),
//           SliverToBoxAdapter(
//             child: userinfo(),
//           ),
//           SliverPadding(
//             padding: EdgeInsets.only(top: 10),
//           ),
//           UserListWidget(),
//           SliverToBoxAdapter(
//             child: SizedBox(
//               height: 20,
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

// class UserHeaderWidget extends StatefulWidget {
//   @override
//   _UserHeaderWidgetState createState() => _UserHeaderWidgetState();
// }

// class _UserHeaderWidgetState extends State<UserHeaderWidget> {
//   @override
//   Widget build(BuildContext context) {
//     var userProfile = StorageManager.sharedPreferences.getString(mUserProfile);

//     return ClipPath(
//       // in widget
//       clipper: BottomClipper(),
//       child: Container(
//         // color: Theme.of(context).primaryColor.withAlpha(200),
//         padding: EdgeInsets.only(top: 10),
//         child: Consumer<UserModel>(
//           builder: (context, model, child) => InkWell(
//             onTap: model.hasUser
//                 ? null
//                 : () {
//                     Navigator.of(context).pushNamed(RouteName.login);
//                   },
//             child: Center(
//               child: InkWell(
//                 onTap: () {
//                   // int usertype =
//                   //     StorageManager.sharedPreferences.getInt(mUserType);
//                   /*if (usertype != 0) {
//                     Navigator.of(context)
//                         .pushNamed(RouteName.partnerOwnProfile);
//                   } else */
//                   if (model?.user?.token == null) {
//                     Navigator.of(context).pushNamed(RouteName.login);
//                   } else {
//                     Navigator.of(context)
//                         .pushNamed(RouteName.partnerOwnProfile);
//                   }
//                 },
//                 child: Hero(
//                   tag: 'loginLogo',
//                   child: model.hasUser
//                       ? CachedNetworkImage(
//                           imageUrl: userProfile,
//                           imageBuilder: (context, item) {
//                             return Container(
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 shape: BoxShape.circle,
//                                 border:
//                                     Border.all(width: 2, color: Colors.black),
//                                 boxShadow: [
//                                   BoxShadow(
//                                       // blurRadius: 10,
//                                       color: Colors.black,
//                                       offset: Offset(0, 5),
//                                       spreadRadius: 2)
//                                 ],
//                               ),
//                               child: CircleAvatar(
//                                 radius: 70,
//                                 backgroundImage: item,
//                               ),
//                             );
//                           },
//                           fit: BoxFit.cover,
//                           width: 120,
//                           height: 120,
//                         )
//                       : Container(
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             shape: BoxShape.circle,
//                             border: Border.all(width: 2, color: Colors.black),
//                             boxShadow: [
//                               BoxShadow(
//                                   // blurRadius: 10,
//                                   color: Colors.black,
//                                   offset: Offset(0, 5),
//                                   spreadRadius: 2)
//                             ],
//                           ),
//                           child: CircleAvatar(
//                             radius: 72,
//                             backgroundColor: Colors.black,
//                             child: CircleAvatar(
//                               radius: 70,
//                               backgroundImage: AssetImage(
//                                 ImageHelper.wrapAssetsImage(
//                                     'MoonBlinkProfile.jpg'),
//                               ),
//                             ),
//                           ),
//                         ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class Logout extends StatefulWidget {
//   @override
//   _LogoutState createState() => _LogoutState();
// }

// class _LogoutState extends State<Logout> {
//   @override
//   Widget build(BuildContext context) {
//     return ProviderWidget<LoginModel>(
//       model: LoginModel(Provider.of(context)),
//       builder: (context, model, child) {
//         return PageCard(
//           pageTitle: G.of(context).logout,
//           iconData: FontAwesomeIcons.signOutAlt,
//           color: Colors.black,
//           onTap: () {
//             model.logout();
//             Navigator.of(context)
//                 .pushNamedAndRemoveUntil(RouteName.login, (route) => false);
//           },
//         );
//       },
//     );
//   }
// }

// class UserListWidget extends StatefulWidget {
//   // var statusModel = Provider.of < (context);

//   @override
//   _UserListWidgetState createState() => _UserListWidgetState();
// }

// class _UserListWidgetState extends State<UserListWidget> {
//   final hasUser = StorageManager.localStorage.getItem(mUser);

//   int usertype = StorageManager.sharedPreferences.getInt(mUserType);

//   @override
//   Widget build(BuildContext context) {
//     int status = StorageManager.sharedPreferences.getInt(mstatus);
//     print("user type is ${usertype.toString()}");
//     print("user status is ${status.toString()}");

//     return SliverGrid(
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         childAspectRatio: 3 / 2,
//         mainAxisSpacing: 15.0,
//       ),
//       delegate: SliverChildListDelegate.fixed(
//         [
//           if (usertype != 0)
//             SVGPageCard(
//                 pageTitle:
//                     status != 1 ? G.of(context).online : G.of(context).offline,
//                 iconData: status != 1 ? online : offline,
//                 color: Colors.redAccent,
//                 onTap: status != 1
//                     ? () {
//                         setState(() {
//                           StorageManager.sharedPreferences.setInt(mstatus, 1);
//                         });
//                         print(status);
//                         print("+++++++++++++++++++++++++++");
//                         MoonBlinkRepository.changestatus(1);
//                         showToast(G.of(context).toastoffline);
//                       }
//                     : () {
//                         setState(() {
//                           StorageManager.sharedPreferences.setInt(mstatus, 0);
//                           // status = 0;
//                         });
//                         print(status);
//                         print("----------------------------");
//                         MoonBlinkRepository.changestatus(0);
//                         showToast(G.of(context).toastonline);
//                       }),

//           ///profile
//           if (usertype != 0)
//             SVGPageCard(
//                 pageTitle: G.of(context).profilegame,
//                 iconData: gameProfile,
//                 color: Colors.blueGrey,
//                 onTap: () => Navigator.of(context)
//                     .pushNamed(RouteName.chooseUserPlayGames)),

//           //if (usertype != 0)
//           SVGPageCard(
//               pageTitle: G.of(context).profileown,
//               iconData: profileEdit,
//               color: Colors.deepOrange,
//               onTap: () =>
//                   Navigator.of(context).pushNamed(RouteName.partnerOwnProfile)),

//           ///wallet
//           SVGPageCard(
//               pageTitle: G.of(context).userStatusWallet,
//               iconData: wallet,
//               color: Colors.greenAccent,
//               onTap: hasUser == null
//                   ? () {
//                       showToast(G.of(context).loginFirst);
//                     }
//                   : () {
//                       Navigator.of(context).pushNamed(RouteName.wallet);
//                     }),

//           ///switch dark mode
//           PageCard(
//               pageTitle: Theme.of(context).brightness == Brightness.light
//                   ? G.of(context).userStatusDayMode
//                   : G.of(context).userStatusDarkMode,
//               iconData: Theme.of(context).brightness == Brightness.light
//                   // ? IconFonts.dayModeIcon
//                   ? FontAwesomeIcons.sun
//                   : FontAwesomeIcons.moon,
//               color: Colors.purpleAccent,
//               onTap: () => _switchDarkMode(context)),

//           ///theme
//           SVGPageCard(
//               pageTitle: G.of(context).userStatusTheme,
//               iconData: theme,
//               color: Colors.pinkAccent,
//               onTap: () => _showPaletteDialog(context)),

//           ///Customer Service
//           SVGPageCard(
//             pageTitle: G.of(context).userStatusCustomerService,
//             iconData: customerservice,
//             color: Colors.red,
//             onTap: hasUser == null
//                 ? () {
//                     showToast(G.of(context).loginFirst);
//                   }
//                 // : () {
//                 //     Navigator.of(context).pushNamed(RouteName.network);
//                 //   }),
//                 : openCustomerServicePage,
//           ),

//           ///settings
//           SVGPageCard(
//               pageTitle: G.of(context).userStatusSettings,
//               iconData: setting,
//               color: Colors.grey,
//               onTap: () => Navigator.of(context).pushNamed(RouteName.setting)),

//           ///check app update
//           PageCard(
//             pageTitle: G.of(context).userStatusCheckAppUpdate,
//             iconData: Platform.isAndroid
//                 ? FontAwesomeIcons.android
//                 : FontAwesomeIcons.appStoreIos,
//             color: Colors.blue,
//             onTap: openStore,
//           ),
//           if (StorageManager.sharedPreferences.getString(token) != null)
//             Logout(),
//         ],
//       ),
//     );
//   }

//   void _switchDarkMode(BuildContext context) {
//     if (MediaQuery.of(context).platformBrightness == Brightness.dark) {
//     } else {
//       Provider.of<ThemeModel>(context, listen: false).switchTheme(
//           userDarkMode: Theme.of(context).brightness == Brightness.light);
//     }
//   }

//   void _showPaletteDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return Dialog(child: SettingThemeWidget());
//       },
//     );
//   }
// }

// class PageCard extends StatelessWidget {
//   final String pageTitle;
//   final IconData iconData;
//   final Color color;
//   final Function onTap;

//   const PageCard(
//       {Key key,
//       @required this.pageTitle,
//       @required this.iconData,
//       @required this.color,
//       @required this.onTap})
//       : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return InkResponse(
//       onTap: onTap,
//       child: Container(
//         // height: 100,
//         decoration: BoxDecoration(
//           color: Theme.of(context).cardColor,
//           border: Border.all(width: 1, color: Colors.black),
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Theme.of(context).brightness == Brightness.dark
//                   ? Colors.black
//                   : Colors.black,
//               spreadRadius: -5,
//               // blurRadius: 2,
//               offset: Offset(-15, 15), // changes position of shadow
//             ),
//           ],
//         ),
//         margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: <Widget>[
//             Icon(
//               iconData,
//               color: color == null ? Theme.of(context).iconTheme.color : color,
//               size: 30.0,
//             ),
//             Center(
//               child: Text(pageTitle,
//                   style: Theme.of(context).textTheme.bodyText1,
//                   // TextStyle(
//                   //     fontWeight: FontWeight.w700, color: Colors.white),
//                   softWrap: true),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

// class SVGPageCard extends StatelessWidget {
//   final String pageTitle;
//   final String iconData;
//   final Color color;
//   final Function onTap;

//   const SVGPageCard(
//       {Key key,
//       @required this.pageTitle,
//       @required this.iconData,
//       @required this.color,
//       @required this.onTap})
//       : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return InkResponse(
//       onTap: onTap,
//       child: Container(
//         // height: 100,
//         decoration: BoxDecoration(
//           color: Theme.of(context).cardColor,
//           border: Border.all(width: 1, color: Colors.black),
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Theme.of(context).brightness == Brightness.dark
//                   ? Colors.black
//                   : Colors.black,
//               spreadRadius: -5,
//               // blurRadius: 2,
//               offset: Offset(-15, 15), // changes position of shadow
//             ),
//           ],
//         ),
//         margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: <Widget>[
//             SvgPicture.asset(
//               iconData,
//               color: color == null ? Theme.of(context).iconTheme.color : color,
//               height: 50,
//               width: 50,
//               fit: BoxFit.contain,
//             ),
//             Center(
//               child: Text(pageTitle,
//                   style: Theme.of(context).textTheme.bodyText1,
//                   // TextStyle(
//                   //     fontWeight: FontWeight.w700, color: Colors.white),
//                   softWrap: true),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

// class SettingThemeWidget extends StatelessWidget {
//   SettingThemeWidget();

//   @override
//   Widget build(BuildContext context) {
//     return ExpansionTile(
//       title: Text(G.of(context).userStatusTheme),
//       leading: Icon(
//         FontAwesomeIcons.palette,
//         color: Theme.of(context).accentColor,
//       ),
//       initiallyExpanded: true,
//       children: <Widget>[
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//           child: Wrap(
//             spacing: 5,
//             runSpacing: 5,
//             children: <Widget>[
//               ...Colors.primaries.map((color) {
//                 return Material(
//                   color: color,
//                   child: InkWell(
//                     onTap: () {
//                       var model =
//                           Provider.of<ThemeModel>(context, listen: false);
//                       // var brightness = Theme.of(context).brightness;
//                       model.switchTheme(color: color);
//                     },
//                     child: Container(
//                       width: 40,
//                       height: 40,
//                     ),
//                   ),
//                 );
//               }).toList(),
//               Material(
//                 child: InkWell(
//                   onTap: () {
//                     var model = Provider.of<ThemeModel>(context, listen: false);
//                     var brightness = Theme.of(context).brightness;
//                     model.switchRandomTheme(brightness: brightness);
//                   },
//                   child: Container(
//                     alignment: Alignment.center,
//                     decoration: BoxDecoration(
//                         border:
//                             Border.all(color: Theme.of(context).accentColor)),
//                     width: 40,
//                     height: 40,
//                     child: Text(
//                       "?",
//                       style: TextStyle(
//                           fontSize: 20, color: Theme.of(context).accentColor),
//                     ),
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
