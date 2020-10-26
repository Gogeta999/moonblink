import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
import 'package:moonblink/ui/pages/call/voice_call_page.dart';
import 'package:moonblink/utils/constants.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:oktoast/oktoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:rxdart/rxdart.dart';

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

  final TextEditingController _messageController = TextEditingController();
  final _rotatedSubject = BehaviorSubject.seeded(true);

  AnimationController _animationController;
  Animation<double> _animation;
  Animation<double> _animation2;
  Animation<double> _animation3;

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

  Widget _buildActionBottomBar() {
    return StreamBuilder<BookingStatus>(
      initialData: null,
      stream: _chatBoxBloc.bookingStatusSubject,
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return CupertinoActivityIndicator();
        }

        ///Blocked
        if (snapshot.data.isBlock == 1) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            height: MediaQuery.of(context).size.height * 0.1,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  // ? Colors.grey
                  ? Theme.of(context).accentColor
                  : Colors.black,
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
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          height: MediaQuery.of(context).size.height * 0.08,
          //color: Theme.of(context).backgroundColor,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).accentColor
                : Colors.black,
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
                  child: StreamBuilder<bool>(
                      initialData: true,
                      stream: _rotatedSubject,
                      builder: (context, snapshot) {
                        return Icon(
                          snapshot.data
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        );
                      }),
                ),
                onPressed: () => _rotate(),
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
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: G.of(context).labelmsg,
                        counterText: "",
                      ),
                    ),
                  ),
                ),
              ),
              _buildSendButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSendButton() {
    return IconButton(
      icon: SvgPicture.asset(
        send,
        color: Colors.white,
        semanticsLabel: 'send',
        width: 30,
        height: 30,
      ),
      iconSize: 30.0,
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.white,
      onPressed: () {},
    );
  }

  Widget _buildPickImageIcon() {
    return Container(
      margin: const EdgeInsets.all(4),
      child: InkResponse(
        child: SvgPicture.asset(
          gallery,
          color: Colors.black,
          semanticsLabel: 'gallery',
        ),
        onTap: () {
          _rotate();
          // CustomBottomSheet.show(
          //     popAfterBtnPressed: true,
          //     requestType: RequestType.image,
          //     buttonText: G.of(context).sendbutton,
          //     buildContext: context,
          //     limit: 1,
          //     body: G.of(context).labelimageselect,
          //     onPressed: (File file) async {
          //       setState(() {
          //         _file = file;
          //       });
          //
          //       await getImage();
          //       String now = DateTime.now().toString();
          //       String filename = selfId.toString() + now + ".png";
          //       model.sendfile(filename, bytes, id, 1, messages);
          //       setState(() {
          //         textEditingController.text = '';
          //         bytes = null;
          //       });
          //     },
          //     onInit: _sendMessageWidgetUp,
          //     onDismiss: _sendMessageWidgetDown,
          //     willCrop: false,
          //     compressQuality: NORMAL_COMPRESS_QUALITY);
        },
      ),
    );
  }

  Widget _buildVoiceRecorderIcon() {
    return Container(
      margin: const EdgeInsets.all(4),
    );
  }

  // Booking Cancel
  Widget _buildBookingCancelButton(int bookingId) {
    return StreamBuilder<bool>(
      initialData: false,
      stream: _chatBoxBloc.bookingCancelButtonSubject,
      builder: (context, snapshot) {
        if (snapshot.data) {
          return CupertinoButton(
              child: CupertinoActivityIndicator(), onPressed: () {});
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

  Widget _buildPhoneButton(int receiverId) {
    String voiceChannelName = 'UserId($myId)CallToUserId($receiverId)';
    return IconButton(
        icon: Icon(
          FontAwesomeIcons.phone,
          size: 20,
          color: Colors.white,
        ),
        onPressed: () {
          _chatBoxBloc.add(ChatBoxCall(voiceChannelName, receiverId));
        });
  }

  Widget _buildFirstAction() {
    return StreamBuilder<BookingStatus>(
      initialData: null,
      stream: _chatBoxBloc.bookingStatusSubject,
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return CupertinoActivityIndicator();
        }
        if (snapshot.data.status == PENDING &&
            _bookingUserIsMe(snapshot.data.booingUserId)) {
          return _buildBookingCancelButton(snapshot.data.bookingId);
        }
        if (snapshot.data.status == ACCEPTED &&
            _bookingUserIsMe(snapshot.data.booingUserId)) {
          return _buildPhoneButton(snapshot.data.userId);
        }
        return Container();
      },
    );
  }

  ///Private UI Widgets - End

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _chatBoxBloc,
      child: BlocConsumer<ChatBoxBloc, ChatBoxState>(
        listener: (context, state) {
          if (state is ChatBoxCancelBookingFailure) {
            showToast(state.error.toString());
          }
          if (state is ChatBoxCallFailure) {
            showToast(state.error.toString());
          }
          if (state is ChatBoxCallSuccess) {
            _handleVoiceCall(state.channel);
          }
        },
        buildWhen: (previous, current) {
          return !(current is ChatBoxCancelBookingSuccess) &&
              !(current is ChatBoxCancelBookingFailure) &&
              !(current is ChatBoxCallSuccess) &&
              !(current is ChatBoxCallFailure);
        },
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
                  child: StreamBuilder<bool>(
                      initialData: true,
                      stream: _rotatedSubject,
                      builder: (context, snapshot) {
                        if (!snapshot.data) {
                          return Stack(
                            children: [
                              Column(
                                children: [
                                  ///Chat messages list
                                  Expanded(
                                    child: ListView.builder(
                                      physics: AlwaysScrollableScrollPhysics(),
                                      controller: _scrollController,
                                      reverse: true,
                                      itemBuilder: (context, index) {
                                        if (index >= state.data.length)
                                          return Center(
                                              child:
                                                  CupertinoActivityIndicator());
                                        return _buildSingleMessage(
                                            state.data[index]);
                                      },
                                      itemCount: state.hasReachedMax
                                          ? state.data.length
                                          : state.data.length + 1,
                                    ),
                                  ),
                                  _buildActionBottomBar(),
                                ],
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
                                child: Container(
                                  margin: const EdgeInsets.all(4),
                                  child: InkResponse(
                                    onTap: () {
                                      _rotate();
                                    },
                                    child: SvgPicture.asset(
                                      camera,
                                      color: Colors.black,
                                      semanticsLabel: 'camera',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                        return Stack(
                          children: [
                            Column(
                              children: [
                                ///Chat messages list
                                Expanded(
                                  child: ListView.builder(
                                    physics: AlwaysScrollableScrollPhysics(),
                                    controller: _scrollController,
                                    reverse: true,
                                    itemBuilder: (context, index) {
                                      if (index >= state.data.length)
                                        return Center(
                                            child:
                                                CupertinoActivityIndicator());
                                      return _buildSingleMessage(
                                          state.data[index]);
                                    },
                                    itemCount: state.hasReachedMax
                                        ? state.data.length
                                        : state.data.length + 1,
                                  ),
                                ),
                                _buildActionBottomBar(),
                              ],
                            ),
                          ],
                        );
                      }),
                ));
          }
          return Text('Something went wrong!');
        },
      ),
    );
  }

  ///Private Methods - Start
  void _rotate() {
    //Animate Icon
    _rotatedSubject.first.then((rotated) {
      if (rotated) {
        _rotatedSubject.add(false);
        _animationController.forward();
      } else {
        _rotatedSubject.add(true);
        _animationController.reverse();
      }
    });
  }

  bool _senderIsMe(int senderId) => myId == senderId;
  bool _bookingUserIsMe(int booingUserId) => myId == booingUserId;

  Future<void> _handleVoiceCall(String voiceChannelName) async {
    await [Permission.microphone].request();
    if (await Permission.microphone.request().isGranted) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VoiceCallWidget(
              channelName: voiceChannelName,
            ),
          ));
    } else if (await Permission.microphone.request().isDenied) {
      showDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text(
              G.of(context).pleaseAllowMicroPhone,
              textAlign: TextAlign.center,
            ),
            content: Text(G.of(context).youNeedToAllowMicroPermission),
            actions: <Widget>[
              FlatButton(
                child: Text(G.of(context).cancel),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text(G.of(context).confirm),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else if (await Permission.microphone.request().isPermanentlyDenied) {
      /// [Error]
      // Permanently being denied,you need to allow in app setting
      showDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text(
              G.of(context).pleaseAllowMicroPhone,
              textAlign: TextAlign.center,
            ),
            content: Text(G.of(context).youNeedToAllowMicroPermission),
            actions: <Widget>[
              FlatButton(
                child: Text(G.of(context).cancel),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text(G.of(context).confirm),
                onPressed: () {
                  openAppSettings();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      _chatBoxBloc.add(ChatBoxFetched());
    }
  }

  ///Private Methods - End
}
