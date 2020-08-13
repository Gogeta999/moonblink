import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:moonblink/base_widget/imageview.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moonblink/base_widget/photo_bottom_sheet.dart';
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
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

import '../../../../models/message.dart';
import '../../../../services/chat_service.dart';

class ChatBoxPage extends StatefulWidget {
  ChatBoxPage(this.detailPageId);
  final int detailPageId;
  @override
  _ChatBoxPageState createState() => _ChatBoxPageState();
}

class _ChatBoxPageState extends State<ChatBoxPage> {
  //for Rating
  bool got = false;
  bool imagepick = false;
  TextEditingController comment = TextEditingController();
  PartnerUser partnerdata;
  int type = 1;
  Uint8List bytes;
  List<Message> messages = [];
  List<Contact> contacts = [];
  List<Chatlist> chatlist = [];
  List<Contact> users = [];
  // Chatlist user = Chatlist();
  Bookingstatus bookingdata;
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
  String _filePath;
  // 2. compress file and get file.
  Future<File> _compressAndGetFile(File file, String targetPath) async {
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 80,
    );

    print(file.lengthSync());
    print(result.lengthSync());

    return result;
  }

  //File formatting
  Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    _filePath =
        '$path/' + DateTime.now().millisecondsSinceEpoch.toString() + '.jpeg';
    return File(_filePath);
  }

  Future getImage() async {
    // PickedFile pickedFile = await picker.getImage(
    //     source: ImageSource.gallery, maxWidth: 300, maxHeight: 600);
    // _file = File(pickedFile.path);
    File temporaryImage = await _getLocalFile();
    File _compressedImage =
        await _compressAndGetFile(_file, temporaryImage.absolute.path);
    setState(() {
      _file = _compressedImage;
      filename = selfId.toString() + now + ".png";
      bytes = _file.readAsBytesSync();
      //preview = true;
      print(bytes);
    });
  }

  @override
  void initState() {
    super.initState();
    got = false;
    ScopedModel.of<ChatModel>(context).chatupdating(widget.detailPageId);
    // setState(() {
    bookingdata = ScopedModel.of<ChatModel>(context).chatupdated();
    // });

    // Future.delayed(Duration.zero, () => rating(1));
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
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.4,
      ),
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Theme.of(context).accentColor,
        borderRadius: BorderRadius.all(
          Radius.circular(15.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SelectableText(
            msg.text,
            autofocus: true,
            cursorRadius: Radius.circular(50),
            cursorColor: Colors.white,
            toolbarOptions: ToolbarOptions(copy: true, selectAll: true),
          ),
          // noramlUserCancel(msg, bookingid),
          partneronly(msg, bookingid)
        ],
      ),
    );
  }

  //Partner Only
  partneronly(msg, bookingid) {
    if (msg.senderID == widget.detailPageId) {
      return Row(
        mainAxisSize: MainAxisSize.min,
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
      child: FlatButton(
        child: Text(S.of(context).accept,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        onPressed: () {
          MoonBlinkRepository.bookingAcceptOrDecline(
              selfId, bookingid, bookingAccept);
          msg.type = 0;
        },
      ),
    );
  }

  //reject button
  rejectbtn(bookingid, msg) {
    return ButtonTheme(
        minWidth: 70,
        child: FlatButton(
          child: Text(S.of(context).reject,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          onPressed: () {
            MoonBlinkRepository.bookingAcceptOrDecline(
                selfId, bookingid, bookingReject);
            msg.type = 0;
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
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.4,
      ),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).accentColor,
        borderRadius: BorderRadius.all(
          Radius.circular(15.0),
        ),
      ),
      child: SelectableText(
        msg.text,
        autofocus: true,
        cursorRadius: Radius.circular(50),
        cursorColor: Colors.white,
        toolbarOptions: ToolbarOptions(copy: true, selectAll: true),
      ),
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
      height: MediaQuery.of(context).size.height * 0.1,
      //color: Theme.of(context).backgroundColor,
      child: Row(
        children: <Widget>[
          //Image select button
          IconButton(
            icon: Icon(FontAwesomeIcons.image),
            iconSize: 30.0,
            color: Theme.of(context).accentColor,
            onPressed: () {
              //getImage();
              CustomBottomSheet.show(
                  popAfterBtnPressed: true,
                  requestType: RequestType.image,
                  buttonText: 'Send',
                  buildContext: context,
                  limit: 1,
                  body: 'Select image',
                  onPressed: (File file) async {
                    setState(() {
                      _file = file;
                    });

                    await getImage();
                    model.sendfile(filename, bytes, id, type, messages);
                    setState(() {
                      textEditingController.text = '';
                      bytes = null;
                    });
                  },
                  onInit: _sendMessageWidgetUp,
                  onDismiss: _sendMessageWidgetDown);
            },
          ),
          //Voice record
          Voicemsg(
            onInit: _sendMessageWidgetUp,
            id: id,
            messages: messages,
            onDismiss: _sendMessageWidgetDown,
          ),
          SizedBox(width: 10),
          //Text Input
          Expanded(
            child: TextField(
              minLines: 1,
              maxLines: 5,
              maxLength: 150,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.newline,
              controller: textEditingController,
              decoration: InputDecoration(
                hintText: 'Input message',
                counterText: "",
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
                bytes = null;
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

  bookingcancel(bookingid, bookinguserid) {
    if (selfId == bookinguserid) {
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
      return Container();
    }
  }

  //action 1
  action1(model) {
    bookingdata = model.chatupdated();
    print("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
    if (bookingdata == null) {
      return ViewStateBusyWidget();
    }

    switch (bookingdata.status) {
      //normal
      case (-1):
        return Container();
        break;
      //cancel booking
      case (0):
        return bookingcancel(bookingdata.bookingid, bookingdata.bookinguserid);
        break;
      //in booking
      case (1):
        return callbtn(widget.detailPageId);
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
  action2(model) {
    bookingdata = model.chatupdated();
    print("BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB");
    if (bookingdata == null) {
      return ViewStateBusyWidget();
    }
    if (selfId != bookingdata.bookinguserid) {
      switch (bookingdata.status) {
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
          return endbtn(bookingdata.bookingid);
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
  Widget buildChatList(id, model) {
    model.receiver(messages);
    bookingdata = model.chatupdated();
    print("CCCCCCCCCCCCCCCCCCCCCCCCCCCCC");
    if (bookingdata == null) {
      return ViewStateBusyWidget();
    }
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      child: ListView.builder(
        reverse: true,
        itemCount: messages.length,
        itemBuilder: (BuildContext context, int index) {
          return buildSingleMessage(
              bookingdata.status, bookingdata.bookingid, messages[index]);
        },
      ),
    );
  }

  bool isShowing = false;
  final controller = ScrollController();
  @override
  Widget build(BuildContext context) {
    print("User Id is ${selfId.toString()}");
    print("++++++++++++++++++++++++++++++++++++++");
    // if (bookingdata == null) {
    //   return ViewStateBusyWidget();
    // }
    // if (bookingdata.status == 3) {
    //   Future.delayed(Duration.zero, () => rating(bookingdata.bookingid));
    // }
    return ScopedModelDescendant<ChatModel>(builder: (context, child, model) {
      // bookingdata = model.chatupdated();
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
            return Scaffold(
              appBar: AppBar(
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
                  action2(model),
                  action1(model),
                ],
              ),
              body: ListView(
                controller: controller,
                addAutomaticKeepAlives: true,
                children: <Widget>[
                  buildChatList(partnermodel.partnerData.partnerId, model),
                  buildmessage(partnermodel.partnerData.partnerId, model),
                  if (isShowing && Platform.isAndroid)
                  SizedBox(height: MediaQuery.of(context).size.height * 0.5),
                  if(isShowing && Platform.isIOS)
                  SizedBox(height: MediaQuery.of(context).size.height * 0.45)
                ],
              ),
            );
          });
    });
  }

  _sendMessageWidgetUp() {
    setState((){
      isShowing = true;
      controller.animateTo(MediaQuery.of(context).size.height * 0.4, duration: Duration(milliseconds: 300), curve: Curves.ease);
    });
  }

  _sendMessageWidgetDown() {
    setState((){
      isShowing = false;
      controller.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.ease);
    });
  }

  ///[CallFunction]
  ///Here is for voicCall
  Future<void> joinChannel(voiceChannelName) async {
    if (voiceChannelName.isNotEmpty) {
      await _handleVoiceCall(voiceChannelName);
    } else if (voiceChannelName.isEmpty) {
      showToast('Developer error,Contact us on Facebook');
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
