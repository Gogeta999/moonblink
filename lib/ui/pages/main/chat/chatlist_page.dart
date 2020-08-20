import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/appbarlogo.dart';
import 'package:moonblink/models/chatlist.dart';
import 'package:moonblink/models/message.dart';
import 'package:moonblink/services/chat_service.dart';
import 'package:moonblink/ui/pages/main/chat/chatbox_page.dart';
import 'package:scoped_model/scoped_model.dart';
import '../../../../services/chat_service.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:oktoast/oktoast.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class ChatListPage extends StatefulWidget {
  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<Chatlist> chatlist = [];
  List<Message> msg = [];

  //Chat Tile
  buildtile(Chatlist chat) {
    return Column(children: <Widget>[
      ListTile(
        leading: CachedNetworkImage(
          imageUrl: chat.profile,
          imageBuilder: (context, imageProvider) => CircleAvatar(
            radius: 28,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            backgroundImage: imageProvider,
          ),
        ),
        title: Text(chat.name),

        ///[Last Message]
        subtitle: Text(chat.lastmsg, maxLines: 1),
        trailing:
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Text(timeAgo.format(DateTime.parse(chat.updated), allowFromNow: true)),
          if (chat.unread != 0)
            CircleAvatar(
              radius: 10,
              backgroundColor: Theme.of(context).accentColor,
              child: Text(
                chat.unread.toString(),
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            )
        ]),
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
    super.build(context);
    return Scaffold(
        appBar: AppBar(title: AppbarLogo()),
        body: ScopedModelDescendant<ChatModel>(
          builder: (context, child, model) {
            chatlist = model.conversationlist();
            print(chatlist.length);

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
