import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:moonblink/base_widget/audioplayer.dart';
import 'package:moonblink/base_widget/imageview.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moonblink/base_widget/player.dart';
import 'package:moonblink/base_widget/indicator/button_indicator.dart';
import 'package:moonblink/base_widget/recorder.dart';
import 'package:moonblink/base_widget/video_player_widget.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/main.dart';
import 'package:moonblink/models/chatlist.dart';
import 'package:moonblink/models/message.dart';
import 'package:moonblink/models/partner.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/provider/view_state_error_widget.dart';
import 'package:moonblink/services/chat_service.dart';
import 'package:moonblink/models/contact.dart';
import 'package:moonblink/services/push_notification_manager.dart';
import 'package:moonblink/ui/pages/call/voice_call_page.dart';
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
  String voiceChannelName = '';
  PartnerUser partnerdata;
  int type = 1;
  Uint8List bytes;
  bool img = false;
  bool file = false;
  List<Message> messages = [];
  List<Contact> contacts = [];
  List<Chatlist> chatlist = [];
  List<Contact> users = [];
  String now = DateTime.now().toString();
  String filename;
  File _file;

  // ByteData _byteData;
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
  Widget buildSingleMessage(Message message) {
    return Container(
        alignment: message.senderID == widget.detailPageId
            ? Alignment.centerLeft
            : Alignment.centerRight,
        // padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
        // padding: EdgeInsets.all(10.0),
        margin: EdgeInsets.all(10.0),
        child: builds(message));
        // child: img ? buildimage(message) : buildmsg(message));
  }

  ///VoiceCallContainer
  // Widget callbutton(){
  // return Container(
  // alignment: Alignment.center,
  // padding: EdgeInsets.all(50),
  //   margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
  //   height: 100,
  //   width: 50,
  //   decoration: BoxDecoration(
  //     border: Border.all(width: 2.0, color: Colors.grey),
  //     // color: Colors.grey,
  //     borderRadius: BorderRadius.all(Radius.circular(20.0)),
  //   ),
  //   child: Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //     children: <Widget>[
  //       CircleAvatar(
  //         radius: 35,
  //         backgroundColor: Colors.black,
  //       ),
  //       IconButton(
  //           icon: Icon(
  //             FontAwesomeIcons.phoneSlash,
  //             color: Colors.red[500],
  //           ),
  //           onPressed: () {
  //             print('Decline');
  //           }),
  //       IconButton(
  //           icon: Icon(
  //             FontAwesomeIcons.phone,
  //             color: Colors.green[300],
  //           ),
  //           onPressed: () {
  //             Navigator.push(
  //                 context,
  //                 MaterialPageRoute(
  //                   builder: (context) => VoiceCallWidget(
  //                     channelName: 'voiceChannelName',
  //                   ),
  //                 ));
  //           }),
  //     ],
  //   ),
  // );
  // }
  //build msg
  builds(Message msg){
    switch (msg.type){
      //build widget for text msgs
      case(0): return buildmsg(msg);
      break;
      case(1): return buildimage(msg);
      break;
      case(2): return buildVideo(msg);
      break;
      case(3): return buildaudio(msg);
      break;
      case(4): return print("calling");
      break;
      case(5): return buildlocalimg(msg);
      break;
      case(6): return buildlocalaudio(msg);
      break;
    }
  }

  buildVideo(Message msg) {
    return VideoPlayerWidget(videoUrl: msg.attach);
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
  buildlocalimg(Message msg){
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
  buildlocalaudio(Message msg){
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
  buildaudio(Message msg){
    return PlayerWidget(url: msg.attach);
  }


  //Send message
  Widget buildmessage(id) {
    return ScopedModelDescendant<ChatModel>(builder: (context, child, model) {
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
            Voicemsg(id: id, messages: messages,),
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
    });
  }

  //For call button
  Widget callbtn(anotherPersonId) {
    return ScopedModelDescendant<ChatModel>(builder: (context, child, model) {
      voiceChannelName = 'UserId($selfId)CallToUserId($anotherPersonId)';
      return IconButton(
        icon: Icon(
          FontAwesomeIcons.phone,
          size: 20,
        ),
        onPressed: () {
          model.call(selfId, anotherPersonId, voiceChannelName);
          // PushNotificationsManager().showVoiceCallNotification('com.moonuniverse.moonblink', 'VoiceCallTitle', 'VoiceCallBody');
          joinChannel();
        },
      );
    });
  }
  //booking check
  checking(id){
    return ScopedModelDescendant<ChatModel>(
      builder: (context, child, model){
        chatlist = model.conversationlist();
        print(chatlist.length);
        var status = chatlist.where((user) => user.userid == id );
        // print(booking);
        List chat = status.toList();
        Chatlist user = chat[0];
        return statuscheck(id, user.bookingStatus);
      }
      );
  }
  //action widget
  statuscheck (id, status){
    switch (status){
      case(0): return Text("hello");
      break;
      case(1): return callbtn(id);
      break;
    }
  }
  //Conversation List
  Widget buildChatList(id) {
    return ScopedModelDescendant<ChatModel>(builder: (context, child, model) {
      model.receiver(messages);
      return Container(
        height: MediaQuery.of(context).size.height * 0.8,
        child: ListView.builder(
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (BuildContext context, int index) {
            return buildSingleMessage(messages[index]);
          },
        ),
      );
    });
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
          if (partnermodel.isBusy || msgmodel.isBusy) {
            return ViewStateBusyWidget();
          } else if (partnermodel.isError || msgmodel.isError) {
            return ViewStateErrorWidget(
                error: partnermodel.viewStateError,
                onPressed: () {
                  partnermodel.initData();
                  msgmodel.initData();
                });
          }
          messages.clear();
          print(msgmodel.list.length);
          for (var i = 0; i < msgmodel.list.length; i++) {
            Lastmsg msgs = msgmodel.list[i];
            messages.add(Message(
                msgs.msg, msgs.sender, msgs.receiver, now, msgs.attach, msgs.type));
          }
          print(messages);
          return Scaffold(
            appBar: //buildappbar(model.partnerData.partnerId, model.partnerData.partnerName),
                AppBar(
              title: Text(partnermodel.partnerData.partnerName),
              actions: <Widget>[
                checking(partnermodel.partnerData.partnerId)
                // statuscheck(partnermodel.partnerData.partnerId)
              ],
            ),
            body: ListView(
              children: <Widget>[
                buildChatList(partnermodel.partnerData.partnerId),
                buildmessage(partnermodel.partnerData.partnerId),
              ],
            ),
          );
        });
  }

  ///[CallFunction]
  ///Here is for voicCall
  Future<void> joinChannel() async {
    if (voiceChannelName.isNotEmpty) {
      await _handleVoiceCall();
    } else if (voiceChannelName.isEmpty) {
      showToast('Developer error');
    }
  }

  Future<void> _handleVoiceCall() async {
    await [Permission.microphone].request();
    if (await Permission.camera.request().isGranted) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VoiceCallWidget(
              channelName: voiceChannelName,
            ),
          ));
    } else if (await Permission.camera.request().isDenied) {
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
    } else if (await Permission.camera.request().isPermanentlyDenied) {
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
