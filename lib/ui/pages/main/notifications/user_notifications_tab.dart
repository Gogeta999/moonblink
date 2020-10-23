import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/appbar/appbar.dart';
import 'package:moonblink/ui/pages/main/notifications/user_new_notification_page.dart';

class UserNotificationTab extends StatefulWidget {
  @override
  _UserNotificationTabState createState() => _UserNotificationTabState();
}

class _UserNotificationTabState extends State<UserNotificationTab> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppbarWidget(),
        body: SafeArea(
          child: UserNewNotificationPage(),
        ));
  }
}