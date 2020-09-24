import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moonblink/base_widget/appbar/appbarlogo.dart';
import 'package:moonblink/bloc_pattern/user_notification/user_notification_bloc.dart';

class BookingRequestDetailPage extends StatefulWidget {
  final int index;

  const BookingRequestDetailPage({Key key, this.index}) : super(key: key);

  @override
  _BookingRequestDetailPageState createState() => _BookingRequestDetailPageState();
}

class _BookingRequestDetailPageState extends State<BookingRequestDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [AppbarLogo()],
        ),
      body: BlocConsumer<UserNotificationBloc, UserNotificationState>(
        listener: (context, state) {

        },
        builder: (context, state) {
          if (state is UserNotificationSuccess) {
            return ListView(
              physics: ClampingScrollPhysics(),
              children: [

              ],
            );
          }
          return Center(child: Text('Oops! Something went wrong!'));
        },
      ),
    );
  }
}
