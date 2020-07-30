import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/resources_manager.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/services/chat_service.dart';
import 'package:moonblink/ui/pages/main/chat/chatlist_page.dart';
import 'package:moonblink/ui/pages/main/contacts/contacts_page.dart';
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

  @override
  void initState() {
    print(usertoken);
    //PushNotificationsManager().init();
    if (usertoken != null) {
      ScopedModel.of<ChatModel>(context, rebuildOnChange: false).init();
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
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
      bottomNavigationBar: Container(
        child: FancyBottomNavigation(
          tabs: [
            TabData(
                iconData: IconFonts.homePageIcon, title: S.of(context).tabHome),
            TabData(
                iconData: IconFonts.chatPageIcon, title: S.of(context).tabChat),
            TabData(
                iconData: IconFonts.followingPageIcon,
                title: S.of(context).tabFollowing),
            TabData(
                iconData: IconFonts.statusPageIcon, title: S.of(context).tabUser),
          ],
          initialSelection: initPage,
          // inactiveIconSize: 30,
          circleHeight: 50,
          arcHeight: 55,
          arcWidth: 80,
          barHeight: 55,
          circleColor: Theme.of(context).accentColor,
          onTabChangedListener: (index) {
            _pageController.jumpToPage(index);
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}
