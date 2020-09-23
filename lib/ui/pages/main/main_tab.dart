import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/customnavigationbar/custom_navigation_bar.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/services/chat_service.dart';
import 'package:moonblink/ui/pages/main/chat/chatlist_page.dart';
import 'package:moonblink/ui/pages/main/contacts/contacts_page.dart';
import 'package:moonblink/ui/pages/main/home/home_page.dart';
import 'package:moonblink/ui/pages/main/notifications/user_notification_page.dart';
import 'package:moonblink/ui/pages/main/user_status/user_status_page.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_svg/flutter_svg.dart';

final String home = 'assets/icons/home.svg';
final String chat = 'assets/icons/chat.svg';
final String following = 'assets/icons/following.svg';
final String user = 'assets/icons/profileBunny.svg';

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
  ScrollController homeController = ScrollController();

  _MainTabPageState(this.initPage);

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
    List<Widget> pages = <Widget>[
      HomePage(homeController),
      ChatListPage(),
      ContactsPage(),
      UserNotificationPage(),
      UserStatusPage(),
    ];

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
        decoration: BoxDecoration(
          border: Border.all(
              width: 1,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black
                  : Colors.black),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(10.0),
          ),
        ),
        child: CustomNavigationBar(
          borderRadius: Radius.circular(10),
          // iconSize: 30.0,
          selectedColor: Theme.of(context).accentColor,
          strokeColor: Theme.of(context).accentColor,
          unSelectedColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          items: [
            CustomNavigationBarItem(
              icon: home,
              doubletap: () {
                homeController.animateTo(
                  0.0,
                  curve: Curves.easeOut,
                  duration: const Duration(milliseconds: 300),
                );
              },
            ),
            CustomNavigationBarItem(
              icon: chat,
            ),
            CustomNavigationBarItem(
              icon: following,
            ),
            CustomNavigationBarItem(
              icon: following, ///TODO - Change to notification icon later
            ),
            CustomNavigationBarItem(
              icon: user,
            )
          ],
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
              _pageController.jumpToPage(_selectedIndex);
            });
          },
        ),
      ),
    );
  }
}
