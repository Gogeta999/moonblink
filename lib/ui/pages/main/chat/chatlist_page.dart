import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/appbarlogo.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/chatlist.dart';
import 'package:moonblink/models/message.dart';
import 'package:moonblink/services/chat_service.dart';
import 'package:moonblink/ui/pages/main/chat/chatbox_page.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../../../services/chat_service.dart';

String usertoken = StorageManager.sharedPreferences.getString(token);

class ChatListPage extends StatefulWidget {
  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  List<Chatlist> chatlist;
  List<Message> msg = [];
  @override
  void initState() {
    super.initState();
    if (usertoken != "token") {
      ScopedModel.of<ChatModel>(context, rebuildOnChange: false).init();
    }
  }

  //Chat Tile
  buildtile(Chatlist chat) {
    return Column(children: <Widget>[
      ListTile(
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          backgroundImage: NetworkImage(chat.profile),
        ),
        title: Text(chat.name),

        ///[Last Message]
        subtitle: Text(chat.lastmsg, maxLines: 1),
        trailing: Text(chat.updated),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatBoxPage(chat.userid)));
        },
      ),
      Divider(
        color: Colors.grey,
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: AppbarLogo()),
        body: ScopedModelDescendant<ChatModel>(
          builder: (context, child, model) {
            // chatlist.clear();
            model.receiver(msg);
            chatlist = model.conversationlist();
            print(chatlist.length);
            // return Container(child: Text("getting chat"),);
            return CustomScrollView(slivers: <Widget>[
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    Chatlist chat = chatlist[index];
                    return buildtile(chat);
                  },
                  childCount: chatlist?.length ?? 0,
                ),
              )
            ]);
          },
        ));
  }
}
