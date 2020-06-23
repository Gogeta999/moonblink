import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/ui/pages/main/chat/chatlist_page.dart';
import 'package:moonblink/ui/pages/main/contacts/contacts_page.dart';
import 'package:moonblink/ui/pages/main/home/home_page.dart';
import 'package:moonblink/ui/pages/main/user_status/user_status_page.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';


List<Widget> pages = <Widget>[
  HomePage(),
  ChatListPage(),
  ContactsPage(),
  UserStatusPage(),
];

class MainTabPage extends StatefulWidget {
  MainTabPage({Key key}) : super(key: key);

  @override
  _MainTabPageState createState() => _MainTabPageState();
}


class _MainTabPageState extends State<MainTabPage> with SingleTickerProviderStateMixin {
  var _pageController = PageController();
  int _selectedIndex = 0;
  DateTime _lastPressed;
  
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          if (_lastPressed == null ||
              DateTime.now().difference(_lastPressed) > Duration(seconds: 1)){
              // if time is separate more than 1 second, then continue to count
              _lastPressed = DateTime.now();
              return false;
              }
            return true;
        },
        child: PageView.builder(
          // this ctx is also context, but avoid to affect from PageState's context
          itemBuilder: (ctx, index) => pages[index],
          itemCount: pages.length,
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          onPageChanged: (index){
            setState(() {
              _selectedIndex = index;
            });
          },
          ),
        ),
      bottomNavigationBar: FancyBottomNavigation(
        tabs: [
            TabData(iconData: FontAwesomeIcons.home, title: "Home"),
            TabData(iconData: FontAwesomeIcons.commentAlt, title:"Chat"),
            TabData(iconData: FontAwesomeIcons.calendar, title:"Contacts"),
            TabData(iconData: FontAwesomeIcons.userAlt, title: "User" ),
        ],
          circleHeight: 50,
          arcHeight: 55,
          arcWidth: 80,
          barHeight: 55,
          circleColor: Theme.of(context).accentColor,
          onTabChangedListener: (index){
            _pageController.jumpToPage(index);
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
    );
  }

}










//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         body: PageView(
//           controller: _controller,
//           children: <Widget>[
//             HomePage(),
//             ChatListPage(),
//             ContactsPage(),
//             UserStatusPage()
//           ],
//           physics: NeverScrollableScrollPhysics(),
//         ),
//   // customize facybottombar
//   // FancyBottomNavigation(
//   //     {@required this.tabs,
//   //     this.onTabChangedListener,
//   //     this.key,
//   //     this.initialSelection = 0,
//   //     this.circleColor,
//   //     this.circleHeight = kCircleHeight,
//   //     this.circleOutline = kCircleOutline,
//   //     this.arcHeight = kArcHeight,
//   //     this.arcWidth = kArcWidth,
//   //     this.shadowAllowance = kShadowAllowance,
//   //     this.barHeight = kBarHeight,
//   //     this.activeIconColor,
//   //     this.inactiveIconColor,
//   //     this.titleStyle = const TextStyle(),
//   //     this.gradient,
//   //     this.barBackgroundColor,
//   //     this.shadowColor,
//   //     this.inactiveIconSize,
//   //     this.activeIconSize,
//   //     this.animDuration = 300,
//   //     this.pageController})
//         bottomNavigationBar: FancyBottomNavigation(
//           // circleHeight: 20,
//           circleHeight: 50,
//           arcHeight: 55,
//           arcWidth: 80,
//           barHeight: 55,
//           // shadowColor: Theme.of(context).textSelectionColor,
//           circleColor: Theme.of(context).accentColor,
//           onTabChangedListener: (index){
//             _controller.jumpToPage(index);
//             setState(() {
//               _currentIndex = index;
//             });
//           },


//           tabs: [
//             // TabData(iconData: Icons.home, title: "Home"),
//             TabData(iconData: FontAwesomeIcons.home, title: "Home"),
//             TabData(iconData: Icons.chat_bubble, title:"Chat"),
//             TabData(iconData: Icons.perm_contact_calendar, title:"Contacts"),
//             TabData(iconData: Icons.person, title: "User" ),
            
//           ],
//         ),
//       ),
//     );
//   }

//   Future<bool> _onWillPop() {
//     return showDialog(
//           context: context,
//           builder: (context) => new AlertDialog(
//                 title: new Text('Notification'),
//                 content: new Text('Are You sure you wanna out this cute app?'),
//                 actions: <Widget>[
//                   new FlatButton(
//                     onPressed: () => Navigator.of(context).pop(false),
//                     child: new Text('Fine, I will take a look more'),
//                   ),
//                   new FlatButton(
//                     onPressed: () => Navigator.of(context).pop(true),
//                     child: new Text('Yes, I wanna out'),
//                   ),
//                 ],
//               ),
//         ) ??
//         false;
//   }
// } 