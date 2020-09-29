// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:moonblink/base_widget/appbar/appbarlogo.dart';
// import 'package:moonblink/bloc_pattern/user_notification/user_booking_notification_bloc.dart';
// import 'package:moonblink/generated/l10n.dart';
// import 'package:moonblink/models/user_booking_notification.dart';
// import 'package:moonblink/utils/constants.dart';
// import 'package:rxdart/rxdart.dart';
//
// enum AcceptState {
//   initial,
//   loading
// }
//
// enum RejectState {
//   initial,
//   loading
// }
//
// class BookingRequestDetailPage extends StatefulWidget {
//   final int notificationId;
//   final int index; ///not using for now
//
//   const BookingRequestDetailPage({Key key, this.notificationId, this.index})
//       : super(key: key);
//
//   @override
//   _BookingRequestDetailPageState createState() =>
//       _BookingRequestDetailPageState();
// }
//
// class _BookingRequestDetailPageState extends State<BookingRequestDetailPage> {
//
//   BehaviorSubject<AcceptState> _acceptSubject = BehaviorSubject.seeded(AcceptState.initial);
//   BehaviorSubject<RejectState> _rejectSubject = BehaviorSubject.seeded(RejectState.initial);
//
//   @override
//   void initState() {
//     BlocProvider.of<UserNotificationBloc>(context)
//         .add(UserNotificationChangeToRead(widget.notificationId));
//     super.initState();
//   }
//
//   Widget _buildContainer({Widget child, EdgeInsets margin}) {
//     return Container(
//       margin: margin,
//       decoration: BoxDecoration(
//         color: Theme.of(context).scaffoldBackgroundColor,
//         border: Border.all(color: Colors.black),
//         borderRadius: BorderRadius.circular(10),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black,
//             spreadRadius: 0.5,
//             // blurRadius: 2,
//             offset: Offset(-3, 3), // changes position of shadow
//           ),
//         ],
//       ),
//       child: child,
//     );
//   }
//
//   List<Widget> _buildSuccessState(UserNotificationData notiData) {
//     return [
//       _buildContainer(
//         margin: EdgeInsets.symmetric(vertical: 16, horizontal: 10),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8),
//           child: Text(
//             _getBookingRequestStatus(notiData.fcmData),
//             style: Theme.of(context).textTheme.headline5,
//             textAlign: TextAlign.center,
//             softWrap: true,
//           ),
//         ),
//       ),
//       Expanded(
//         child: _buildContainer(
//             margin: const EdgeInsets.symmetric(horizontal: 10),
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 children: [
//                   Row(
//                     children: [
//                       _buildContainer(
//                           child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text('Requested user\'s name'),
//                       )),
//                       SizedBox(width: 30),
//                       _buildContainer(
//                           child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text('${notiData.fcmData.name}'),
//                       ))
//                     ],
//                   ),
//                   SizedBox(height: 8),
//                   Row(
//                     children: [
//                       _buildContainer(
//                           child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text('Requested game name'),
//                       )),
//                       SizedBox(width: 30),
//                       _buildContainer(
//                           child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text('${notiData.fcmData.gameName}'),
//                       ))
//                     ],
//                   ),
//                   SizedBox(height: 8),
//                   Row(
//                     children: [
//                       _buildContainer(
//                           child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text('Requested game mode'),
//                       )),
//                       SizedBox(width: 30),
//                       _buildContainer(
//                           child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text('${notiData.fcmData.type}'),
//                       ))
//                     ],
//                   )
//                 ],
//               ),
//             )),
//       ),
//       if (notiData.fcmData.status == PENDING)
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             _buildContainer(
//               child: StreamBuilder<RejectState>(
//                 initialData: RejectState.initial,
//                 stream: _rejectSubject,
//                 builder: (context, snapshot) {
//                   if (snapshot.data  == RejectState.initial) {
//                     return CupertinoButton(
//                       onPressed: () {
//                         _rejectSubject.add(RejectState.loading);
//                         BlocProvider.of<UserNotificationBloc>(context).add(
//                             UserNotificationRejected(
//                                 notiData.fcmData.userId, notiData.fcmData.id));
//                       },
//                       child: Text(G.of(context).reject),
//                     );
//                   }
//                   else if (snapshot.data == RejectState.loading) {
//                     return CupertinoActivityIndicator();
//                   }
//                   else return Text('Oops');
//                 }
//               ),
//             ),
//             _buildContainer(
//               child: StreamBuilder<AcceptState>(
//                 initialData: AcceptState.initial,
//                 stream: _acceptSubject,
//                 builder: (context, snapshot) {
//                   if (snapshot.data == AcceptState.initial) {
//                     return CupertinoButton(
//                       onPressed: () {
//                         _acceptSubject.add(AcceptState.loading);
//                         BlocProvider.of<UserNotificationBloc>(context).add(
//                             UserNotificationAccepted(notiData.fcmData.userId,
//                                 notiData.fcmData.id, notiData.fcmData.bookingUserId));
//                       },
//                       child: Text(G.of(context).accept),
//                     );
//                   }
//                   else if (snapshot.data == AcceptState.loading) {
//                     return CupertinoActivityIndicator();
//                   }
//                   else return Text('Oops');
//                 }
//               ),
//             )
//           ],
//         )
//     ];
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         actions: [AppbarLogo()],
//       ),
//       body: SafeArea(
//         child: BlocConsumer<UserNotificationBloc, UserNotificationState>(
//           buildWhen: (previousState, currentState) =>
//             currentState != UserNotificationAcceptStateToInitial() &&
//             currentState != UserNotificationRejectStateToInitial()
//           ,
//           listener: (context, state) {
//             if (state is UserNotificationAcceptStateToInitial) {
//               _acceptSubject.add(AcceptState.initial);
//             }
//             if (state is UserNotificationRejectStateToInitial) {
//               _rejectSubject.add(RejectState.initial);
//             }
//           },
//           builder: (context, state) {
//             if (state is UserNotificationUpdating) {
//               UserNotificationData notiData;
//               state.data.forEach((element) {
//                 if (element.id == widget.notificationId) {
//                   notiData = element;
//                 }
//               });
//               List<Widget> children = _buildSuccessState(notiData);
//               children.insert(
//                   0,
//                   Text(
//                     'Updating...',
//                     textAlign: TextAlign.center,
//                   ));
//               return Column(children: children);
//             }
//             if (state is UserNotificationSuccess) {
//               UserNotificationData notiData;
//               state.data.forEach((element) {
//                 if (element.id == widget.notificationId) {
//                   notiData = element;
//                 }
//               });
//               return Column(children: _buildSuccessState(notiData));
//             }
//             return Center(child: Text('Oops! Something went wrong!'));
//           },
//         ),
//       ),
//     );
//   }
//
//   String _getBookingRequestStatus(UserNotificationFcmData data) {
//     switch (data.status) {
//       case PENDING:
//         return 'Booking Status\nPending';
//       case ACCEPTED:
//         return 'Booking Status\nAccepted';
//       case REJECT:
//         return 'Booking Status\nRejected';
//       case DONE:
//         return 'Booking Status\nDone';
//       case EXPIRED:
//         return 'Booking Status\nExpired';
//       case UNAVAILABLE:
//         return 'Booking Status\nUnavailable';
//       case CANCEL:
//         return 'Booking Status\nCancelled';
//       default:
//         return 'Oops! Something went Wrong!';
//     }
//   }
// }
