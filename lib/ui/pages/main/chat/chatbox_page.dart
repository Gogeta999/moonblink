import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:moonblink/base_widget/imageview.dart';
import 'package:moonblink/view_model/contact_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_webrtc/webrtc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moonblink/models/message.dart';
import 'package:moonblink/models/partner.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/provider/view_state_error_widget.dart';
import 'package:moonblink/services/chat_service.dart';
import 'package:moonblink/models/contact.dart';
import 'package:moonblink/view_model/message_model.dart';
import 'package:moonblink/view_model/partner_detail_model.dart';
import 'package:scoped_model/scoped_model.dart';

class ChatBoxPage extends StatefulWidget {
  ChatBoxPage(this.detailPageId);
  final int detailPageId;
  @override
  _ChatBoxPageState createState() => _ChatBoxPageState();
}

class _ChatBoxPageState extends State<ChatBoxPage> {
  PartnerUser partnerdata;
  Uint8List bytes;
  RTCPeerConnection pc;
  bool img = false;
  // bool local = false;
  List<Message> messages = [];
  List<Contact> contacts = [];
  List<Contact> users = [];
  String now = DateTime.now().toString();
  String filename;
  File _image;
  bool end = true;
  // ByteData _byteData;
  final picker = ImagePicker();
  final TextEditingController textEditingController = TextEditingController();
  //File formatting

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedFile.path);
      filename = _image.path;
      bytes = _image.readAsBytesSync();
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
    if (message.attach != "") {
      img = true;
    }
    return Container(
        alignment: message.senderID == widget.detailPageId
            ? Alignment.centerLeft
            : Alignment.centerRight,
        // padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
        // padding: EdgeInsets.all(10.0),
        margin: EdgeInsets.all(10.0),
        child: img ? buildimage(message) : buildmsg(message));
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
        borderRadius: msg.senderID == widget.detailPageId
            ? BorderRadius.all(
                Radius.circular(15.0),
              )
            : BorderRadius.all(
                Radius.circular(15.0),
              ),
      ),
      child: Text(msg.text),
    );
  }

  //build image
  buildimage(Message msg) {
    img = false;
    // local = false;
    return Container(
      height: 100,
      width: 100,
      child: GestureDetector(
        child: Image.network(msg.attach,
            loadingBuilder: (context, child, progress) {
          return progress == null
              ? child
              : SpinKitCircle(color: Theme.of(context).accentColor);
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

  //Send message
  Widget buildmessage(id, model) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      height: 70.0,
      //color: Theme.of(context).backgroundColor,
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(FontAwesomeIcons.image),
            iconSize: 30.0,
            color: Theme.of(context).accentColor,
            onPressed: () {
              getImage();
            },
          ),
          Expanded(
            child: TextField(
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.send,
              controller: textEditingController,
              decoration: InputDecoration.collapsed(
                hintText: 'Input message',
              ),
              onSubmitted: (text) {
                model.sendMessage(text, id, messages);
              },
            ),
          ),
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
                model.sendfile(filename, bytes, id, messages);
                textEditingController.text = '';
                bytes = null;
              }
            },
          ),
        ],
      ),
    );
  }

  //Conversation List
  Widget buildChatList(id, model) {
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
          if (partnermodel.isBusy && msgmodel.isBusy) {
            return ViewStateBusyWidget();
          } else if (partnermodel.isError && msgmodel.isError) {
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
                msgs.msg, msgs.sender, msgs.receiver, now, msgs.attach));
          }
          print(messages);
          return ScopedModelDescendant<ChatModel>(
              builder: (context, child, model) {
            model.receiver(messages);
            return Scaffold(
              appBar: //buildappbar(model.partnerData.partnerId, model.partnerData.partnerName),
                  AppBar(
                title: Text(partnermodel.partnerData.partnerName),
                actions: <Widget>[
                  // end ? Text("$_start") : Container()
                ],
              ),
              body: ListView(
                children: <Widget>[
                  buildChatList(partnermodel.partnerData.partnerId, model),
                  buildmessage(partnermodel.partnerData.partnerId, model),
                ],
              ),
            );
          });
        });
  }
}
