import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/appbar/appbar.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/ui/pages/main/notifications/user_new_notification_page.dart';
import 'package:rxdart/rxdart.dart';

enum SelectedName { message, booking }

class UserNotificationTab extends StatefulWidget {
  @override
  _UserNotificationTabState createState() => _UserNotificationTabState();
}

class _UserNotificationTabState extends State<UserNotificationTab>
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => false;

  SizedBox blankSpace() => SizedBox(height: 10);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        appBar: AppbarWidget(),
        body: SafeArea(
          child: Column(
            children: [
              Card(
                margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
                child: ListTile(
                  onTap: () => Navigator.pushNamed(context, RouteName.userMessageHistory),
                  title: Text('Message History'),
                ),
              ),
              Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  onTap: () => Navigator.pushNamed(context, RouteName.userBookingHistory),
                  title: Text('Booking History'),
                ),
              ),
              Expanded(
                child: UserNewNotificationPage()
              )
            ],
          ),
        )
    );
  }
}


/*
import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/appbar/appbar.dart';
import 'package:moonblink/ui/pages/main/notifications/user_booking_notification_page.dart';
import 'package:moonblink/ui/pages/main/notifications/user_message_notification_page.dart';
import 'package:rxdart/rxdart.dart';

enum SelectedName { message, booking }

class UserNotificationTab extends StatefulWidget {
  @override
  _UserNotificationTabState createState() => _UserNotificationTabState();
}

class _UserNotificationTabState extends State<UserNotificationTab>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {

  BehaviorSubject<SelectedName> _selectedNameSubject;
  TabController _tabController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _tabController = TabController(initialIndex: 0, length: 2, vsync: this);
    _selectedNameSubject = BehaviorSubject.seeded(SelectedName.message);
    super.initState();
  }

  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        appBar: AppbarWidget(),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: StreamBuilder<SelectedName>(
                stream: _selectedNameSubject,
                builder: (context, snapshot) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ///Message
                      InkResponse(
                        onTap: () {
                          _selectedNameSubject.add(SelectedName.message);
                          _selectedNameSubject.first.then((value) =>
                          {_tabController.animateTo(value.index)});
                        },
                        child: Ink(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: snapshot.data == SelectedName.message
                                    ? Theme.of(context).accentColor
                                    : Colors.black,
                                spreadRadius: 1,
                                // blurRadius: 2,
                                offset: Offset(
                                    -2, 2), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Text('Message', style: Theme.of(context).textTheme.button),
                        ),
                      ),
                      InkResponse(
                        onTap: () {
                          _selectedNameSubject.add(SelectedName.booking);
                          _selectedNameSubject.first.then((value) =>
                          {_tabController.animateTo(value.index)});
                        },
                        child: Ink(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: snapshot.data == SelectedName.booking
                                    ? Theme.of(context).accentColor
                                    : Colors.black,
                                spreadRadius: 1,
                                // blurRadius: 2,
                                offset: Offset(
                                    -2, 2), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Text('Booking', style: Theme.of(context).textTheme.button),
                        ),
                      )
                    ],
                  );
                }
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.71,
                child: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  controller: _tabController,
                  children: [
                    UserMessageNotificationPage(),
                    UserBookingNotificationPage()
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}


 */