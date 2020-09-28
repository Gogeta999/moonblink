import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moonblink/base_widget/appbar/appbar.dart';
import 'package:moonblink/base_widget/chat/chattile.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/resources_manager.dart';
import 'package:moonblink/models/chatlist.dart';
import 'package:moonblink/models/message.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/services/chat_service.dart';
import 'package:moonblink/ui/pages/main/chat/chatbox_page.dart';
import 'package:moonblink/ui/pages/main/stories/storylist.dart';
import 'package:moonblink/utils/status_bar_utils.dart';
import 'package:moonblink/view_model/story_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:scoped_model/scoped_model.dart';
import '../../../../services/chat_service.dart';
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
  RefreshController refreshController = RefreshController();
  // @override
  // void initState() {
  //   super.initState();
  //   ScopedModel.of<ChatModel>(context).connection();
  // }
  String finalmsg(String lastmsg) {
    if (lastmsg.length > 15) {
      return lastmsg.substring(0, 15) + '...';
    } else {
      return lastmsg;
    }
  }

  void onRefresh(StoryModel storyModel) async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    storyModel.fetchStory();
    refreshController.refreshCompleted();
  }

  //Chat Tile
  buildtile(Chatlist chat) {
    String msg = finalmsg(chat.lastmsg);
    return Column(children: <Widget>[
      ChatTile(
        image: CachedNetworkImage(
          imageUrl: chat.profile,
          imageBuilder: (context, imageProvider) => CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            backgroundImage: imageProvider,
          ),
          placeholder: (context, url) => CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            // backgroundImage: ,
          ),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
        name: Text(chat.name),

        ///[Last Message]
        lastmsg: Text(msg, maxLines: 1),
        trailing:
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Text(
              timeAgo.format(DateTime.parse(chat.updated), allowFromNow: true)),
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
      // Divider(
      //   color: Colors.grey,
      // )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppbarWidget(),
      body: ScopedModelDescendant<ChatModel>(
        builder: (context, child, model) {
          model.connection();
          chatlist = model.conversationlist();
          if (chatlist.isEmpty) {
            return AnnotatedRegion<SystemUiOverlayStyle>(
                value: StatusBarUtils.systemUiOverlayStyle(context),
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(
                            ImageHelper.wrapAssetsImage('noFollowing.jpg'),
                          ),
                          fit: BoxFit.cover)),
                  width: double.infinity,
                  height: double.infinity,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: 200,
                        child: Text(
                          G.of(context).noChatHistory,
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                ));
          } else {
            print(
                "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
            print(chatlist.length);

            return ProviderWidget<StoryModel>(
              model: StoryModel(),
              onModelReady: (model) {
                model.fetchStory();
              },
              builder: (context, storymodel, child) {
                // print(storymodel.stories);
                return SmartRefresher(
                  controller: refreshController,
                  header: WaterDropHeader(),
                  onRefresh: () {
                    onRefresh(storymodel);
                  },
                  child: CustomScrollView(slivers: <Widget>[
                    if (storymodel.stories.isNotEmpty)
                      StoryList(
                        stories: storymodel.stories,
                      ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          Chatlist chat = chatlist[index];
                          return buildtile(chat);
                        },
                        childCount: chatlist?.length ?? 0,
                      ),
                    )
                  ]),
                );
              },
            );
          }
        },
      ),
    );
  }
}
