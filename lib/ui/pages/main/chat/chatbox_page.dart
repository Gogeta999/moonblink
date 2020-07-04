import 'dart:io';
import 'dart:typed_data';

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
import 'package:moonblink/ui/pages/call/callerscreen.dart';
import 'package:moonblink/view_model/message_model.dart';
import 'package:moonblink/view_model/partner_detail_model.dart';
import 'package:scoped_model/scoped_model.dart';

Map<String, dynamic> _iceServers = {
  'iceServers': [
    {'url': 'stun:54.179.117.84:3478'},
    {
      'url': 'turn:54.179.117.84:3478',
      'username': 'moonblink',
      'credential': 'm00nblink'
    },
  ]
};
final Map<String, dynamic> _config = {
  'mandatory': {},
  'optional': [
    {'DtlsSrtpKeyAgreement': true},
  ],
};

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
  String now = DateTime.now().toString();
  String filename;
  File _image;

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

  //create peer connection
  _createPeerConnection() async {
    pc = await createPeerConnection(_iceServers, _config);
  }

  @override
  void initState() {
    super.initState();
    _createPeerConnection();
  }

  //build message
  Widget buildSingleMessage(Message message) {
    if (message.attach != "") {
      img = true;
    }
    return Container(
        alignment: message.senderID == widget.detailPageId
            ? Alignment.centerLeft
            : Alignment.centerRight,
        // padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
        padding: EdgeInsets.all(10.0),
        width: 100,
        margin: EdgeInsets.all(10.0),
        // decoration: BoxDecoration(
        // color: Theme.of(context).accentColor,
        // borderRadius: message.senderID == widget.detailPageId
        //   ? BorderRadius.only(
        //     topLeft: Radius.circular(15.0),
        //     bottomLeft: Radius.circular(15.0),
        //   )
        //   : BorderRadius.only(
        //     topRight: Radius.circular(15.0),
        //     bottomRight: Radius.circular(15.0),
        //   ),
        // ),
        child: Column(
          children: <Widget>[
            Text(message.text),
            img ? buildimage(message) : Text("")
          ],
        ));
  }

  //build image
  buildimage(Message msg) {
    img = false;
    // local = false;
    return Container(
      height: 100,
      width: 100,
      child:
          Image.network(msg.attach, loadingBuilder: (context, child, progress) {
        return progress == null
            ? child
            : SpinKitCircle(color: Theme.of(context).accentColor);
      }, fit: BoxFit.fill),
    );
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
                textCapitalization: TextCapitalization.sentences,
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Input message',
                ),
              ),
            ),
            IconButton(
              icon: Icon(FontAwesomeIcons.upload),
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
    });
  }

  //Conversation List
  Widget buildChatList(id) {
    return ScopedModelDescendant<ChatModel>(
      builder: (context, child, model) {
        // List<Message> msgs = model.getMessagesForChatID(id);
        // messages.addAll(msgs);
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
      },
    );
  }

  ///[Call Button]
  Widget buildfloat(id) {
    return ScopedModelDescendant<ChatModel>(
      builder: (context, child, model) {
        // RTCPeerConnection pc = _createPeerConnection();
        return FloatingActionButton(
            child: Text("Call"),
            onPressed: () {
              model.createOffer(id, pc, "video");
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CallerScreen(),
                  ));
              // model.createAnswer(id, pc, "video");
            });
      },
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
          print(msgmodel.list.length);
          for (var i = 0; i < msgmodel.list.length; i++) {
            Lastmsg msgs = msgmodel.list[i];
            messages.add(Message(
                msgs.msg, msgs.sender, msgs.receiver, now, msgs.attach));
          }
          print(messages);
          return Scaffold(
            // floatingActionButton: buildfloat(partnermodel.partnerData.partnerId),
            appBar: //buildappbar(model.partnerData.partnerId, model.partnerData.partnerName),
                AppBar(
              title: Text(partnermodel.partnerData.partnerName),
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
}
