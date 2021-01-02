import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moonblink/base_widget/customnavigationbar/custom_navigation_bar.dart';
import 'package:moonblink/base_widget/customnavigationbar/src/convex_appBar/convex_bottom_bar.dart';
import 'package:moonblink/bloc_pattern/chat_list/chat_list_bloc.dart';
import 'package:moonblink/bloc_pattern/user_notification/new/user_new_notification_bloc.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/services/web_socket_service.dart';
import 'package:moonblink/ui/helper/icons.dart';
import 'package:moonblink/ui/pages/main/chat/chat_list_page.dart';
import 'package:moonblink/ui/pages/main/contacts/contacts_page.dart';
import 'package:moonblink/ui/pages/main/home/home_page.dart';
import 'package:moonblink/ui/pages/main/newfeed/create_post_page.dart';
import 'package:moonblink/ui/pages/main/newfeed/new_feed_page.dart';
import 'package:moonblink/ui/pages/main/notifications/user_new_notification_page.dart';
import 'package:moonblink/ui/pages/main/user_status/user_status_page.dart';
import 'package:moonblink/view_model/login_model.dart';

class MainTabPage extends StatefulWidget {
  final int initPage;
  MainTabPage({Key key, this.initPage}) : super(key: key);

  @override
  _MainTabPageState createState() => _MainTabPageState();
}

class _MainTabPageState extends State<MainTabPage>
    with SingleTickerProviderStateMixin {
  PageController _pageController;
  String usertoken = StorageManager.sharedPreferences.getString(token);
  int initPage;
  // // ignore: unused_field
  int _selectedIndex = 0;
  DateTime _lastPressed;
  ScrollController homeController = ScrollController();
  final nfController = ScrollController();

  // _MainTabPageState();

  @override
  void initState() {
    setState(() {
      initPage = widget.initPage;
    });
    WebSocketService().init(BlocProvider.of<ChatListBloc>(context));
    if (usertoken != null)
      BlocProvider.of<UserNewNotificationBloc>(context)
          .add(UserNewNotificationFetched());
    setState(() {
      _pageController = PageController(initialPage: initPage);
      _selectedIndex = initPage;
    });
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    homeController.dispose();
    nfController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    switch (index) {
      case 0:
        setState(() {
          _selectedIndex = 0;
          // _pageController.jumpToPage(0);
        });
        break;
      case 1:
        setState(() {
          _selectedIndex = 1;
          // _pageController.jumpToPage(1);
        });
        break;
      case 2:
        setState(() {
          _selectedIndex = _selectedIndex;
        });
        // setState(() {
        //   _selectedIndex = 2;
        //   _pageController.jumpToPage(2);
        // });
        Navigator.pushNamed(context, RouteName.createPostPage);
        break;
      case 3:
        setState(() {
          _selectedIndex = 3;
          // _pageController.jumpToPage(3);
        });
        break;
      case 4:
        setState(() {
          _selectedIndex = 4;
          // _pageController.jumpToPage(4);
        });
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = <Widget>[
      NewFeedPage(scrollController: nfController),
      HomePage(homeController),
      CreatePostPage(),
      NewChatListPage(), //ChatListPage(),
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
          itemBuilder: (ctx, index) {
            return pages[_selectedIndex];
          },
          itemCount: pages.length,
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          onPageChanged: _onPageChanged,
        ),
      ),
      // bottomNavigationBar: SnakeNavigationBar.color(
      //   behaviour: snakeBarStyle,
      //   snakeShape: snakeShape,
      //   shape: null,
      //   padding: EdgeInsets.zero,

      //   ///configuration for SnakeNavigationBar.color
      //   snakeViewColor: selectedColor,
      //   selectedItemColor:
      //       snakeShape == SnakeShape.indicator ? selectedColor : null,
      //   unselectedItemColor: Colors.blueGrey,

      //   ///configuration for SnakeNavigationBar.gradient
      //   //snakeViewGradient: selectedGradient,
      //   //selectedItemGradient: snakeShape == SnakeShape.indicator ? selectedGradient : null,
      //   //unselectedItemGradient: unselectedGradient,

      //   showUnselectedLabels: showUnselectedLabels,
      //   showSelectedLabels: showSelectedLabels,

      //   currentIndex: _selectedIndex,
      //   onTap: _onPageChanged,
      //   items: [
      //     BottomNavigationBarItem(
      //         icon: InkWell(
      //           child: Icon(FontAwesomeIcons.home),
      //           onDoubleTap: () {
      //             nfController.animateTo(0.0,
      //                 duration: const Duration(milliseconds: 300),
      //                 curve: Curves.easeOut);
      //           },
      //         ),
      //         label: 'home'),
      //     BottomNavigationBarItem(
      //         icon: Icon(FontAwesomeIcons.heart), label: 'heart'),
      //     BottomNavigationBarItem(
      //         icon: Icon(FontAwesomeIcons.plus), label: 'plus'),
      //     BottomNavigationBarItem(
      //         icon: Icon(FontAwesomeIcons.comment), label: 'comment'),
      //     BottomNavigationBarItem(
      //         icon: Icon(FontAwesomeIcons.comment), label: 'user')
      //   ],
      // ),
      bottomNavigationBar: ConvexAppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        style: TabStyle.fixedCircle,
        // color: Theme.of(context).brightness == Brightness.dark
        //     ? Colors.black
        //     : Colors.grey,
        items: [
          TabItem(
            icon: Image.asset('images/mainTab/home.png'),
            activeIcon: Image.asset(
              'images/mainTab/home1.png',
              color: Colors.black,
            ),
          ),
          TabItem(
            icon: Image.asset('images/mainTab/following.png'),
            activeIcon: Image.asset('images/mainTab/following1.png',
                color: Colors.black),
          ),
          TabItem(
            icon: Icon(FontAwesomeIcons.plus),
            // activeIcon: Icon(Icons.add)
          ),
          TabItem(
            icon: Image.asset('images/mainTab/chat.png'),
            activeIcon:
                Image.asset('images/mainTab/chat1.png', color: Colors.black),
          ),
          TabItem(
            icon: Image.asset('images/mainTab/mainProfile.png'),
            activeIcon: Image.asset('images/mainTab/mainProfile1.png',
                color: Colors.black),
          ),
        ],
        initialActiveIndex: 1 /*optional*/,
        onTap: _onPageChanged,
      ),
    );
  }
}
