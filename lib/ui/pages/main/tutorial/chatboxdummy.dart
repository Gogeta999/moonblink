import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moonblink/base_widget/intro/flutter_intro.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/resources_manager.dart';
import 'package:moonblink/ui/helper/icons.dart';
import 'package:moonblink/ui/pages/main/chat/rating_page.dart';

class ChatBoxDummyPage extends StatefulWidget {
  ChatBoxDummyPage({Key key}) : super(key: key);

  @override
  _ChatBoxDummyPageState createState() => _ChatBoxDummyPageState();
}

class _ChatBoxDummyPageState extends State<ChatBoxDummyPage> {
  Intro intro;

  _ChatBoxDummyPageState() {
    intro = Intro(
      stepCount: 3,
      borderRadius: BorderRadius.circular(15),
      onfinish: () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => RatingPage(0, 0)));
      },

      /// use defaultTheme, or you can implement widgetBuilder function yourself
      widgetBuilder: StepWidgetBuilder.useDefaultTheme(
        texts: [
          "When you book with someone, these button will appear",
          "This button enable you to end booking with the player you play",
          "This button will allow you to call voice to voice with the player",
        ],
        buttonTextBuilder: (curr, total) {
          return curr < total - 1 ? 'Next' : 'Finish';
        },
      ),
    );
  }
  bool _isDark() => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    Timer(Duration(microseconds: 0), () {
      intro.start(context);
    });
  }

  @override
  void dispose() {
    Timer(Duration(microseconds: 0), () {
      intro.dispose();
    });
    super.dispose();
  }

  Widget _buildBasicMessageWidget({Widget child}) {
    return Container(
      alignment: Alignment.centerRight,
      margin: EdgeInsets.all(10.0),
      child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.6,
          ),
          // maxHeight: MediaQuery.of(context).size.height * 0.3),
          decoration: BoxDecoration(
            color: _isDark()
                ? Theme.of(context).accentColor.withOpacity(0.5)
                : Theme.of(context).accentColor,
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            border: Border.all(color: Colors.black12),
          ),
          child: child),
    );
  }

  firstActionBtn() {
    return CupertinoButton(
      key: intro.keys[1],
      child: Text(
        G.of(context).end,
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () {},
    );
  }

  secActionBtn() {
    return IconButton(
      key: intro.keys[2],
      onPressed: () {},
      icon: Icon(
        FontAwesomeIcons.phone,
        size: 20,
        color: Colors.white,
      ),
    );
  }

  bottomActionBar() {
    return Column(
      key: intro.keys[0],
      children: [
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
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey
                              : Colors.black),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.menu,
                        size: 30,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                  onPressed: () {}),
              IconButton(
                onPressed: () {},
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
                    Icons.arrow_drop_down,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
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
                          color: Theme.of(context).brightness == Brightness.dark
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
                    // controller: _chatBoxBloc.messageController,
                    decoration: InputDecoration(
                      hintText: G.of(context).labelmsg,
                      counterText: "",
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: SvgPicture.asset(
                  send,
                  color: Colors.white,
                  semanticsLabel: 'send',
                  width: 30,
                  height: 30,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  chatboxbody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ///Chat messages list
        Expanded(
          child: ListView.builder(
            physics: AlwaysScrollableScrollPhysics(),
            // controller: _scrollController,
            reverse: true,
            itemBuilder: (context, index) {
              return _buildBasicMessageWidget(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    "Hello",
                    style: TextStyle(
                        color: _isDark() ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              );
            },
            itemCount: 1,
          ),
        ),
        bottomActionBar(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // intro.dispose();
        return false;
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
          title: Row(
            children: [
              CircleAvatar(
                backgroundImage: AssetImage(
                  ImageHelper.wrapAssetsImage("MoonBlinkProfile.jpg"),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "MoonGo",
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            Row(
              key: intro.keys[0],
              children: [
                firstActionBtn(),
                secActionBtn(),
              ],
            ),
          ],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              chatboxbody(),
            ],
          ),
        ),
      ),
    );
  }
}
