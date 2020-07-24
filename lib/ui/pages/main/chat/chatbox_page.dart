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
import 'package:moonblink/view_model/call_model.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:moonblink/view_model/message_model.dart';
import 'package:moonblink/view_model/partner_detail_model.dart';
import 'package:oktoast/oktoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scoped_model/scoped_model.dart';

class ChatBoxPage extends StatefulWidget {
  ChatBoxPage(this.detailPageId);
  final int detailPageId;
  @override
  _ChatBoxPageState createState() => _ChatBoxPageState();
}

class _ChatBoxPageState extends State<ChatBoxPage> {
  // String voiceChannelName = '';
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
  int booking_accept = 1;
  int booking_reject = 2;

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

  // Timer _timer;
  // int _start = 10;

  // void startTimer(bool end) {
  //   const oneSec = const Duration(seconds: 1);
  //   _timer = new Timer.periodic(
  //     oneSec,
  //     (Timer timer) => setState(
  //       () {
  //         if (_start < 1) {
  //           timer.cancel();
  //         } else {
  //           _start = _start - 1;
  //         }
  //       },
  //     ),
  //   );
  //   end = false;
  // }

  // @override
  // void dispose() {
  //   _timer.cancel();
  //   super.dispose();
  // }

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
      case(0): return buildmsg(msg);
      break;
      case(1): return buildimage(msg);
      break;
      case(2): return buildVideo(msg);
      break;
      case(3): return buildaudio(msg);
      break;
      case(4): return buildcallmsg(status, bookingid, msg);
      break;
      case(5): return buildlocalimg(msg);
      break;
      case(6): return buildlocalaudio(msg);
      break;
      case(7): return buildrequest(msg, bookingid);
      break;
      default: return Text("error");
      break;
    }
  }

  //build request
  buildrequest(msg, bookingid) {
    return Container(
      width: 160,
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: msg.senderID == widget.detailPageId
            ? Colors.grey[300]
            : Theme.of(context).accentColor,
        borderRadius: BorderRadius.all(
          Radius.circular(15.0),
        ),
      ),
      child: Column(
        children: <Widget>[
          Text("Booking Request"),
          // noramlUserCancel(msg, bookingid),
          partneronly(msg, bookingid)
        ],
      ),
    );
  }

  //NormalUserToCancelBooking
  noramlUserCancel(msg, bookingid) {
    if (msg.senderID != widget.detailPageId) {
      return Flex(
        direction: Axis.horizontal,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[cancelRequestButton(bookingid)],
      );
    }
  }

  //TODO:
  cancelRequestButton(bookingid) {
    return ButtonTheme(
        minWidth: 70,
        child: FlatButton(
          child: Text("Delete Request",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          onPressed: () {
            MoonBlinkRepository.bookingAcceptOrDecline(
                selfId, bookingid, booking_reject);
          },
        ));
  }

  //Partner Only
  partneronly(msg, bookingid) {
    if (msg.senderID == widget.detailPageId) {
      return Flex(
        mainAxisSize: MainAxisSize.min,
        direction: Axis.horizontal,
        children: <Widget>[
          rejectbtn(bookingid),
          acceptbtn(bookingid),
        ],
      );
    } else
      return Container();
  }
  //Rating Box
  void rating() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: Text("something"),
            actions: [
              FlatButton(
                  child: Text("Go Back"),
                  onPressed: () {
                    Navigator.pop(context, 'Cancel');
                  })
            ],
          );
        });
  }
  //accept button
  acceptbtn(bookingid) {
    return ButtonTheme(
        minWidth: 70,
        child: FlatButton(
          child: Text("Accept",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          onPressed: () {
            MoonBlinkRepository.bookingAcceptOrDecline(
                selfId, bookingid, booking_accept);
          },
        ));
  }

  //reject button
  rejectbtn(bookingid) {
    return ButtonTheme(
        minWidth: 70,
        child: FlatButton(
          child: Text("Reject",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          onPressed: () {
            MoonBlinkRepository.bookingAcceptOrDecline(
                selfId, bookingid, booking_reject);
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
        color: msg.senderID == widget.detailPageId
            ? Colors.grey[300]
            : Theme.of(context).accentColor,
        borderRadius: BorderRadius.all(
          Radius.circular(15.0),
        ),
      ),
      child: Column(
        children: <Widget>[
          Text("Someone is Calling u"),
          buttoncheck(status, msg)
        ],
      ),
    );
  }

  //button enable
  buttoncheck(status, msg) {
    if (status == 1) {
      return MaterialButton(
        child: Text("Enter call"),
        onPressed: () {
          joinChannel(msg.attach);
        },
      );
    } else {
      return Text("Booking is ended",
          style: TextStyle(fontWeight: FontWeight.bold));
    }
  }

  //build msg template
  buildmsg(Message msg) {
    return Container(
      width: 150,
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: msg.senderID == widget.detailPageId
            ? Colors.grey[300]
            : Theme.of(context).accentColor,
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
    return Container(
      height: 100,
      width: 100,
      child: GestureDetector(
        child: Image.memory(file, fit: BoxFit.fill),
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
              icon: Icon(Icons.send),
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
            child: Text("End"),
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

  //action widget
  action1(id, status) {
    switch (status) {
      case (-1):
        return Text("error");
        break;
      case (0):
        return Text("pending");
        break;
      case (1):
        return callbtn(id);
        break;
      case (2):
        return Text("reject");
        break;
      case (3):
        return Text("done");
        break;
      case (4):
        return Text("expired");
        break;
      case (5):
        return Text("unavailable");
        break;
      case (6):
        return Text("cancel");
        break;
      default:
        return Text("default");
    }
  }

  action2(status, bookingid) {
    if (usertype == 1) {
      switch (status) {
        case (-1):
          return Text("error");
          break;
        case (0):
          return Text("pending");
          break;
        case (1):
          return endbtn(bookingid);
          break;
        case (2):
          return Text("reject");
          break;
        case (3):
          return Text("done");
          break;
        case (4):
          return Text("expired");
          break;
        case (5):
          return Text("unavailable");
          break;
        case (6):
          return Text("cancel");
          break;
        default:
          return Text("default");
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
    return ProviderWidget2<PartnerDetailModel, GetmsgModel>(
        autoDispose: true,
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
          for (var i = 0; i < msgmodel.list.length; i++) {
            Lastmsg msgs = msgmodel.list[i];
            messages.add(Message(msgs.msg, msgs.sender, msgs.receiver, now,
                msgs.attach, msgs.type));
          }
          // print(messages);
          return ScopedModelDescendant<ChatModel>(
          builder:(context, child, model){
          chatlist = model.conversationlist();
          if (chatlist.isNotEmpty) {
            print("is working chatlist");
            var status = chatlist.where((user) => user.userid == widget.detailPageId );
            print(status.toList());
            List chat = status.toList();
            user = chat[0];
          }
          else{
            print("Chatlist is empty");
            user.bookingStatus = 0;
          }
          if(user.bookingStatus == 3 ){
            Future.delayed(Duration.zero, () => rating());
          }
          return Scaffold(
            appBar: //buildappbar(model.partnerData.partnerId, model.partnerData.partnerName),
                AppBar(
              title: Text(partnermodel.partnerData.partnerName),
              actions: <Widget>[ 
                action2(user.bookingStatus, user.bookingid),
                action1(widget.detailPageId, user.bookingStatus),
              ],
            ),
            body: ListView(
              children: <Widget>[
                buildChatList(user.bookingStatus, user.bookingid,partnermodel.partnerData.partnerId, model),
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
                "Please allow Microphone",
                textAlign: TextAlign.center,
              ),
              content: Text(
                  "You need to allow Microphone permission to enable voice call"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    } else if (await Permission.microphone.request().isPermanentlyDenied) {
      print('Permanently being denied,user need to allow in app setting');
      showDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: Text(
                "Please allow Microphone to",
                textAlign: TextAlign.center,
              ),
              content: Text(
                  "You need to allow Microphone permission at App Settings"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Text("Ok"),
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
