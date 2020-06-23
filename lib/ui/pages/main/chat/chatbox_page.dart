import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/webrtc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moonblink/models/message.dart';
import 'package:moonblink/models/partner.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/provider/view_state_error_widget.dart';
import 'package:moonblink/services/chat_service.dart';
import 'package:moonblink/ui/pages/call/callerscreen.dart';
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
  // ByteData _byteData;
  final picker = ImagePicker();
  final TextEditingController textEditingController = TextEditingController();
  //File formatting
  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      File _image = File(pickedFile.path);
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
    return Container(
      alignment: message.senderID == widget.detailPageId
          ? Alignment.centerLeft
          : Alignment.centerRight,
      padding: EdgeInsets.all(10.0),
      margin: EdgeInsets.all(10.0),
      child: Text(message.text),
    );
  }
  //show File
  Widget buildfile(Files file) {
    return Container(
      alignment: file.senderID == widget.detailPageId
          ? Alignment.centerLeft
          : Alignment.centerRight,
      padding: EdgeInsets.all(10.0),
      margin: EdgeInsets.all(10.0),
      child: Text(file.name),
    );
  }
  //Send message
  Widget buildmessage(id) {
    return ScopedModelDescendant<ChatModel>(
    builder: (context, child, model) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      height: 70.0,
      color: Colors.white,
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(FontAwesomeIcons.image),
            iconSize: 30.0,
            color: Theme.of(context).primaryColor,
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
            icon: Icon(FontAwesomeIcons.circle),
            iconSize: 30.0,
            color: Theme.of(context).accentColor,
            onPressed: () {
              if (bytes ==null) {
                if(textEditingController.text != ''){
                model.sendMessage(
                textEditingController.text, id);
                textEditingController.text = '';
                }
              }
              else {
                if (bytes != null) {
                model.filemessage(textEditingController.text, bytes, id);
                textEditingController.text = null;
                bytes = null;
                }
              }
            },
          ),
        ],
      ),
    );
    }
  );
  }
  //Conversation List
  Widget buildChatList(id) {
    return ScopedModelDescendant<ChatModel>(
      builder: (context, child, model) {  
      List<Message> messages = model.getMessagesForChatID(id);
      print(messages);
      //List<Files> files = model.getAttachForChatID(id);
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
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
    return ScopedModelDescendant<ChatModel> (
      builder: (context, child, model) {
        // RTCPeerConnection pc = _createPeerConnection();
        return FloatingActionButton(
              child: Text("Call"),
              onPressed: () { 
                model.createOffer(id, pc, "video");
                Navigator.push(context,
                MaterialPageRoute(builder: (context) => CallerScreen(),) 
                );
                // model.createAnswer(id, pc, "video");
              }
        );
      },
      );
  }

  @override
  Widget build(BuildContext context) {
    return ProviderWidget<PartnerDetailModel>(
      model: PartnerDetailModel(partnerdata, widget.detailPageId),
      onModelReady: (partnerModel){
        partnerModel.initData();
      },
    builder: (context,model, child) {
        if (model.isBusy) {
          return ViewStateBusyWidget();
        } 
        else if (model.isError ) {
          return ViewStateErrorWidget(error: model.viewStateError, onPressed: model.initData);
        }
      return Scaffold(
        floatingActionButton: buildfloat(model.partnerData.partnerId),
      appBar: //buildappbar(model.partnerData.partnerId, model.partnerData.partnerName),
      AppBar(
        title: Text(model.partnerData.partnerName),
      ),
      body: ListView(
        children: <Widget>[
          buildChatList(model.partnerData.partnerId),
          buildmessage(model.partnerData.partnerId),
        ],
      ),
      );
      }
      );
  }
}
