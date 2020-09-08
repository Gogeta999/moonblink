// import 'dart:async';

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:moonblink/base_widget/profile_widgets.dart';
// import 'package:moonblink/bloc_pattern/blocked_users/blocked_users_lists/bloc.dart';
// import 'package:moonblink/bloc_pattern/blocked_users/unblock_button/bloc.dart';
// import 'package:moonblink/generated/l10n.dart';
// import 'package:moonblink/models/blocked_user.dart';
// import 'package:oktoast/oktoast.dart';
// import 'package:provider/provider.dart';
// import 'package:timeago/timeago.dart' as timeAgo;

// class BlockedUserPage extends StatefulWidget {
//   @override
//   _BlockedUserPageState createState() => _BlockedUserPageState();
// }

// class _BlockedUserPageState extends State<BlockedUserPage> {
//   final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
//   final _scrollController = ScrollController();
//   final _scrollThreshold = 600.0;
//   Completer<void> _refreshCompleter;
//   var _blockedUsersBloc;

//   @override
//   void initState() {
//     _blockedUsersBloc = BlockedUsersBloc(_listKey, _buildRemovedItem);
//     _scrollController.addListener(_onScroll);
//     _refreshCompleter = Completer<void>();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }

//   Widget _buildItem(BuildContext context, int index,
//       Animation<double> animation, BlockedUser data) {
//     return SlideTransition(
//         position: CurvedAnimation(
//           curve: Curves.easeOut,
//           parent: animation,
//         ).drive(Tween<Offset>(
//           begin: Offset(1, 0),
//           end: Offset(0, 0),
//         )),
//         child: BlockedUserListTile(
//           data: data,
//           index: index,
//           isUnblocking: false,
//         ));
//   }

//   Widget _buildRemovedItem(BuildContext context, int index,
//       Animation<double> animation, BlockedUser data) {
//     return SizeTransition(
//       axis: Axis.vertical,
//       sizeFactor: animation,
//       child: BlockedUserListTile(
//         data: data,
//         index: index,
//         isUnblocking: true,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(G.of(context).block),
//       ),
//       body: BlocProvider<BlockedUsersBloc>(
//         create: (_) => _blockedUsersBloc..add(BlockedUsersFetched()),
//         child: RefreshIndicator(
//           onRefresh: _onRefresh,
//           child: BlocConsumer<BlockedUsersBloc, BlockedUsersState>(
//             listener: (context, state) {
//               if (state is BlockedUsersSuccess) {
//                 _refreshCompleter.complete();
//                 _refreshCompleter = Completer();
//               }
//               if (state is BlockedUsersFailure) {
//                 _refreshCompleter.completeError(state.error);
//                 _refreshCompleter = Completer();
//               }
//             },
//             builder: (context, state) {
//               if (state is BlockedUsersInitial) {
//                 return Center(
//                   child: CupertinoActivityIndicator(),
//                 );
//               }
//               if (state is BlockedUsersFailure) {
//                 return Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: <Widget>[
//                       Text('Error: ${state.error}.'),
//                       RaisedButton(
//                         onPressed: _onRefresh,
//                         child: Text('Retry'),
//                       )
//                     ],
//                   ),
//                 );
//               }
//               if (state is BlockedUsersNoData) {
//                 return Center(
//                   child: Text('No Data.'),
//                 );
//               }
//               if (state is BlockedUsersSuccess) {
//                 /*if (state.data.isEmpty) {
//                   return Center(
//                     child: Text('Empty.'),
//                   );
//                 }*/
//                 return AnimatedList(
//                   key: _listKey,
//                   controller: _scrollController,
//                   physics: ClampingScrollPhysics(),
//                   itemBuilder: (BuildContext context, int index, animation) {
//                     return Column(
//                       children: <Widget>[
//                         _buildItem(
//                             context, index, animation, state.data[index]),
//                         Divider(),
//                         if (state.hasReachedMax == false &&
//                             index >= state.data.length - 1)
//                           Center(child: CupertinoActivityIndicator())
//                       ],
//                     );
//                     return index >= state.data.length
//                         ? BottomLoader()
//                         : Column(
//                             children: <Widget>[
//                               _buildItem(
//                                   context, index, animation, state.data[index]),
//                               Divider(),
//                             ],
//                           );
//                   },
//                 );
//                 return ListView.builder(
//                   physics: ClampingScrollPhysics(),
//                   itemBuilder: (BuildContext context, int index) {
//                     return index >= state.data.length
//                         ? BottomLoader()
//                         : Column(
//                             children: <Widget>[
//                               BlockedUserListTile(
//                                   data: state.data[index], index: index),
//                               Divider(),
//                             ],
//                           );
//                   },
//                   itemCount: state.hasReachedMax
//                       ? state.data.length
//                       : state.data.length + 1,
//                   controller: _scrollController,
//                 );
//               }
//               return Text('Oops!. Something went wrong.');
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   void _onScroll() {
//     final maxScroll = _scrollController.position.maxScrollExtent;
//     final currentScroll = _scrollController.position.pixels;
//     if (maxScroll - currentScroll <= _scrollThreshold) {
//       _blockedUsersBloc.add(BlockedUsersFetched());
//     }
//   }

//   Future<void> _onRefresh() {
//     _blockedUsersBloc.add(BlockedUsersRefreshed());
//     return _refreshCompleter.future;
//   }
// }

// class BlockedUserListTile extends StatelessWidget {
//   final BlockedUser data;
//   final int index;
//   final bool isUnblocking;

//   const BlockedUserListTile({Key key, this.data, this.index, this.isUnblocking})
//       : assert(isUnblocking != null &&
//             data != null &&
//             index != null &&
//             index >= 0),
//         super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => UnblockButtonBloc(),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8.0),
//         child: ListTile(
//           leading: CachedNetworkImage(
//             imageUrl: data.profileImage,
//             imageBuilder: (context, imageProvider) => Container(
//               width: 52.0,
//               height: 52.0,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
//               ),
//             ),
//             placeholder: (context, url) => CircularProgressIndicator(),
//             errorWidget: (context, url, error) => Icon(Icons.error),
//           ),
//           title: Text(data.name),
//           subtitle: Text('Blocked ' +
//               timeAgo.format(DateTime.parse(data.createdAt),
//                   allowFromNow: true)),
//           trailing: isUnblocking
//               ? CupertinoButton(onPressed: () {}, child: Text('Unblocking'))
//               : BlocConsumer<UnblockButtonBloc, UnblockButtonState>(
//                   listener: (context, buttonState) {
//                   if (buttonState is Failed) {
//                     showToast('Sorry, ${buttonState.error}');
//                   }
//                 }, builder: (context, buttonState) {
//                   if (buttonState is Initial) {
//                     return UnblockButton(blockUserId: data.blockUserId);
//                   }
//                   if (buttonState is Loading) {
//                     return CupertinoActivityIndicator();
//                   }
//                   if (buttonState is Failed) {
//                     return UnblockButton(blockUserId: data.blockUserId);
//                   }
//                   if (buttonState is Success) {
//                     context.watch<UnblockButtonBloc>().add(Reset());
//                     context
//                         .watch<BlockedUsersBloc>()
//                         .add(BlockedUsersRemoved(index: index));
//                     return CupertinoActivityIndicator();
//                   }
//                   return Text('Something went wrong!');
//                 }),
//         ),
//       ),
//     );
//   }
// }

// class UnblockButton extends StatelessWidget {
//   final int blockUserId;

//   const UnblockButton({Key key, this.blockUserId}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider.value(
//       value: Provider.of<UnblockButtonBloc>(context),
//       child: BlocBuilder<UnblockButtonBloc, UnblockButtonState>(
//           builder: (context, state) {
//         return CupertinoButton(
//           onPressed: () => context
//               .read<UnblockButtonBloc>()
//               .add(Remove(blockUserId: blockUserId)),
//           child: Text('Unblock'),
//         );
//       }),
//     );
//   }
// }
