import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moonblink/base_widget/chat/floatingbutton.dart';
import 'package:moonblink/base_widget/custom_bottom_sheet.dart';
import 'package:moonblink/bloc_pattern/chat_box_bloc.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/chat_models/booking_status.dart';
import 'package:moonblink/models/chat_models/last_message.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/services/web_socket_service.dart';
import 'package:moonblink/ui/helper/icons.dart';
import 'package:moonblink/utils/constants.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:oktoast/oktoast.dart';
import 'package:photo_manager/photo_manager.dart';

class NewChatBoxPage extends StatefulWidget {
  final int partnerId;
  NewChatBoxPage(this.partnerId);
  @override
  _NewChatBoxPageState createState() => _NewChatBoxPageState();
}

class _NewChatBoxPageState extends State<NewChatBoxPage>
    with SingleTickerProviderStateMixin {

  ///Private Properties - Start
  ChatBoxBloc _chatBoxBloc;
  final int myId = StorageManager.sharedPreferences.getInt(mUserId);

  final _scrollThreshold = 600.0;
  final ScrollController _scrollController = ScrollController();

  AnimationController _animationController;
  Animation<double> _animation;
  Animation<double> _animation2;
  Animation<double> _animation3;

  bool _isRotated = false;
  ///Private Properties - End

  ///Lifecycle - Start
  @override
  void initState() {
    _chatBoxBloc = ChatBoxBloc(widget.partnerId);
    _chatBoxBloc.add(ChatBoxFetched());
    WebSocketService().initWithChatBoxBloc(_chatBoxBloc);

    _scrollController.addListener(_onScroll);

    ///[Animation]
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.0, 1.0, curve: Curves.linear),
    );

    _animation2 = CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.5, 1.0, curve: Curves.linear),
    );

    _animation3 = new CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.8, 1.0, curve: Curves.linear),
    );
    _animationController.reverse();

    ///[Chat Data]
    StorageManager.sharedPreferences.setBool(isUserAtChatBox, true);
    print(
        'isUserAtChatBox --- ${StorageManager.sharedPreferences.get(isUserAtChatBox)}');

    super.initState();
  }

  @override
  void dispose() {
    StorageManager.sharedPreferences.setBool(isUserAtChatBox, false);
    print(
        'isUserAtChatBox --- ${StorageManager.sharedPreferences.get(isUserAtChatBox)}');
    WebSocketService().disposeWithChatBoxBloc();
    super.dispose();
  }
  ///Lifecycle - End

  ///Private UI Widgets - Start
  //build messages
  Widget _buildSingleMessage(LastMessage lastMessage) {
    return Container(
        alignment: _senderIsMe(lastMessage.senderId)
            ? Alignment.centerRight
            : Alignment.centerLeft,
        margin: EdgeInsets.all(10.0),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.5,
          ),
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
              color: _senderIsMe(lastMessage.senderId)
                  ? Theme.of(context).accentColor.withOpacity(0.5)
                  : Colors.black12,
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
              border: Border.all(
                  color: _senderIsMe(lastMessage.senderId)
                      ? Colors.black12
                      : Theme.of(context).accentColor)),
          child: SelectableText(
            lastMessage.message,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            autofocus: true,
            cursorRadius: Radius.circular(50),
            cursorColor: Colors.white,
            toolbarOptions: ToolbarOptions(copy: true, selectAll: true),
          ),
        ));
  }

  //Send message
  /*Widget buildmessage(id, model) {
    if (bookingdata == null) {
      return ViewStateBusyWidget();
    }
    if (bookingdata.isblock == 0) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        height: MediaQuery.of(context).size.height * 0.08,
        //color: Theme.of(context).backgroundColor,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
          // ? Colors.grey
              ? Theme.of(context).accentColor
              : Colors.black,
          // boxShadow: [
          //   BoxShadow(
          //     color: Theme.of(context).brightness == Brightness.dark
          //         ? Colors.white
          //         : Colors.black,
          //     offset: Offset(0.0, 1.0), //(x,y)
          //     spreadRadius: 3,
          //   ),
          // ],
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30.0),
          ),
        ),
        child: Row(
          children: <Widget>[
            IconButton(
              iconSize: 35,
              icon: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey
                          : Colors.black),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Icon(
                  _isRotated ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              onPressed: () => rotate(),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 1,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey
                            : Colors.black),
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                  ),
                  child: TextField(
                    minLines: 1,
                    maxLines: 5,
                    maxLength: 150,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.newline,
                    controller: textEditingController,
                    decoration: InputDecoration(
                      hintText: G.of(context).labelmsg,
                      counterText: "",
                    ),
                  ),
                ),
              ),
            ),
            //Send button
            sendbtn(model, id),
          ],
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        height: MediaQuery.of(context).size.height * 0.1,
        //color: Theme.of(context).backgroundColor,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
          // ? Colors.grey
              ? Theme.of(context).accentColor
              : Colors.black,
          // boxShadow: [
          //   BoxShadow(
          //     color: Theme.of(context).brightness == Brightness.dark
          //         ? Colors.white
          //         : Colors.black,
          //     offset: Offset(0.0, 1.0), //(x,y)
          //     spreadRadius: 3,
          //   ),
          // ],
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
        ),
        child: Center(
          child: Text(
            "This person has blocked you",
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }
  }*/


  Widget _buildPickImageIcon() {
    return IconButton(
      icon: SvgPicture.asset(
        gallery,
        color: Colors.black,
        semanticsLabel: 'gallery',
        width: 30,
        height: 30,
      ),
      iconSize: 30.0,
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : Colors.black,
      onPressed: () {
        _rotate();
      },
    );
  }

  Widget _buildVoiceRecorderIcon() {
    return Container();
  }

  // Booking Cancel
  Widget _buildBookingCancelButton(int bookingId) {
    return StreamBuilder<bool>(
      initialData: false,
      stream: _chatBoxBloc.bookingCancelButtonSubject,
      builder: (context, snapshot) {
        if (snapshot.data) {
          return CupertinoButton(
            child: CupertinoActivityIndicator(),
            onPressed: (){}
          );
        }
        return CupertinoButton(
          child: Text(
            G.of(context).cancel,
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () => _chatBoxBloc.add(ChatBoxCancelBooking(bookingId)),
        );
      },
    );
  }

  Widget _buildFirstAction() {
    return StreamBuilder<BookingStatus>(
      initialData: null,
      builder: (context, snapshot) {
        if (snapshot.data.status == PENDING && _bookingUserIsMe(snapshot.data.booingUserId)) {
          return _buildBookingCancelButton(snapshot.data.bookingId);
        }
        return CupertinoActivityIndicator();
      },
    );
    // if (bookingdata == null) {
    //   return ViewStateBusyWidget();
    // }
    // switch (bookingdata.status) {
    // //normal
    //   case (-1):
    //     return Container();
    //     break;
    // //cancel booking
    //   case (0):
    //     return bookingcancel(
    //       bookingdata.bookingid,
    //       bookingdata.bookinguserid,
    //     );
    //     break;
    // //in booking
    //   case (1):
    //     return callbtn(widget.detailPageId);
    //     break;
    // //reject
    //   case (2):
    //     return Container();
    //     break;
    // //done
    //   case (3):
    //     return Container();
    //     break;
    // //expired
    //   case (4):
    //     return Container();
    //     break;
    // //unavailable
    //   case (5):
    //     return Container();
    //     break;
    // //cancel
    //   case (6):
    //     return Container();
    //     break;
    // //default
    //   default:
    //     return Container();
    // }
  }
  ///Private UI Widgets - End

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _chatBoxBloc,
      child: BlocConsumer<ChatBoxBloc, ChatBoxState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state is ChatBoxInitial) {
            return Scaffold(body: Center(child: CupertinoActivityIndicator()));
          }
          if (state is ChatBoxFailure) {
            return Scaffold(body: Center(child: Text(state.error.toString())));
          }
          if (state is ChatBoxSuccess) {
            return Scaffold(
                appBar: AppBar(
                  leading: IconButton(
                      icon: SvgPicture.asset(
                        back,
                        semanticsLabel: 'back',
                        color: Colors.white,
                        width: 30,
                        height: 30,
                      ),
                      onPressed: () => Navigator.pop(context)),
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                          // ? Colors.grey
                          ? Colors.black
                          : Colors.black,
                  title: GestureDetector(
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(state
                                .partnerUser.prfoileFromPartner.profileImage),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Container(
                              width: MediaQuery.of(context).size.width / 3,
                              child: Text(
                                state.partnerUser.partnerName,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                      onTap: state.partnerUser.type != 0
                          ? () {
                              Navigator.pushReplacementNamed(
                                      context, RouteName.partnerDetail,
                                      arguments: widget.partnerId)
                                  .then((value) async {
                                if (value != null) {
                                  ///Block Uesrs
                                  try {
                                    await MoonBlinkRepository.blockOrUnblock(
                                        value, BLOCK);
                                    showToast(G.of(context).toastsuccess);
                                  } catch (e) {
                                    print(e.toString());
                                  }
                                }
                              });
                            }
                          : null),
                   actions: <Widget>[
                  //   action2(model),
                     _buildFirstAction(),
                   ],
                ),
                body: SafeArea(
                  child: Stack(
                    children: [
                      ListView.builder(
                        physics: AlwaysScrollableScrollPhysics(),
                        controller: _scrollController,
                        reverse: true,
                        itemBuilder: (context, index) {
                          if (index >= state.data.length)
                            return Center(child: CupertinoActivityIndicator());
                          return _buildSingleMessage(state.data[index]);
                        },
                        itemCount: state.hasReachedMax
                            ? state.data.length
                            : state.data.length + 1,
                      ),
                      FloatingButton(
                        bottom: 80,
                        left: 10,
                        scale: _animation,
                        child: _buildPickImageIcon(),
                      ),
                      FloatingButton(
                        bottom: 140,
                        left: 30,
                        scale: _animation2,
                        child: _buildVoiceRecorderIcon(),
                      ),
                      FloatingButton(
                        bottom: 200,
                        left: 10,
                        scale: _animation3,
                        child: IconButton(
                          icon: SvgPicture.asset(
                            camera,
                            color: Colors.black,
                            semanticsLabel: 'camera',
                            width: 30,
                            height: 30,
                          ),
                          onPressed: () => print('Camera')
                        ),
                      )
                    ],
                  ),
                ));
          }
          return Text('Something went wrong!');
        },
      ),
    );
  }

  ///Private Methods - Start
  void _rotate() { //Animate Icon
    setState(() {
      if (_isRotated) {
        _isRotated = false;
        _animationController.forward();
      } else {
        _isRotated = true;
        _animationController.reverse();
      }
    });
  }

  bool _senderIsMe(int senderId) => myId == senderId;
  bool _bookingUserIsMe(int booingUserId) => myId == booingUserId;

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      _chatBoxBloc.add(ChatBoxFetched());
    }
  }
  ///Private Methods - End
}
