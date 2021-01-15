import 'package:flutter/material.dart';
import 'package:moonblink/ui/pages/main/contacts/contacts_page.dart';
import 'package:moonblink/ui/pages/main/newfeed/new_feed_page.dart';

class MainPage extends StatefulWidget {
  final nfcontroller;
  MainPage({this.nfcontroller});
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  PageController pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: pageController,
      children: [
        NewFeedPage(
          scrollController: widget.nfcontroller,
        ),
        ContactsPage(),
      ],
    );
  }
}
