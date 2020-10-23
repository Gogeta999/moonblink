import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moonblink/base_widget/chat/bookingtimeleft.dart';
import 'package:moonblink/base_widget/chat/floatingbutton.dart';
import 'package:moonblink/base_widget/chat/waitingtimeleft.dart';
import 'package:moonblink/base_widget/customDialog_widget.dart';
import 'package:moonblink/base_widget/imageview.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moonblink/base_widget/custom_bottom_sheet.dart';
import 'package:moonblink/base_widget/player.dart';
import 'package:moonblink/base_widget/recorder.dart';
import 'package:moonblink/base_widget/video_player_widget.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/message.dart';
import 'package:moonblink/models/partner.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/provider/view_state_error_widget.dart';
import 'package:moonblink/services/chat_service.dart';
import 'package:moonblink/services/moonblink_repository.dart';
import 'package:moonblink/ui/helper/icons.dart';
import 'package:moonblink/ui/pages/call/voice_call_page.dart';
import 'package:moonblink/ui/pages/main/chat/rating_page.dart';
import 'package:moonblink/utils/constants.dart';
import 'package:moonblink/view_model/call_model.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:moonblink/view_model/message_model.dart';
import 'package:moonblink/view_model/partner_detail_model.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../../../models/message.dart';
import '../../../../services/chat_service.dart';

class ChatBoxPage extends StatefulWidget {
  ChatBoxPage(this.detailPageId);
  final int detailPageId;
  @override
  _ChatBoxPageState createState() => _ChatBoxPageState();
}

class _ChatBoxPageState extends State<ChatBoxPage>
    with TickerProviderStateMixin {
  //animation
  bool _isRotated = true;
  AnimationController _controller;
  Animation<double> _animation;
  Animation<double> _animation2;
  Animation<double> _animation3;
  //camera
  final _picker = ImagePicker();
  //Message
  bool got = false;
  //Rating
  bool rated = false;
  //Messaging

  File _file;

  Uint8List bytes;
  final TextEditingController textEditingController = TextEditingController();
  String _filePath;
  List<Message> messages = [];
  //Status
  Bookingstatus bookingdata;
  //Booking
  int bookingAccept = 1;
  int bookingReject = 2;
  //Userdata
  PartnerUser partnerdata;
  final usertype = StorageManager.sharedPreferences.getInt(mUserType);
  final selfId = StorageManager.sharedPreferences.getInt(mUserId);
  //bottom box
  bool isShowing = false;
  final controller = ScrollController();
  //compress file and get file.
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

  //Short Title
  String titlename(String title) {
    if (title.length > 10) {
      return title.substring(0, 9) + '...';
    } else {
      return title;
    }
  }

  //File formatting
  Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    _filePath =
        '$path/' + DateTime.now().millisecondsSinceEpoch.toString() + '.jpeg';
    return File(_filePath);
  }

  //Image formatting
  Future getImage() async {
    File temporaryImage = await _getLocalFile();
    File _compressedImage =
        await _compressAndGetFile(_file, temporaryImage.absolute.path);
    setState(() {
      _file = _compressedImage;
      bytes = _file.readAsBytesSync();
      print(bytes);
    });
  }

  //take photo
  _takePhoto(ChatModel model) async {
    PickedFile pickedFile = await _picker.getImage(source: ImageSource.camera);
    File image = File(pickedFile.path);
    File temporaryImage = await _getLocalFile();
    File compressedImage =
        await _compressAndGetFile(image, temporaryImage.absolute.path);
    if (compressedImage != null) {
      setState(() {
        _file = compressedImage;
        bytes = _file.readAsBytesSync();
        String now = DateTime.now().toString();
        String filename = selfId.toString() + now + ".png";
        model.sendfile(filename, bytes, widget.detailPageId, 1, messages);
        bytes = null;
        textEditingController.text = '';
      });
    }
  }

  ///[Icon Change]
  void rotate() {
    setState(() {
      if (_isRotated) {
        _isRotated = false;
        _controller.forward();
      } else {
        _isRotated = true;
        _controller.reverse();
      }
    });
  }

  @override
  void initState() {
    super.initState();

    ///[Animation]
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    _animation = new CurvedAnimation(
      parent: _controller,
      curve: new Interval(0.0, 1.0, curve: Curves.linear),
    );

    _animation2 = new CurvedAnimation(
      parent: _controller,
      curve: new Interval(0.5, 1.0, curve: Curves.linear),
    );

    _animation3 = new CurvedAnimation(
      parent: _controller,
      curve: new Interval(0.8, 1.0, curve: Curves.linear),
    );
    _controller.reverse();

    ///[Chat Data]
    StorageManager.sharedPreferences.setBool(isUserAtChatBox, true);
    print(
        'isUserAtChatBox --- ${StorageManager.sharedPreferences.get(isUserAtChatBox)}');
    got = false;
    ScopedModel.of<ChatModel>(context).clear();
    ScopedModel.of<ChatModel>(context).chatupdated();
    ScopedModel.of<ChatModel>(context).chatupdating(widget.detailPageId);
  }

  @override
  void dispose() {
    StorageManager.sharedPreferences.setBool(isUserAtChatBox, false);
    print(
        'isUserAtChatBox --- ${StorageManager.sharedPreferences.get(isUserAtChatBox)}');
    super.dispose();
  }

  //build messages
  Widget buildSingleMessage(int status, int bookingid, Message message) {
    return Container(
        alignment: message.senderID == widget.detailPageId
            ? Alignment.centerLeft
            : Alignment.centerRight,
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
        return Text(G.of(context).error);
        break;
    }
  }

  //build request
  buildrequest(msg, bookingid) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.5,
      ),
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        // color: Theme.of(context).brightness == Brightness.dark
        //     ? Theme.of(context).accentColor
        //     : Colors.grey,
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
            style: TextStyle(color: Colors.white),
            autofocus: true,
            cursorRadius: Radius.circular(50),
            cursorColor: Colors.white,
            toolbarOptions: ToolbarOptions(copy: true, selectAll: true),
          ),
          partneronly(msg, bookingid)
        ],
      ),
    );
  }

  //Request Button
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

  //booking End Dialog
  void bookingenddialog(model, Bookingstatus booking) {
    showDialog(
        context: context,
        builder: (_) {
          return CustomDialog(
            title: G.of(context).bookingEnded,
            row1Content: G.of(context).timeleft,
            row2Content: BookingTimeLeft(
              count: booking.count,
              upadateat: booking.updated,
              timeleft: bookingdata.section,
            ),
            cancelColor: Theme.of(context).accentColor,
            confirmButtonColor: Theme.of(context).accentColor,
            confirmContent: G.of(context).end,
            confirmCallback: () {
              model.endbooking(selfId, booking.bookingid, 3);
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      RatingPage(bookingdata.bookingid, widget.detailPageId),
                ),
              );
            },
          );
        }
        // builder: (_) => AlertDialog(
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.all(
        //       Radius.circular(15.0),
        //     ),
        //   ),
        //   // title: Text(partnerModel.gameprofile[index].gameName),
        //   contentPadding: EdgeInsets.zero,
        //   content: Column(
        //     crossAxisAlignment: CrossAxisAlignment.stretch,
        //     mainAxisSize: MainAxisSize.min,
        //     children: [
        //       Container(
        //         width: MediaQuery.of(context).size.width,
        //         padding: EdgeInsets.symmetric(vertical: 20),
        //         child: Center(
        //           child: Text("End Booking"),
        //         ),
        //       ),
        //       Container(
        //         width: MediaQuery.of(context).size.width,
        //         child: Center(
        //           child: Text("Time Left"),
        //         ),
        //       ),
        //       SizedBox(
        //         height: 10,
        //       ),
        //       Container(
        //         width: MediaQuery.of(context).size.width,
        //         child: Center(
        //           child: BookingTimeLeft(
        //             upadateat: booking.updated,
        //             timeleft: bookingdata.section,
        //           ),
        //         ),
        //       ),
        //       SizedBox(
        //         height: 20,
        //       ),
        //       Row(
        //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //         children: [
        //           InkWell(
        //             onTap: () => Navigator.pop(context),
        //             child: Container(
        //               width: MediaQuery.of(context).size.width / 2.5,
        //               padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
        //               decoration: BoxDecoration(
        //                 color: Theme.of(context).accentColor,
        //                 borderRadius: BorderRadius.only(
        //                   bottomLeft: Radius.circular(15.0),
        //                   // bottomRight: Radius.circular(15.0),
        //                 ),
        //               ),
        //               child: Text(
        //                 "Cancel",
        //                 style: TextStyle(color: Colors.white),
        //                 textAlign: TextAlign.center,
        //               ),
        //             ),
        //           ),
        //           InkWell(
        //             onTap: () {
        //               model.endbooking(selfId, booking.bookingid, 3);
        //               Navigator.pop(context);
        //             },
        //             child: Container(
        //               width: MediaQuery.of(context).size.width / 2.5,
        //               padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
        //               decoration: BoxDecoration(
        //                 color: Theme.of(context).accentColor,
        //                 borderRadius: BorderRadius.only(
        //                   // bottomLeft: Radius.circular(15.0),
        //                   bottomRight: Radius.circular(15.0),
        //                 ),
        //               ),
        //               child: Text(
        //                 "End",
        //                 style: TextStyle(color: Colors.white),
        //                 textAlign: TextAlign.center,
        //               ),
        //             ),
        //           ),
        //         ],
        //       ),
        //     ],
        //   ),
        // ),
        );
  }

  // //Rating Box
  // void rating(bookingid) {
  //   var rate = 5.0;
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return ProviderWidget<RateModel>(
  //         model: RateModel(),
  //         builder: (context, model, child) {
  //           return new AlertDialog(
  //             title: Text(G.of(context).pleaseRatingForThisGame),
  //             shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(20.0)),
  //             content: Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               mainAxisSize: MainAxisSize.min,
  //               children: <Widget>[
  //                 SmoothStarRating(
  //                   starCount: 5,
  //                   rating: rate,
  //                   color: Theme.of(context).accentColor,
  //                   isReadOnly: false,
  //                   size: 30,
  //                   filledIconData: Icons.star,
  //                   halfFilledIconData: Icons.star_half,
  //                   defaultIconData: Icons.star_border,
  //                   allowHalfRating: true,
  //                   spacing: 2.0,
  //                   //star value
  //                   onRated: (value) {
  //                     print("rating value -> $value");
  //                     setState(() {
  //                       rate = value;
  //                     });
  //                   },
  //                 ),
  //                 SizedBox(
  //                   height: 30,
  //                 ),
  //                 //Comment for Rating
  //                 Container(
  //                   margin: EdgeInsets.fromLTRB(0, 1.5, 0, 1.5),
  //                   padding: EdgeInsets.all(8.0),
  //                   decoration: BoxDecoration(
  //                     border: Border.all(width: 1.5, color: Colors.grey),
  //                     borderRadius: BorderRadius.all(Radius.circular(12.0)),
  //                   ),
  //                   child: TextField(
  //                     controller: comment,
  //                     textInputAction: TextInputAction.done,
  //                     decoration: InputDecoration(
  //                       labelText: G.of(context).labelcomment,
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             //Summit Rating
  //             actions: [
  //               FlatButton(
  //                   child: Text(G.of(context).submit),
  //                   onPressed: () {
  //                     model
  //                         .rate(widget.detailPageId, bookingid, rate,
  //                             comment.text)
  //                         .then((value) => value
  //                             ? Navigator.pop(context)
  //                             : showToast(G.of(context).toastratingfail));
  //                   })
  //             ],
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  //accept button
  acceptbtn(bookingid, msg) {
    return ButtonTheme(
      minWidth: 70,
      child: FlatButton(
        child: Text(G.of(context).accept,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 17)),
        onPressed: () {
          MoonBlinkRepository.bookingAcceptOrDecline(
              selfId, bookingid, bookingAccept);
          // msg.type = 0;
        },
      ),
    );
  }

  //reject button
  rejectbtn(bookingid, msg) {
    return ButtonTheme(
        minWidth: 70,
        child: FlatButton(
          child: Text(G.of(context).reject,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17)),
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
          Text(
            G.of(context).someoneCallingYou,
            style: TextStyle(color: Colors.white),
          ),
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
          G.of(context).enterCall,
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
        ),
        onPressed: () {
          joinChannel(msg.attach);
        },
      );
    } else {
      return Text(G.of(context).bookingEnded,
          style: TextStyle(fontWeight: FontWeight.bold));
    }
  }

  //build msg template
  buildmsg(Message msg) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.46,
      ),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        // color: Theme.of(context).brightness == Brightness.dark
        //     ? Theme.of(context).accentColor
        //     // ? Theme.of(context).scaffoldBackgroundColor
        //     : Theme.of(context).accentColor,
        color: Theme.of(context).accentColor,
        borderRadius: BorderRadius.all(
          Radius.circular(15.0),
        ),
      ),
      child: SelectableText(
        msg.text,
        style: TextStyle(color: Colors.white),
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
      padding: EdgeInsets.all(2),
      decoration: BoxDecoration(
        // color: Theme.of(context).brightness == Brightness.dark
        //     ? Theme.of(context).accentColor
        //     // ? Theme.of(context).scaffoldBackgroundColor
        //     : Colors.grey,
        color: Theme.of(context).accentColor,
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: BoxConstraints(
          // minHeight: MediaQuery.of(context).size.height / 8,
          maxHeight: MediaQuery.of(context).size.height / 3,
          // minWidth: MediaQuery.of(context).size.width / 8,
          maxWidth: MediaQuery.of(context).size.width / 2),
      child: GestureDetector(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.memory(
            file,
          ),
        ),
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
    print("audio File path is ${msg.attach}");
    return LocalPlayerWidget(path: msg.attach);
  }

  //build image
  buildimage(Message msg) {
    return Container(
      padding: EdgeInsets.all(2),
      decoration: BoxDecoration(
        // color: Theme.of(context).brightness == Brightness.dark
        //     ? Theme.of(context).accentColor
        //     // ? Theme.of(context).scaffoldBackgroundColor
        //     : Colors.grey,
        color: Theme.of(context).accentColor,
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: BoxConstraints(
          // minHeight: MediaQuery.of(context).size.height / 8,
          maxHeight: MediaQuery.of(context).size.height / 3,
          // minWidth: MediaQuery.of(context).size.width / 8,
          maxWidth: MediaQuery.of(context).size.width / 2),
      // height: 100,
      // width: 100,
      child: GestureDetector(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            msg.attach,
            loadingBuilder: (context, child, progress) {
              return progress == null
                  ? child
                  : Padding(
                      padding: EdgeInsets.all(8),
                      child: Text("Downloading Image"),
                    );
            },
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImageView(msg.attach),
            ),
          );
        },
      ),
    );
  }

  //build audio player
  buildaudio(Message msg) {
    return PlayerWidget(url: msg.attach);
  }

  //image pick
  Widget imagepick(model, id) {
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
        rotate();
        CustomBottomSheet.show(
            popAfterBtnPressed: true,
            requestType: RequestType.image,
            buttonText: G.of(context).sendbutton,
            buildContext: context,
            limit: 1,
            body: G.of(context).labelimageselect,
            onPressed: (File file) async {
              setState(() {
                _file = file;
              });

              await getImage();
              String now = DateTime.now().toString();
              String filename = selfId.toString() + now + ".png";
              model.sendfile(filename, bytes, id, 1, messages);
              setState(() {
                textEditingController.text = '';
                bytes = null;
              });
            },
            onInit: _sendMessageWidgetUp,
            onDismiss: _sendMessageWidgetDown,
            willCrop: false,
            compressQuality: NORMAL_COMPRESS_QUALITY);
      },
    );
  }

  //voice msg
  Widget voicemsg(id) {
    return Voicemsg(
      onInit: _sendMessageWidgetUp,
      id: id,
      messages: messages,
      onDismiss: _sendMessageWidgetDown,
      rotate: () => rotate(),
    );
  }

  //send Button
  Widget sendbtn(model, id) {
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
      onPressed: () {
        if (bytes == null) {
          if (textEditingController.text != '') {
            model.sendMessage(textEditingController.text, id, messages);
            textEditingController.text = '';
          }
        } else {
          // model.sendfile(filename, bytes, id, 1, messages);
          // textEditingController.text = '';
          bytes = null;
        }
      },
    );
  }

  //Send message
  Widget buildmessage(id, model) {
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
  }

  //Booking End button
  Widget endbtn(booking) {
    return ProviderWidget(
      model: CallModel(),
      builder: (context, model, child) {
        return FlatButton(
          child: Text(
            G.of(context).end,
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            bookingenddialog(model, booking);
          },
        );
      },
    );
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
              color: Colors.white,
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

  // Booking Cancel
  bookingcancel(bookingid, bookinguserid) {
    if (selfId == bookinguserid) {
      return ProviderWidget(
          model: CallModel(),
          builder: (context, model, child) {
            return FlatButton(
              child: Text(
                G.of(context).cancel,
                style: TextStyle(color: Colors.white),
              ),
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
        return bookingcancel(
          bookingdata.bookingid,
          bookingdata.bookinguserid,
        );
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
    if (bookingdata == null) {
      return ViewStateBusyWidget();
    }
    if (selfId == bookingdata.bookinguserid) {
      switch (bookingdata.status) {
        //normal
        case (-1):
          return Container();
          break;
        //pending
        case (0):
          return WaitingTimeLeft(
            createat: bookingdata.created,
          );
          break;
        //end booking
        case (1):
          return endbtn(bookingdata);
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
    } else {
      return Container();
    }
  }

  //Chat List
  Widget buildChatList(id, ChatModel model) {
    model.receiver(messages, widget.detailPageId);
    bookingdata = model.chatupdated();
    if (bookingdata == null) {
      return ViewStateBusyWidget();
    }
    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
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

  //Widget build
  @override
  Widget build(BuildContext context) {
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
        if (bookingdata != null) {
          if (bookingdata.status == 3 && rated == false) {
            rated = true;
            Future.delayed(
              Duration.zero,
              () => RatingPage(bookingdata.bookingid, widget.detailPageId),
            );
          }
        }
        return ScopedModelDescendant<ChatModel>(
          builder: (context, child, model) {
            String name = titlename(partnermodel.partnerData.partnerName);
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
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    // ? Colors.grey
                    ? Colors.black
                    : Colors.black,
                title: GestureDetector(
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(partnermodel
                              .partnerData.prfoileFromPartner.profileImage),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Container(
                            width: MediaQuery.of(context).size.width / 3,
                            child: Text(
                              name,
                            ),
                          ),
                        ),
                      ],
                    ),
                    onTap: partnermodel.partnerData.type != 0
                        ? () {
                            Navigator.pushReplacementNamed(
                                    context, RouteName.partnerDetail,
                                    arguments: widget.detailPageId)
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
                  action2(model),
                  action1(model),
                ],
              ),
              body: Stack(
                children: [
                  ListView(
                    controller: controller,
                    addAutomaticKeepAlives: true,
                    children: <Widget>[
                      //chat list
                      buildChatList(partnermodel.partnerData.partnerId, model),
                      //Message input box
                      buildmessage(partnermodel.partnerData.partnerId, model),
                      //Bottom Box
                      if (isShowing && Platform.isAndroid)
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5),
                      if (isShowing && Platform.isIOS)
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.45)
                    ],
                  ),
                  FloatingButton(
                    bottom: 80,
                    left: 10,
                    scale: _animation,
                    child: imagepick(model, widget.detailPageId),
                  ),
                  FloatingButton(
                    bottom: 140,
                    left: 30,
                    scale: _animation2,
                    child: voicemsg(widget.detailPageId),
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
                      onPressed: () {
                        _takePhoto(model);
                        rotate();
                      },
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  //bottom widget up
  _sendMessageWidgetUp() {
    setState(() {
      isShowing = true;
      controller.animateTo(MediaQuery.of(context).size.height * 0.4,
          duration: Duration(milliseconds: 300), curve: Curves.ease);
    });
  }

  //bottom widget down
  _sendMessageWidgetDown() {
    setState(() {
      isShowing = false;
      controller.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.ease);
    });
  }

  ///[CallFunction]
  ///Here is for voiceCall
  Future<void> joinChannel(voiceChannelName) async {
    if (voiceChannelName.isNotEmpty) {
      await _handleVoiceCall(voiceChannelName);
    } else if (voiceChannelName.isEmpty) {
      showToast(G.of(context).toasterror);
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
}
