import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moonblink/base_widget/chat/floatingbutton.dart';
import 'package:moonblink/base_widget/chat/waitingtimeleft.dart';
import 'package:moonblink/base_widget/customDialog_widget.dart';
import 'package:moonblink/base_widget/custom_bottom_sheet.dart';
import 'package:moonblink/base_widget/imageview.dart';
import 'package:moonblink/base_widget/player.dart';
import 'package:moonblink/base_widget/video_player_widget.dart';
import 'package:moonblink/bloc_pattern/chat_box/chat_box_bloc.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/chat_models/booking_status.dart';
import 'package:moonblink/models/chat_models/last_message.dart';
import 'package:moonblink/models/partner.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/services/web_socket_service.dart';
import 'package:moonblink/ui/helper/icons.dart';
import 'package:moonblink/ui/helper/tutorial.dart';
import 'package:moonblink/ui/pages/booking_page/booking_page.dart';
import 'package:moonblink/ui/pages/call/voice_call_page.dart';
import 'package:moonblink/ui/pages/main/chat/rating_page.dart';
import 'package:moonblink/utils/compress_utils.dart';
import 'package:moonblink/utils/constants.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:oktoast/oktoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:rxdart/rxdart.dart';
import 'package:selectable_autolink_text/selectable_autolink_text.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class NewChatBoxPage extends StatefulWidget {
  final int partnerId;
  NewChatBoxPage(this.partnerId);
  @override
  _NewChatBoxPageState createState() => _NewChatBoxPageState();
}

class _NewChatBoxPageState extends State<NewChatBoxPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  ///Private Properties - Start
  ChatBoxBloc _chatBoxBloc;

  Timer _debounce;
  final int myId = StorageManager.sharedPreferences.getInt(mUserId);
  final int myType = StorageManager.sharedPreferences.getInt(mUserType);

  final _scrollThreshold = 200.0;
  final ScrollController _scrollController = ScrollController();

  final _rotatedSubject = BehaviorSubject.seeded(true);
  final _rotatedSubject2 = BehaviorSubject.seeded(false);
  final _upWidgetSubject = BehaviorSubject.seeded(false);

  AnimationController _animationController;
  AnimationController _animationController2;
  Animation<double> _animationbotmsg;
  Animation<double> _animation;
  Animation<double> _animation2;
  Animation<double> _animation3;

  ///Private Properties - End

  ///Lifecycle - Start
  @override
  void initState() {
    //_chatBoxBloc = ChatBoxBloc(widget.partnerId);
    if (myType == kNormal) {
      _chatBoxBloc = ChatBoxBloc.initNormal(widget.partnerId);
    } else {
      _chatBoxBloc = ChatBoxBloc(widget.partnerId);
    }
    _chatBoxBloc.add(ChatBoxFetched());
    WebSocketService().initWithChatBoxBloc(_chatBoxBloc);

    _scrollController.addListener(_onScroll);

    ///[Animation]
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    _animationController2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    _animationbotmsg = CurvedAnimation(
      parent: _animationController2,
      curve: Interval(0.0, 1.0, curve: Curves.linear),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.0, 1.0, curve: Curves.linear),
    );

    _animation2 = CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.5, 1.0, curve: Curves.linear),
    );

    _animation3 = CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.8, 1.0, curve: Curves.linear),
    );
    _animationController.reverse();

    ///[Chat Data]
    StorageManager.sharedPreferences.setBool(isUserAtChatBox, true);
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      if (myType == kNormal) _chatBoxBloc.saveTimer();
    }
  }

  @override
  void dispose() {
    StorageManager.sharedPreferences.setBool(isUserAtChatBox, false);
    WebSocketService().disposeWithChatBoxBloc();
    _debounce?.cancel();
    _animationController.dispose();
    _animationController2.dispose();
    _scrollController.dispose();
    List<Future> futures = [
      _rotatedSubject.close(),
      _upWidgetSubject.close(),
    ];
    Future.wait(futures);
    _chatBoxBloc.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  ///Lifecycle - End

  ///Private UI Widgets - Start
  Widget _buildMessageOnType(LastMessage lastMessage) {
    switch (lastMessage.type) {
      case MESSAGE:
        return _buildTextMessage(lastMessage);
      case IMAGE:
        return _buildImageMessage(lastMessage);
      case VIDEO:

        ///Not using
        return VideoPlayerWidget(videoUrl: lastMessage.attach);
      case AUDIO:
        return _buildAudioMessage(lastMessage);
      case CALL:
        return _buildCallMessage(lastMessage);
      case REQUEST:
        return _buildRequestMessage(lastMessage);
      default:
        return Text('This message type is not supported');
    }
  }

  Widget _buildBasicMessageWidget({Widget child, LastMessage lastMessage}) {
    return Container(
      alignment: _senderIsMe(lastMessage.senderId)
          ? Alignment.centerRight
          : Alignment.centerLeft,
      margin: EdgeInsets.all(10.0),
      child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.6,
          ),
          // maxHeight: MediaQuery.of(context).size.height * 0.3),
          decoration: BoxDecoration(
              color: _senderIsMe(lastMessage.senderId)
                  ? _isDark()
                      ? Theme.of(context).accentColor.withOpacity(0.5)
                      : Theme.of(context).accentColor
                  : _isDark()
                      ? Colors.black12
                      : Colors.white12,
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
              border: Border.all(
                  color: _senderIsMe(lastMessage.senderId)
                      ? Colors.black12
                      : Theme.of(context).accentColor)),
          child: child),
    );
  }

  Widget _buildTextMessage(LastMessage lastMessage) {
    return _buildBasicMessageWidget(
      lastMessage: lastMessage,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: SelectableAutoLinkText(
          lastMessage.message,
          toolbarOptions: ToolbarOptions(copy: true, selectAll: true),
          cursorRadius: Radius.circular(50),
          cursorColor: Colors.white,
          autofocus: true,
          style: TextStyle(
              color: _isDark() ? Colors.white : Colors.black,
              fontWeight: FontWeight.w500),
          linkStyle: TextStyle(color: Colors.blue),
          highlightedLinkStyle: TextStyle(
            color: Colors.blue,
            backgroundColor: Colors.blueAccent.withAlpha(0x33),
          ),
          onTap: (url) {
            ///Checking if the url is our video link or not. if true launch directly without showing warning since it's our supported url.
            if (url ==
                "https://www.facebook.com/MoonblinkUniverse/videos/3552024048229706/") {
              launch(url);
            } else if (url ==
                "https://www.facebook.com/MoonblinkUniverse/videos/1359862744362719/") {
              launch(url);
            } else {
              alerturl(url);
            }
          },
          onLongPress: (url) => Share.share(url),
        ),
      ),
    );
  }

  alerturl(url) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
          title: Text("Alert URL"),
          content: Container(
            child: Text(
                "This url is not our support url. We can't provide security for you.Make sure you want to open or not?"),
          ),
          actions: [
            FlatButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            FlatButton(
              onPressed: () {
                launch(url);
                Navigator.pop(context);
              },
              child: Text("View URL"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImageMessage(LastMessage lastMessage) {
    return _buildBasicMessageWidget(
      lastMessage: lastMessage,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: lastMessage.attach.contains('http')
            ? InkResponse(
                onTap: () => Navigator.push(
                    context,
                    CupertinoPageRoute(
                        fullscreenDialog: true,
                        builder: (_) =>
                            FullScreenImageView(imageUrl: lastMessage.attach))),
                child: CachedNetworkImage(
                  imageUrl: lastMessage.attach,
                  placeholder: (_, __) => Container(
                    margin: const EdgeInsets.all(4),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CupertinoActivityIndicator(),
                          SizedBox(height: 5),
                          Text('Downloading Image',
                              overflow: TextOverflow.ellipsis)
                        ],
                      ),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Icon(Icons.error),
                ),
              )
            : InkResponse(
                onTap: () => Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) =>
                          FullScreenImageView(image: File(lastMessage.attach)),
                    )),
                child: Image.file(File(lastMessage.attach))),
      ),
    );
  }

  Widget _buildAudioMessage(LastMessage lastMessage) {
    return _buildBasicMessageWidget(
        lastMessage: lastMessage,
        child: PlayerWidget(
            url: lastMessage.attach,
            isLocal: !lastMessage.attach.contains('http')));
  }

  Widget _buildCallMessage(LastMessage lastMesage) {
    return _buildBasicMessageWidget(
      lastMessage: lastMesage,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<BookingStatus>(
            initialData: null,
            stream: _chatBoxBloc.bookingStatusSubject,
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return CupertinoActivityIndicator();
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    G.of(context).someoneCallingYou,
                  ),
                  if (snapshot.data.status == 1)
                    CupertinoButton(
                      child: Text(G.of(context).enterCall),
                      onPressed: () => _handleVoiceCall(lastMesage.attach),
                    )
                  else
                    Text(G.of(context).bookingEnded)
                ],
              );
            }),
      ),
    );
  }

  Widget _buildRequestMessage(LastMessage lastMessage) {
    return _buildBasicMessageWidget(
      lastMessage: lastMessage,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SelectableText(
              lastMessage.message,
              style: TextStyle(
                  color: _isDark() ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w500),
              autofocus: true,
              cursorRadius: Radius.circular(50),
              cursorColor: Colors.white,
              toolbarOptions: ToolbarOptions(copy: true, selectAll: true),
            ),
            if (lastMessage.senderId == widget.partnerId)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ///Reject
                  StreamBuilder<bool>(
                      initialData: false,
                      stream: _chatBoxBloc.rejectButtonSubject,
                      builder: (context, snapshot) {
                        if (snapshot.data) {
                          return CupertinoButton(
                            child: CupertinoActivityIndicator(),
                            onPressed: () {},
                          );
                        }
                        return CupertinoButton(
                            child: Text(G.of(context).reject),
                            onPressed: () =>
                                _chatBoxBloc.add(ChatBoxRejectBooking()));
                      }),

                  ///Accept
                  StreamBuilder<bool>(
                      initialData: false,
                      stream: _chatBoxBloc.acceptButtonSubject,
                      builder: (context, snapshot) {
                        if (snapshot.data) {
                          return CupertinoButton(
                            child: CupertinoActivityIndicator(),
                            onPressed: () {},
                          );
                        }
                        return CupertinoButton(
                          child: Text(G.of(context).accept),
                          onPressed: () =>
                              _chatBoxBloc.add(ChatBoxAcceptBooking()),
                        );
                      })
                ],
              )
          ],
        ),
      ),
    );
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

        return Column(
          children: [
            if (myType == kNormal) _buildNormalUserButtons(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
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
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey
                                  : Colors.black),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.menu,
                            size: 30,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                          ),
                        ),
                      ),
                      onPressed: () => _rotate2()),
                  IconButton(
                    iconSize: 35,
                    icon: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        border: Border.all(
                            color:
                                Theme.of(context).brightness == Brightness.dark
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
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
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
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: 1,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey
                                  : Colors.black),
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(20)),
                      child: TextField(
                        minLines: 1,
                        maxLines: 3,
                        maxLength: 150,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.newline,
                        controller: _chatBoxBloc.messageController,
                        decoration: InputDecoration(
                          hintText: G.of(context).labelmsg,
                          counterText: "",
                        ),
                      ),
                    ),
                  ),
                  _buildSendButton(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNormalUserButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
                border: Border.all(
                    width: 1,
                    color: _isDark() ? Colors.white24 : Colors.black26),
                borderRadius: BorderRadius.circular(10)),
            child: Text(G.current.chatwelcome,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: _isDark() ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w300))),
        // Container(
        //   height: 60,
        //   margin: const EdgeInsets.symmetric(vertical: 4),
        //   child: ListView(
        //     shrinkWrap: true,
        //     scrollDirection: Axis.horizontal,
        //     physics: ClampingScrollPhysics(),
        //     children: [
        //       SizedBox(width: 10),

        //       ///First
        //       StreamBuilder<String>(
        //           initialData: null,
        //           stream: _chatBoxBloc.firstButtonSubject,
        //           builder: (context, snapshot) {
        //             if (snapshot.data == null) {
        //               return Container(
        //                 decoration: BoxDecoration(
        //                     border: Border.all(
        //                         width: 1, color: Theme.of(context).accentColor),
        //                     borderRadius: BorderRadius.circular(8)),
        //                 padding: const EdgeInsets.all(12),
        //                 child: Center(child: CupertinoActivityIndicator()),
        //               );
        //             }
        //             if (snapshot.data.isNotEmpty) {
        //               return Container(
        //                 padding: const EdgeInsets.all(4),
        //                 decoration: BoxDecoration(
        //                     border: Border.all(
        //                         width: 1, color: Theme.of(context).accentColor),
        //                     borderRadius: BorderRadius.circular(8)),
        //                 child: Center(
        //                   child: Padding(
        //                     padding: const EdgeInsets.symmetric(horizontal: 12),
        //                     child: Text('${snapshot.data}'),
        //                   ),
        //                 ),
        //               );
        //             }
        //             return InkResponse(
        //               onTap: () => _chatBoxBloc.add(ChatBoxCheckAvailable()),
        //               child: Container(
        //                 decoration: BoxDecoration(
        //                     border: Border.all(
        //                         width: 1, color: Theme.of(context).accentColor),
        //                     borderRadius: BorderRadius.circular(8)),
        //                 padding: const EdgeInsets.all(4),
        //                 child: Center(
        //                   child: Text(G.current.chatavailable,
        //                       textAlign: TextAlign.center),
        //                 ),
        //               ),
        //             );
        //           }),
        //       SizedBox(width: 10),

        //       ///Second
        //       StreamBuilder<String>(
        //           initialData: null,
        //           stream: _chatBoxBloc.secondButtonSubject,
        //           builder: (context, snapshot) {
        //             if (snapshot.data == null) {
        //               return Container(
        //                 decoration: BoxDecoration(
        //                     border: Border.all(
        //                         width: 1, color: Theme.of(context).accentColor),
        //                     borderRadius: BorderRadius.circular(8)),
        //                 padding: const EdgeInsets.all(12),
        //                 child: Center(child: CupertinoActivityIndicator()),
        //               );
        //             }
        //             if (snapshot.data.isNotEmpty) {
        //               return Container(
        //                 padding: const EdgeInsets.all(4),
        //                 decoration: BoxDecoration(
        //                     border: Border.all(
        //                         width: 1, color: Theme.of(context).accentColor),
        //                     borderRadius: BorderRadius.circular(8)),
        //                 child: Center(
        //                   child: Padding(
        //                     padding: const EdgeInsets.symmetric(horizontal: 12),
        //                     child: Text('${snapshot.data}'),
        //                   ),
        //                 ),
        //               );
        //             }
        //             return InkResponse(
        //               onTap: () async {
        //                 StorageManager.sharedPreferences
        //                     .setBool(bookingtuto, true);
        //                 PartnerUser partnerData =
        //                     await MoonBlinkRepository.fetchPartner(
        //                         widget.partnerId);
        //                 Navigator.pushNamed(context, RouteName.booking,
        //                     arguments: partnerData);
        //               },
        //               child: Container(
        //                 decoration: BoxDecoration(
        //                     border: Border.all(
        //                         width: 1, color: Theme.of(context).accentColor),
        //                     borderRadius: BorderRadius.circular(8)),
        //                 padding: const EdgeInsets.all(4),
        //                 child: Center(
        //                   child: Text(G.current.chatbook,
        //                       textAlign: TextAlign.center),
        //                 ),
        //               ),
        //             );
        //           }),
        //       SizedBox(width: 10),

        //       ///Third
        //       StreamBuilder<String>(
        //           initialData: null,
        //           stream: _chatBoxBloc.secondButtonSubject,
        //           builder: (context, snapshot) {
        //             if (snapshot.data == null) {
        //               return Container(
        //                 decoration: BoxDecoration(
        //                     border: Border.all(
        //                         width: 1, color: Theme.of(context).accentColor),
        //                     borderRadius: BorderRadius.circular(8)),
        //                 padding: const EdgeInsets.all(12),
        //                 child: Center(child: CupertinoActivityIndicator()),
        //               );
        //             }
        //             if (snapshot.data.isNotEmpty) {
        //               return Container(
        //                 padding: const EdgeInsets.all(4),
        //                 decoration: BoxDecoration(
        //                     border: Border.all(
        //                         width: 1, color: Theme.of(context).accentColor),
        //                     borderRadius: BorderRadius.circular(8)),
        //                 child: Center(
        //                   child: Padding(
        //                     padding: const EdgeInsets.symmetric(horizontal: 12),
        //                     child: Text('${snapshot.data}'),
        //                   ),
        //                 ),
        //               );
        //             }
        //             return InkResponse(
        //               onTap: () => _chatBoxBloc.add(ChatBoxSecondButton()),
        //               child: Container(
        //                 decoration: BoxDecoration(
        //                     border: Border.all(
        //                         width: 1, color: Theme.of(context).accentColor),
        //                     borderRadius: BorderRadius.circular(8)),
        //                 padding: const EdgeInsets.all(4),
        //                 child: Center(
        //                   child: Text(G.current.chatbuycoin,
        //                       textAlign: TextAlign.center),
        //                 ),
        //               ),
        //             );
        //           }),
        //       SizedBox(width: 10),

        //       ///Fourth
        //       StreamBuilder<String>(
        //           initialData: null,
        //           stream: _chatBoxBloc.thirdButtonSubject,
        //           builder: (context, snapshot) {
        //             if (snapshot.data == null) {
        //               return Container(
        //                 decoration: BoxDecoration(
        //                     border: Border.all(
        //                         width: 1, color: Theme.of(context).accentColor),
        //                     borderRadius: BorderRadius.circular(8)),
        //                 padding: const EdgeInsets.all(12),
        //                 child: Center(child: CupertinoActivityIndicator()),
        //               );
        //             }
        //             if (snapshot.data.isNotEmpty) {
        //               return Container(
        //                 padding: const EdgeInsets.all(4),
        //                 decoration: BoxDecoration(
        //                     border: Border.all(
        //                         width: 1, color: Theme.of(context).accentColor),
        //                     borderRadius: BorderRadius.circular(8)),
        //                 child: Center(
        //                   child: Padding(
        //                     padding: const EdgeInsets.symmetric(horizontal: 12),
        //                     child: Text('${snapshot.data}'),
        //                   ),
        //                 ),
        //               );
        //             }
        //             return InkResponse(
        //               onTap: () => _chatBoxBloc.add(ChatBoxThirdButton()),
        //               child: Container(
        //                 decoration: BoxDecoration(
        //                     border: Border.all(
        //                         width: 1, color: Theme.of(context).accentColor),
        //                     borderRadius: BorderRadius.circular(8)),
        //                 padding: const EdgeInsets.all(4),
        //                 child: Center(
        //                   child: Text(G.current.chathowtoplay,
        //                       textAlign: TextAlign.center),
        //                 ),
        //               ),
        //             );
        //           }),
        //       SizedBox(width: 10),
        //     ],
        //   ),
        // ),
      ],
    );
  }

  Widget _buildSendButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: InkResponse(
        onTap: () => _chatBoxBloc.add(ChatBoxSendMessage()),
        child: SvgPicture.asset(
          send,
          color: Colors.white,
          semanticsLabel: 'send',
          width: 30,
          height: 30,
        ),
      ),
    );
  }

  Widget _buildPickImageIcon() {
    return Container(
      margin: const EdgeInsets.all(4),
      child: InkResponse(
        child: SvgPicture.asset(
          gallery,
          color: Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).accentColor
              : Colors.black,
          semanticsLabel: 'gallery',
        ),
        onTap: () {
          _rotate();
          CustomBottomSheet.show(
              popAfterBtnPressed: true,
              requestType: RequestType.image,
              buttonText: G.of(context).sendbutton,
              buildContext: context,
              limit: 1,
              body: G.of(context).labelimageselect,
              onPressed: (File file) {
                _chatBoxBloc.add(ChatBoxSendImage(file));
              },
              //onInit: _sendMessageWidgetUp,
              //onDismiss: _sendMessageWidgetDown,
              minWidth: 500,
              minHeight: 500,
              willCrop: false,
              compressQuality: LOW_COMPRESS_QUALITY);
        },
      ),
    );
  }

  Widget _buildCameraIcon() {
    return Container(
      margin: const EdgeInsets.all(4),
      child: InkResponse(
        onTap: () async {
          _rotate();
          PickedFile pickedFile =
              await ImagePicker().getImage(source: ImageSource.camera);
          File image = File(pickedFile.path);
          File compressedImage = await CompressUtils.compressAndGetFile(
              image, LOW_COMPRESS_QUALITY, 500, 500);
          _chatBoxBloc.add(ChatBoxSendImage(compressedImage));
        },
        child: SvgPicture.asset(
          camera,
          color: Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).accentColor
              : Colors.black,
          semanticsLabel: 'camera',
        ),
      ),
    );
  }

  Widget _buildVoiceRecorderIcon() {
    return Container(
        margin: const EdgeInsets.all(4),
        child: InkResponse(
          onTap: () {
            _rotate();
            CustomBottomSheet.showNewVoiceSheet(
                buildContext: context,
                send: (File audio) {
                  _chatBoxBloc.add(ChatBoxSendAudio(audio));
                });
          },
          child: SvgPicture.asset(
            microphone,
            color: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).accentColor
                : Colors.black,
            semanticsLabel: 'microphone',
          ),
        ));
  }

  Widget _buildBookingCancelButton() {
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
          onPressed: () => _chatBoxBloc.add(ChatBoxCancelBooking()),
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

  Widget _buildBookingEndButton() {
    return CupertinoButton(
        child: Text(
          G.of(context).end,
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () => _chatBoxBloc.bookingStatusSubject.first
            .then((value) => _showBookingEndDialog(value)));
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
            _bookingUserIsMe(snapshot.data.bookingUserId)) {
          return WaitingTimeLeft(createat: snapshot.data.createdAt);
        }
        if (snapshot.data.status == ACCEPTED &&
            _bookingUserIsMe(snapshot.data.bookingUserId)) {
          return _buildBookingEndButton();
        }
        if (snapshot.data.status != ACCEPTED) {
          return blockbtn();
        }
        return Container();
      },
    );
  }

  //Block Button
  Widget blockbtn() {
    return IconButton(
      icon: Icon(FontAwesomeIcons.info),
      color: Theme.of(context).accentColor,
      onPressed: () => CustomBottomSheet.showUserManageContent(
          buildContext: context,
          onReport: () async {
            ///Reporting user
            try {
              await MoonBlinkRepository.reportUser(widget.partnerId);

              ///Api call success
              showToast(
                  'Thanks for making our MoonBlink\'s Universe clean and tidy. We will act on this user within 24 hours.');
              Navigator.pop(context);
            } catch (e) {
              showToast('Sorry, $e');
            }
          },
          onBlock: () async {
            ///Blocking user
            MoonBlinkRepository.blockOrUnblock(widget.partnerId, 1)
                .then((value) {
              int count = 0;
              Navigator.popUntil(context, (route) {
                return count++ == 2;
              });
            });
          },
          onDismiss: () => print('Dismissing BottomSheet')),
    );
  }

  Widget _buildSecondAction() {
    return StreamBuilder<BookingStatus>(
      initialData: null,
      stream: _chatBoxBloc.bookingStatusSubject,
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return CupertinoActivityIndicator();
        }
        if (snapshot.data.status == PENDING &&
            _bookingUserIsMe(snapshot.data.bookingUserId)) {
          return _buildBookingCancelButton();
        }
        if (snapshot.data.status == ACCEPTED) {
          return _buildPhoneButton(snapshot.data.userId);
        }
        return Container();
      },
    );
  }

  Widget _buildChatBoxBody(ChatBoxState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state is ChatBoxInitial)
          Expanded(
              child: Center(
            child: CupertinoActivityIndicator(),
          )),
        if (state is ChatBoxFailure)
          Expanded(
              child: Center(
                  child: Text(
            state.error.toString(),
          ))),
        if (state is ChatBoxSuccess)

          ///Chat messages list
          Expanded(
            child: ListView.builder(
              physics: AlwaysScrollableScrollPhysics(),
              controller: _scrollController,
              reverse: true,
              itemBuilder: (context, index) {
                if (index >= state.data.length)
                  return Center(child: CupertinoActivityIndicator());
                return _buildMessageOnType(state.data[index]);
              },
              itemCount: state.hasReachedMax
                  ? state.data.length
                  : state.data.length + 1,
            ),
          ),
        if (widget.partnerId != 48) _buildActionBottomBar(),
      ],
    );
  }

  ///Private UI Widgets - End

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _chatBoxBloc,
      child: BlocListener<ChatBoxBloc, ChatBoxState>(
        listenWhen: (previous, current) {
          return !(current is ChatBoxInitial) &&
              !(current is ChatBoxFailure) &&
              !(current is ChatBoxSuccess);
        },
        listener: (context, state) {
          if (state is ChatBoxCancelBookingSuccess) {
            showToast('Booking Cancelled');
          }
          if (state is ChatBoxCancelBookingFailure) {
            showToast(state.error.toString());
          }
          if (state is ChatBoxCallFailure) {
            showToast(state.error.toString());
          }
          if (state is ChatBoxCallSuccess) {
            _handleVoiceCall(state.channel);
          }
          if (state is ChatBoxEndBookingSuccess) {
            showToast('Booking Ended');
          }
          if (state is ChatBoxEndBookingFailure) {
            showToast(state.error.toString());
          }
          if (state is ChatBoxRejectBookingSuccess) {
            showToast('Booking Rejected');
          }
          if (state is ChatBoxRejectBookingFailure) {
            showToast(state.error.toString());
          }
          if (state is ChatBoxAcceptBookingFailure) {
            showToast(state.error.toString());
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
                icon: SvgPicture.asset(
                  back,
                  semanticsLabel: 'back',
                  color: Theme.of(context).accentColor,
                  width: 30,
                  height: 30,
                ),
                onPressed: () => Navigator.pop(context)),
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.black
                : Colors.black,
            title: StreamBuilder<PartnerUser>(
                initialData: null,
                stream: _chatBoxBloc.partnerUserSubject,
                builder: (context, snapshot) {
                  if (snapshot.data == null) {
                    return CupertinoActivityIndicator();
                  }
                  return GestureDetector(
                      child: Row(
                        children: [
                          CachedNetworkImage(
                            imageUrl:
                                snapshot.data.prfoileFromPartner.profileImage,
                            imageBuilder: (context, item) {
                              return CircleAvatar(
                                backgroundImage: item,
                              );
                            },
                            placeholder: (_, __) =>
                                CupertinoActivityIndicator(),
                            errorWidget: (_, __, ___) => Icon(Icons.error),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              snapshot.data.partnerName,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: widget.partnerId == 48
                                      ? Theme.of(context).accentColor
                                      : Colors.white),
                            ),
                          ),
                        ],
                      ),
                      onTap: snapshot.data.type != 0
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
                          : null);
                }),
            actions: <Widget>[_buildFirstAction(), _buildSecondAction()],
          ),
          body: SafeArea(
            child: Stack(
              children: [
                BlocBuilder<ChatBoxBloc, ChatBoxState>(
                    buildWhen: (previous, current) {
                      return current is ChatBoxInitial ||
                          current is ChatBoxFailure ||
                          current is ChatBoxSuccess;
                    },
                    builder: (context, state) => _buildChatBoxBody(state)),
                StreamBuilder<bool>(
                    initialData: true,
                    stream: _rotatedSubject,
                    builder: (context, snapshot) {
                      if (!snapshot.data) {
                        return FloatingButton(
                          bottom: 80,
                          left: 10,
                          scale: _animation,
                          child: _buildPickImageIcon(),
                        );
                      }
                      return Container();
                    }),
                StreamBuilder<bool>(
                    initialData: true,
                    stream: _rotatedSubject,
                    builder: (context, snapshot) {
                      if (!snapshot.data) {
                        return FloatingButton(
                          bottom: 140,
                          left: 30,
                          scale: _animation2,
                          child: _buildVoiceRecorderIcon(),
                        );
                      }
                      return Container();
                    }),
                StreamBuilder<bool>(
                    initialData: true,
                    stream: _rotatedSubject,
                    builder: (context, snapshot) {
                      if (!snapshot.data) {
                        return FloatingButton(
                            bottom: 200,
                            left: 10,
                            scale: _animation,
                            child: _buildCameraIcon());
                      }
                      return Container();
                    }),

                ///bot messages
                StreamBuilder<bool>(
                  initialData: false,
                  stream: _rotatedSubject2,
                  builder: (context, snapshot) {
                    if (!snapshot.data) {
                      _animationController2.forward();
                      return Positioned(
                        bottom: 80,
                        left: 10,
                        child: new ScaleTransition(
                          scale: _animationbotmsg,
                          alignment: FractionalOffset.center,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 4,
                            child: Container(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  firstbotmsg(),
                                  SizedBox(height: 10),
                                  secbotmsg(),
                                  thirdbotmsg(),
                                  SizedBox(height: 10),
                                  fourthbotmsg(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return Container();
                  },
                ),
                // StreamBuilder<bool>(
                //   initialData: true,
                //   stream: _rotatedSubject2,
                //   builder: (context, snapshot) {
                //     if (!snapshot.data) {
                //       return Positioned(
                //         bottom: 140,
                //         left: 10,
                //         child: new Container(
                //           child: new ScaleTransition(
                //             scale: _animation,
                //             alignment: FractionalOffset.center,
                //             child: thirdbotmsg(),
                //           ),
                //         ),
                //       );
                //     }
                //     return Container();
                //   },
                // ),
                // StreamBuilder<bool>(
                //   initialData: true,
                //   stream: _rotatedSubject2,
                //   builder: (context, snapshot) {
                //     if (!snapshot.data) {
                //       return Positioned(
                //         bottom: 200,
                //         left: 10,
                //         child: new Container(
                //           child: new ScaleTransition(
                //             scale: _animation,
                //             alignment: FractionalOffset.center,
                //             child: fourthbotmsg(),
                //           ),
                //         ),
                //       );
                //     }
                //     return Container();
                //   },
                // ),
                // StreamBuilder<bool>(
                //   initialData: true,
                //   stream: _rotatedSubject2,
                //   builder: (context, snapshot) {
                //     if (!snapshot.data) {
                //       return Positioned(
                //         bottom: 260,
                //         left: 10,
                //         child: new Container(
                //           child: new ScaleTransition(
                //             scale: _animation,
                //             alignment: FractionalOffset.center,
                //             child: secbotmsg(),
                //           ),
                //         ),
                //       );
                //     }
                //     return Container();
                //   },
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///First Bot Message
  firstbotmsg() {
    return StreamBuilder<String>(
        initialData: null,
        stream: _chatBoxBloc.firstButtonSubject,
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return Container(
              decoration: BoxDecoration(
                  border: Border.all(
                      width: 1, color: Theme.of(context).accentColor),
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.all(12),
              child: Center(child: CupertinoActivityIndicator()),
            );
          }
          if (snapshot.data.isNotEmpty) {
            return Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  border: Border.all(
                      width: 1, color: Theme.of(context).accentColor),
                  borderRadius: BorderRadius.circular(8)),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('${snapshot.data}'),
                ),
              ),
            );
          }
          return InkResponse(
            onTap: () => _chatBoxBloc.add(ChatBoxCheckAvailable()),
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(
                      width: 1, color: Theme.of(context).accentColor),
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.all(4),
              child: Center(
                child:
                    Text(G.current.chatavailable, textAlign: TextAlign.center),
              ),
            ),
          );
        });
  }

  ///Second Bot Message
  secbotmsg() {
    return StreamBuilder<PartnerUser>(
      initialData: null,
      stream: _chatBoxBloc.partnerUserSubject,
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return Container(
            decoration: BoxDecoration(
                border:
                    Border.all(width: 1, color: Theme.of(context).accentColor),
                borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.all(12),
            child: Center(child: CupertinoActivityIndicator()),
          );
        }
        if (snapshot.data.type == kNormal) {
          return Container();
        }
        return InkResponse(
          onTap: () async {
            StorageManager.sharedPreferences.setBool(bookingtuto, true);
            PartnerUser partnerData =
                await _chatBoxBloc.partnerUserSubject.first;
            // await MoonBlinkRepository.fetchPartner(widget.partnerId);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => BookingPage(
                  partnerId: partnerData.partnerId,
                  partnerName: partnerData.partnerName,
                  partnerBios: partnerData.prfoileFromPartner.bios,
                  partnerProfile: partnerData.prfoileFromPartner.profileImage,
                ),
              ),
            );
          },
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                    border: Border.all(
                        width: 1, color: Theme.of(context).accentColor),
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.all(4),
                child: Center(
                  child: Text(G.current.chatbook, textAlign: TextAlign.center),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  ///Third Bot Msg
  thirdbotmsg() {
    return StreamBuilder<String>(
      initialData: null,
      stream: _chatBoxBloc.secondButtonSubject,
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return Container(
            decoration: BoxDecoration(
                border:
                    Border.all(width: 1, color: Theme.of(context).accentColor),
                borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.all(12),
            child: Center(child: CupertinoActivityIndicator()),
          );
        }
        if (snapshot.data.isNotEmpty) {
          return Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
                border:
                    Border.all(width: 1, color: Theme.of(context).accentColor),
                borderRadius: BorderRadius.circular(8)),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('${snapshot.data}'),
              ),
            ),
          );
        }
        return InkResponse(
          onTap: () => _chatBoxBloc.add(ChatBoxSecondButton()),
          child: Container(
            decoration: BoxDecoration(
                border:
                    Border.all(width: 1, color: Theme.of(context).accentColor),
                borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.all(4),
            child: Center(
              child: Text(G.current.chatbuycoin, textAlign: TextAlign.center),
            ),
          ),
        );
      },
    );
  }

  ///Fourth Bot Message
  fourthbotmsg() {
    return StreamBuilder<String>(
      initialData: null,
      stream: _chatBoxBloc.thirdButtonSubject,
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return Container(
            decoration: BoxDecoration(
                border:
                    Border.all(width: 1, color: Theme.of(context).accentColor),
                borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.all(12),
            child: Center(child: CupertinoActivityIndicator()),
          );
        }
        if (snapshot.data.isNotEmpty) {
          return Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
                border:
                    Border.all(width: 1, color: Theme.of(context).accentColor),
                borderRadius: BorderRadius.circular(8)),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('${snapshot.data}'),
              ),
            ),
          );
        }
        return InkResponse(
          onTap: () => _chatBoxBloc.add(ChatBoxThirdButton()),
          child: Container(
            decoration: BoxDecoration(
                border:
                    Border.all(width: 1, color: Theme.of(context).accentColor),
                borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.all(4),
            child: Center(
              child: Text(G.current.chathowtoplay, textAlign: TextAlign.center),
            ),
          ),
        );
      },
    );
  }

  ///Private Methods - Start
  void _rotate() {
    //Animate Icon
    _rotatedSubject.first.then((rotated) {
      if (rotated) {
        _rotatedSubject.add(false);
        _animationController.forward();
        _rotatedSubject2.add(true);
        _animationController2.reverse();
      } else {
        _rotatedSubject.add(true);
        _animationController.reverse();
      }
    });
  }

  /// For bot messages
  ///Private Methods - Start
  void _rotate2() {
    //Animate Icon
    _rotatedSubject2.first.then((rotated) {
      if (rotated) {
        _rotatedSubject2.add(false);
        _animationController2.forward();
        _rotatedSubject.add(true);
        _animationController.reverse();
      } else {
        _rotatedSubject2.add(true);
        _animationController2.reverse();
      }
    });
  }

  bool _senderIsMe(int senderId) => myId == senderId;
  bool _bookingUserIsMe(int booingUserId) => myId == booingUserId;
  bool _isDark() => Theme.of(context).brightness == Brightness.dark;

  //bottom widget up
  ///not using now
  // _sendMessageWidgetUp() {
  //   _upWidgetSubject.add(true);
  //   _scrollController.animateTo(MediaQuery.of(context).size.height * 0.4,
  //       duration: Duration(milliseconds: 300), curve: Curves.ease);
  // }

  //bottom widget down
  // _sendMessageWidgetDown() {
  //   _upWidgetSubject.add(false);
  //   _scrollController.animateTo(0.0,
  //       duration: Duration(milliseconds: 300), curve: Curves.ease);
  // }

  Future<void> _handleVoiceCall(String voiceChannelName) async {
    final otherProfile = await _chatBoxBloc.partnerUserSubject.first;
    final otherProfileImage = otherProfile.prfoileFromPartner.profileImage;
    await [Permission.microphone].request();
    if (await Permission.microphone.request().isGranted) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => VoiceCallWidget(
                  channelName: voiceChannelName,
                  otherUserProfile: otherProfileImage)));
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

  void _showBookingEndDialog(BookingStatus bookingStatus) {
    showDialog(
        context: context,
        builder: (_) {
          return CustomDialog(
            title: G.of(context).bookingEnded,
            simpleContent: 'Are you sure to end this order?',
            // row2Content: BookingTimeLeft(
            //   count: bookingStatus.count,
            //   upadateat: bookingStatus.updatedAt,
            //   timeleft: bookingStatus.minutePerSection,
            // ),
            cancelColor: Theme.of(context).accentColor,
            confirmButtonColor: Theme.of(context).accentColor,
            confirmContent: G.of(context).end,
            confirmCallback: () {
              _chatBoxBloc.add(ChatBoxEndBooking());
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      RatingPage(bookingStatus.bookingId, widget.partnerId),
                ),
              );
            },
          );
        });
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      if (_debounce?.isActive ?? false) _debounce.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        _chatBoxBloc.add(ChatBoxFetchedMore());
      });
    }
  }

  ///Private Methods - End
}
