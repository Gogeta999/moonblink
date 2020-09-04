import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/resources_manager.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/services/chat_service.dart';
import 'package:moonblink/ui/pages/main/chat/chatlist_page.dart';
import 'package:moonblink/ui/pages/main/chat/newchatlist.dart';
import 'package:moonblink/ui/pages/main/contacts/contacts_page.dart';
import 'package:moonblink/ui/pages/main/contacts/newcontactspage.dart';
import 'package:moonblink/ui/pages/main/home/home_page.dart';
import 'package:moonblink/ui/pages/main/user_status/user_status_page.dart';

import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:scoped_model/scoped_model.dart';

List<Widget> pages = <Widget>[
  HomePage(),
  ChatListPage(),
  ContactsPage(),
  UserStatusPage(),
];

class MainTabPage extends StatefulWidget {
  final int initPage;
  MainTabPage({Key key, this.initPage}) : super(key: key);

  @override
  _MainTabPageState createState() => _MainTabPageState(initPage);
}

class _MainTabPageState extends State<MainTabPage>
    with SingleTickerProviderStateMixin {
  var _pageController;
  String usertoken = StorageManager.sharedPreferences.getString(token);
  // ignore: unused_field
  final int initPage;
  // ignore: unused_field
  int _selectedIndex = 0;
  DateTime _lastPressed;

  _MainTabPageState(this.initPage);
  // @override
  // void dipose() {
  //   dipose();
  // }

  @override
  void initState() {
    print(usertoken);
    //PushNotificationsManager().init();
    if (usertoken != null) {
      ScopedModel.of<ChatModel>(context, rebuildOnChange: false).init();
      ScopedModel.of<ChatModel>(context).conversationlist();
    }
    setState(() {
      _pageController = PageController(initialPage: initPage);
      _selectedIndex = initPage;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          if (_lastPressed == null ||
              DateTime.now().difference(_lastPressed) > Duration(seconds: 1)) {
            // if time is separate more than 1 second, then continue to count
            _lastPressed = DateTime.now();
            // showToast("You Really want to out?");
            return false;
          }
          return true;
        },
        child: PageView.builder(
          // this ctx is also context, but avoid to affect from PageState's context
          itemBuilder: (ctx, index) {
            // pages[index];
            return GestureDetector(
              //Horizontal Swipe
              onHorizontalDragEnd: (details) {
                //Swipe right
                if (details.primaryVelocity < 0) {
                  print("Swiping right");
                  if (index >= 0) {
                    index++;
                    // setState(() {
                    //   _selectedIndex = index;
                    // });
                    _pageController.animateTo(
                        MediaQuery.of(context).size.width * index,
                        duration: Duration(milliseconds: 200),
                        curve: Curves.ease);

                    // _pageController.jumpToPage(index);
                  }
                }
                //Swipe left
                else if (details.primaryVelocity > 0) {
                  print("Swiping left");
                  if (index < pages.length) {
                    index--;
                    // setState(() {
                    //   _selectedIndex = index;
                    // });
                    _pageController.animateTo(
                        MediaQuery.of(context).size.width * index,
                        duration: Duration(milliseconds: 200),
                        curve: Curves.ease);
                    // _pageController.jumpToPage(index);
                  }
                }
              },
              child: pages[index],
            );
          },
          itemCount: pages.length,
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          onPageChanged: (index) {
            setState(
              () {
                _selectedIndex = index;
                print('index num is: $_selectedIndex');
              },
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        child: FancyBottomNavigation(
          tabs: [
            TabData(
                iconData: IconFonts.homePageIcon, title: G.of(context).tabHome),
            TabData(
                iconData: IconFonts.chatPageIcon, title: G.of(context).tabChat),
            TabData(
                iconData: IconFonts.followingPageIcon,
                title: G.of(context).tabFollowing),
            TabData(
                iconData: IconFonts.statusPageIcon,
                title: G.of(context).tabUser),
          ],
          initialSelection: initPage,
          // inactiveIconSize: 30,
          // circleOutline: 10,
          circleHeight: 50,
          arcHeight: 55,
          arcWidth: 80,
          // activeIconSize: 00,
          shadowAllowance: 18,
          activeIconColor: Colors.white,
          barHeight: 53,
          pageController: _pageController,
          circleColor: Theme.of(context).accentColor,
          onTabChangedListener: (index) {
            _pageController.animateTo(MediaQuery.of(context).size.width * index,
                duration: Duration(milliseconds: 10), curve: Curves.ease);
          },
        ),
      ),
    );
  }
}
