import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/appbarlogo.dart';
import 'package:moonblink/models/chatlist.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/services/chat_service.dart';
import 'package:moonblink/ui/pages/main/chat/chatbox_page.dart';
import 'package:moonblink/view_model/conversation_model.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';
class ChatListPage extends StatefulWidget {
  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  // list() {
  //   List<Chatlist> users = [];
  //   users.addAll(users);
  //   users.forEach((user) {
  //   items.add(
  //     Column(
  //       children: <Widget>[ 
  //         ListTile(
  //           leading: CircleAvatar(
  //             backgroundImage: NetworkImage(user.profile),
  //           ),
  //           title: Text(user.name),
  //           ///[Last Message]
  //           //subtitle: Text(user.contactUserProfile),
  //           onTap: () {
  //             Navigator.push(
  //               context, MaterialPageRoute(builder: (context) => ChatBoxPage(user.id)));
  //           },         
  //         ),
  //         Divider(color: Colors.grey,)
  //         ]
  //         )
  //     );   
  //     }
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: AppbarLogo()),
      body: ProviderWidget<ConversationModel> (
        model: ConversationModel(),
        onModelReady: (model) => model.initData(),
        builder: (context,model,child) {
          print(model.list.length);
          return CustomScrollView(
            slivers: <Widget> [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                (context, index){
                  Chatlist chat = model.list[index];
                    return Column(
                      children: <Widget>[ 
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                          backgroundImage: NetworkImage(chat.profile),
                        ),
                        title: Text(chat.name),
                        ///[Last Message]
                        subtitle: Text(chat.lastmsg),
                        onTap: () {
                          Navigator.push(
                            context, MaterialPageRoute(builder: (context) => ChatBoxPage(chat.userid)));
                          },         
                        ),
                        Divider(color: Colors.grey,)
                      ]
                    );
                  },
                childCount: model.list?.length ?? 0,
                ),
              )
            ]
          ); 
        },
      )
    );
  }
}
