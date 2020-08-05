import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:moonblink/base_widget/imageview.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moonblink/base_widget/player.dart';
import 'package:moonblink/base_widget/indicator/button_indicator.dart';
import 'package:moonblink/base_widget/recorder.dart';
import 'package:moonblink/base_widget/video_player_widget.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/resources_manager.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/chatlist.dart';
import 'package:moonblink/models/message.dart';
import 'package:moonblink/models/partner.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/provider/view_state_error_widget.dart';
import 'package:moonblink/services/chat_service.dart';
import 'package:moonblink/models/contact.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/ui/pages/call/voice_call_page.dart';
import 'package:moonblink/ui/pages/user/partner_detail_page.dart';
import 'package:moonblink/view_model/call_model.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:moonblink/view_model/message_model.dart';
import 'package:moonblink/view_model/partner_detail_model.dart';
import 'package:moonblink/view_model/rate_model.dart';
import 'package:oktoast/oktoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class ChatBoxPage extends StatefulWidget {
  ChatBoxPage(this.detailPageId);
  final int detailPageId;
  @override
  _ChatBoxPageState createState() => _ChatBoxPageState();
}

class _ChatBoxPageState extends State<ChatBoxPage> {
  //for Rating
  bool got = false;
  TextEditingController comment = TextEditingController();
  PartnerUser partnerdata;
  int type = 1;
  Uint8List bytes;
  bool img = false;
  bool file = false;
  List<Message> messages = [];
  List<Contact> contacts = [];
  List<Chatlist> chatlist = [];
  List<Contact> users = [];
  Chatlist user = Chatlist();
  String now = DateTime.now().toString();
  String filename;
  File _file;
  int bookingAccept = 1;
  int bookingReject = 2;

  // ByteData _byteData;
  final usertype = StorageManager.sharedPreferences.getInt(mUserType);
  final selfId = StorageManager.sharedPreferences.getInt(mUserId);
  final picker = ImagePicker();
  final TextEditingController textEditingController = TextEditingController();
  //File formatting

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      _file = File(pickedFile.path);
      filename = _file.path;
      bytes = _file.readAsBytesSync();
      print(bytes);
      // _byteData = ByteData.view(bytes.buffer);
      // print(_byteData);
    });
  }

  @override
  void initState() {
    super.initState();
    got = false;
  }

  //build messages
  Widget buildSingleMessage(int status, int bookingid, Message message) {
    return Container(
        alignment: message.senderID == widget.detailPageId
            ? Alignment.centerLeft
            : Alignment.centerRight,
        // padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
        // padding: EdgeInsets.all(10.0),
        margin: EdgeInsets.all(10.0),
        child: builds(status, bookingid, message));
    // child: img ? buildimage(message) : buildmsg(message));
  }

  //build msg
  builds(int status, int bookingid, Message msg) {
    switch (msg.type) {
      //build widget for text msgs
      case (0):
        return buildmsg(msg);
        break;
      case (1):
        return buildimage(msg);
        break;
      case (2):
        return buildVideo(msg);
        break;
      case (3):
        return buildaudio(msg);
        break;
      case (4):
        return buildcallmsg(status, bookingid, msg);
        break;
      case (5):
        return buildlocalimg(msg);
        break;
      case (6):
        return buildlocalaudio(msg);
        break;
      case (7):
        return buildrequest(msg, bookingid);
        break;
      default:
        return Text("Error");
        break;
    }
  }

  //build request
  buildrequest(msg, bookingid) {
    return Container(
      width: 160,
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Theme.of(context).accentColor,
        borderRadius: BorderRadius.all(
          Radius.circular(15.0),
        ),
      ),
      child: Column(
        children: <Widget>[
          Text(S.of(context).bookingRequest),
          // noramlUserCancel(msg, bookingid),
          partneronly(msg, bookingid)
        ],
      ),
    );
  }

  //Partner Only
  partneronly(msg, bookingid) {
    if (msg.senderID == widget.detailPageId) {
      return Flex(
        mainAxisSize: MainAxisSize.min,
        direction: Axis.horizontal,
        children: <Widget>[
          rejectbtn(bookingid, msg),
          acceptbtn(bookingid, msg),
        ],
      );
    } else
      return Container();
  }

  //Rating Box
  void rating(bookingid) {
    var rate = 5.0;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ProviderWidget<RateModel>(
              model: RateModel(),
              builder: (context, model, child) {
                return new AlertDialog(
                  title: Text(S.of(context).pleaseRatingForThisGame),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                  content: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SmoothStarRating(
                        starCount: 5,
                        rating: rate,
                        color: Theme.of(context).accentColor,
                        isReadOnly: false,
                        size: 30,
                        filledIconData: Icons.star,
                        halfFilledIconData: Icons.star_half,
                        defaultIconData: Icons.star_border,
                        allowHalfRating: true,
                        spacing: 2.0,
                        onRated: (value) {
                          print("rating value -> $value");
                          setState(() {
                            rate = value;
                          });
                        },
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Container(
                          margin: EdgeInsets.fromLTRB(0, 1.5, 0, 1.5),
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            border: Border.all(width: 1.5, color: Colors.grey),
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0)),
                          ),
                          child: TextField(
                            controller: comment,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              labelText: "Please give some comments",
                            ),
                          ))
                    ],
                  ),
                  actions: [
                    FlatButton(
                        child: Text(S.of(context).submit),
                        onPressed: () {
                          model
                              .rate(widget.detailPageId, bookingid, rate,
                                  comment.text)
                              .then((value) => value
                                  ? Navigator.pop(context)
                                  : showToast("Rating Failed"));
                        })
                  ],
                );
              });
        });
  }

  //accept button
  acceptbtn(bookingid, msg) {
    return ButtonTheme(
        minWidth: 70,
        child: ProviderWidget(
          model: CallModel(),
          builder: (context, model, child) {
            return FlatButton(
              child: Text(S.of(context).accept,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              onPressed: () {
                MoonBlinkRepository.bookingAcceptOrDecline(
                    selfId, bookingid, bookingAccept);
                msg.type = 0;
              },
            );
          },
        ));
  }

  //reject button
  rejectbtn(bookingid, msg) {
    return ButtonTheme(
        minWidth: 70,
        child: ProviderWidget(
          model: CallModel(),
          builder: (context, model, child) {
            return FlatButton(
              child: Text(S.of(context).reject,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              onPressed: () {
                MoonBlinkRepository.bookingAcceptOrDecline(
                    selfId, bookingid, bookingReject);
                msg.type = 0;
              },
            );
          },
        ));
  }

  //build video
  buildVideo(Message msg) {
    return VideoPlayerWidget(videoUrl: msg.attach);
  }

  //build call msg
  buildcallmsg(int status, int id, Message msg) {
    return Container(
      width: 150,
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Theme.of(context).accentColor,
        borderRadius: BorderRadius.all(
          Radius.circular(15.0),
        ),
      ),
      child: Column(
        children: <Widget>[
          Text(S.of(context).someoneCallingYou),
          buttoncheck(status, msg)
        ],
      ),
    );
  }

  //button enable
  buttoncheck(status, msg) {
    if (status == 1) {
      return MaterialButton(
        child: Text(
          S.of(context).enterCall,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        onPressed: () {
          joinChannel(msg.attach);
        },
      );
    } else {
      return Text(S.of(context).bookingEnded,
          style: TextStyle(fontWeight: FontWeight.bold));
    }
  }

  //build msg template
  buildmsg(Message msg) {
    return Container(
      width: 150,
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Theme.of(context).accentColor,
        borderRadius: BorderRadius.all(
          Radius.circular(15.0),
        ),
      ),
      child: Text(msg.text),
    );
  }

  //build temporary img file
  buildlocalimg(Message msg) {
    var file = new Uint8List.fromList(msg.attach.codeUnits);
    print(file);
    return Container(
      height: 100,
      width: 100,
      child: GestureDetector(
        child: Image.memory(file, fit: BoxFit.fill),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LocalImageView(file),
              ));
        },
      ),
    );
  }

  //build temporary audio file
  buildlocalaudio(Message msg) {
    var file = new Uint8List.fromList(msg.attach.codeUnits);
    File audio = File.fromRawPath(file);
    //need to fix path
    return PlayerWidget(url: audio.path);
  }

  //build image
  buildimage(Message msg) {
    return Container(
      height: 100,
      width: 100,
      child: GestureDetector(
        child: Image.network(msg.attach,
            loadingBuilder: (context, child, progress) {
          return progress == null ? child : ButtonProgressIndicator();
        }, fit: BoxFit.fill),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ImageView(msg.attach),
              ));
        },
      ),
    );
  }

  //build audio player
  buildaudio(Message msg) {
    return PlayerWidget(url: msg.attach);
  }

  //Send message
  Widget buildmessage(id, model) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      height: 70.0,
      //color: Theme.of(context).backgroundColor,
      child: Row(
        children: <Widget>[
          //Image select button
          IconButton(
            icon: Icon(FontAwesomeIcons.image),
            iconSize: 30.0,
            color: Theme.of(context).accentColor,
            onPressed: () {
              getImage();
            },
          ),
          //Voice record
          Voicemsg(
            id: id,
            messages: messages,
          ),
          //Text Input
          Expanded(
            child: TextField(
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.send,
              controller: textEditingController,
              decoration: InputDecoration.collapsed(
                hintText: 'Input message',
              ),
            ),
          ),
          //Send button
          IconButton(
            icon: Icon(IconFonts.sendIcon),
            iconSize: 30.0,
            color: Theme.of(context).accentColor,
            onPressed: () {
              if (bytes == null) {
                if (textEditingController.text != '') {
                  model.sendMessage(textEditingController.text, id, messages);
                  textEditingController.text = '';
                }
              } else {
                model.sendfile(filename, bytes, id, type, messages);
                textEditingController.text = '';
              }
            },
          ),
        ],
      ),
    );
  }

  //Booking End button
  Widget endbtn(bookingid) {
    return ProviderWidget(
        model: CallModel(),
        builder: (context, model, child) {
          return FlatButton(
            child: Text(S.of(context).end),
            onPressed: () {
              model.endbooking(selfId, bookingid, 3);
            },
          );
        });
  }

  //For call button
  Widget callbtn(anotherPersonId) {
    String voiceChannelName = 'UserId($selfId)CallToUserId($anotherPersonId)';
    return ProviderWidget(
        model: CallModel(),
        builder: (context, child, model) {
          // var callmodel = Provider.of<CallModel>(context);
          return IconButton(
            icon: Icon(
              FontAwesomeIcons.phone,
              size: 20,
            ),
            onPressed: () {
              // model.call(selfId, anotherPersonId, voiceChannelName);
              child.call(voiceChannelName, anotherPersonId);
              // PushNotificationsManager().showVoiceCallNotification('com.moonuniverse.moonblink', 'VoiceCallTitle', 'VoiceCallBody');
              joinChannel(voiceChannelName);
            },
          );
        });
  }

  bookingcancel(bookingid) {
    if (usertype == 0) {
      return ProviderWidget(
          model: CallModel(),
          builder: (context, model, child) {
            return FlatButton(
              child: Text(S.of(context).cancel),
              onPressed: () {
                model.endbooking(selfId, bookingid, 6);
              },
            );
          });
    } else {
      return Center(child: Text(S.of(context).cancel));
    }
  }

  //action 1
  action1(id, status, bookingid) {
    switch (status) {
      //normal
      case (-1):
        return Container();
        break;
      //cancel booking
      case (0):
        return bookingcancel(bookingid);
        break;
      //in booking
      case (1):
        return callbtn(id);
        break;
      //reject
      case (2):
        return Container();
        break;
      //done
      case (3):
        return Container();
        break;
      //expired
      case (4):
        return Container();
        break;
      //unavailable
      case (5):
        return Container();
        break;
      //cancel
      case (6):
        return Container();
        break;
      //default
      default:
        return Container();
    }
  }

  //action2
  action2(status, bookingid) {
    if (usertype == 1) {
      switch (status) {
        //normal
        case (-1):
          return Container();
          break;
        //pending
        case (0):
          return Container();
          break;
        //end booking
        case (1):
          return endbtn(bookingid);
          break;
        //reject
        case (2):
          return Container();
          break;
        //done
        case (3):
          return Container();
          break;
        //expired
        case (4):
          return Container();
          break;
        //unavailable
        case (5):
          return Container();
          break;
        //cancel
        case (6):
          return Container();
          break;
        //default
        default:
          return Container();
      }
    } else
      return Container();
  }

  //Conversation List
  Widget buildChatList(status, bookingid, id, model) {
    model.receiver(messages);
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      child: ListView.builder(
        reverse: true,
        itemCount: messages.length,
        itemBuilder: (BuildContext context, int index) {
          return buildSingleMessage(status, bookingid, messages[index]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print(got);
    return ProviderWidget2<PartnerDetailModel, GetmsgModel>(
        autoDispose: false,
        model1: PartnerDetailModel(partnerdata, widget.detailPageId),
        model2: GetmsgModel(widget.detailPageId),
        onModelReady: (partnerModel, msgModel) {
          partnerModel.initData();
          msgModel.initData();
        },
        builder: (context, partnermodel, msgmodel, child) {
          if (partnermodel.isBusy) {
            return ViewStateBusyWidget();
          } else if (partnermodel.isError) {
            return ViewStateErrorWidget(
                error: partnermodel.viewStateError,
                onPressed: () {
                  partnermodel.initData();
                  msgmodel.initData();
                });
          }
          if (got == false && msgmodel.list.isNotEmpty) {
            for (var i = 0; i < msgmodel.list.length; i++) {
              Lastmsg msgs = msgmodel.list[i];
              messages.add(Message(msgs.msg, msgs.sender, msgs.receiver, now,
                  msgs.attach, msgs.type));
            }
            got = true;
          }
          // print(messages);
          return ScopedModelDescendant<ChatModel>(
              builder: (context, child, model) {
            chatlist = model.conversationlist();
            if (chatlist.isNotEmpty) {
              print("is working chatlist");
              var status =
                  chatlist.where((user) => user.userid == widget.detailPageId);
              print(status.toList());
              List chat = status.toList();
              if (chat.isNotEmpty) {
                user = chat[0];
              } else {
                user.bookingStatus = -1;
              }
            } else {
              print("Chatlist is empty");
              user.bookingStatus = -1;
            }
            if (user.bookingStatus == 3 && msgmodel.isBusy) {
              Future.delayed(Duration.zero, () => rating(user.bookingid));
            }
            return Scaffold(
              // resizeToAvoidBottomInset: false,
              appBar: //buildappbar(model.partnerData.partnerId, model.partnerData.partnerName),
                  AppBar(
                title: GestureDetector(
                    child: Text(partnermodel.partnerData.partnerName),
                    onTap: partnermodel.partnerData.type == 1
                        ? () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PartnerDetailPage(
                                        widget.detailPageId)));
                          }
                        : null),
                actions: <Widget>[
                  action2(user.bookingStatus, user.bookingid),
                  action1(
                      widget.detailPageId, user.bookingStatus, user.bookingid),
                ],
              ),
              body: ListView(
                children: <Widget>[
                  buildChatList(user.bookingStatus, user.bookingid,
                      partnermodel.partnerData.partnerId, model),
                  buildmessage(partnermodel.partnerData.partnerId, model),
                ],
              ),
            );
          });
        });
  }

  ///[CallFunction]
  ///Here is for voicCall
  Future<void> joinChannel(voiceChannelName) async {
    if (voiceChannelName.isNotEmpty) {
      await _handleVoiceCall(voiceChannelName);
    } else if (voiceChannelName.isEmpty) {
      showToast('Developer error');
    }
  }

  Future<void> _handleVoiceCall(voiceChannelName) async {
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
                S.of(context).pleaseAllowMicroPhone,
                textAlign: TextAlign.center,
              ),
              content: Text(S.of(context).youNeedToAllowMicroPermission),
              actions: <Widget>[
                FlatButton(
                  child: Text(S.of(context).cancel),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Text(S.of(context).confirm),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    } else if (await Permission.microphone.request().isPermanentlyDenied) {
      /// [Error]
      // Permanently being denied,you need to allow in app setting
      showDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: Text(
                S.of(context).pleaseAllowMicroPhone,
                textAlign: TextAlign.center,
              ),
              content: Text(S.of(context).youNeedToAllowMicroPermission),
              actions: <Widget>[
                FlatButton(
                  child: Text(S.of(context).cancel),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Text(S.of(context).confirm),
                  onPressed: () {
                    openAppSettings();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    }
  }
}
