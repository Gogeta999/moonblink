import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moonblink/base_widget/appbar/appbar.dart';
import 'package:moonblink/base_widget/chat/chattile.dart';
import 'package:moonblink/bloc_pattern/chat_list/chat_list_bloc.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/resources_manager.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/models/chat_models/new_chat.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/ui/pages/main/stories/storylist.dart';
import 'package:moonblink/utils/status_bar_utils.dart';
import 'package:moonblink/view_model/story_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class NewChatListPage extends StatefulWidget {
  @override
  _NewChatListPageState createState() => _NewChatListPageState();
}

class _NewChatListPageState extends State<NewChatListPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  ChatListBloc _chatListBloc;
  RefreshController refreshController = RefreshController();

  @override
  void initState() {
    _chatListBloc = BlocProvider.of<ChatListBloc>(context);
    super.initState();
  }

  void onRefresh(StoryModel storyModel) async {
    await storyModel.fetchStory().then((value) {
      refreshController.refreshCompleted();
    }, onError: (e) => refreshController.refreshFailed()
    );
  }

  //Chat Tile
  _buildChatTile(NewChat chat) {
    return ChatTile(
      image: CachedNetworkImage(
        imageUrl: chat.profileImage,
        imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: 33,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          backgroundImage: imageProvider,
        ),
        placeholder: (context, url) => CircleAvatar(
          radius: 33,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          // backgroundImage: ,
        ),
        errorWidget: (context, url, error) => Icon(Icons.error),
      ),
      name: Text(chat.name),

      ///[Last Message]
      lastmsg: Text(chat.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing:
      Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Text(
            timeAgo.format(DateTime.parse(chat.updatedAt), allowFromNow: true)),
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
      onTap: () => Navigator.pushNamed(context, RouteName.chatBox, arguments: chat.userId)
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Colors.grey[200]
          : null,
      appBar: AppbarWidget(),
      body: BlocProvider.value(
        value: _chatListBloc,
        child: BlocBuilder<ChatListBloc, ChatListState>(
          builder: (context, state) {
            return StreamBuilder<List<NewChat>>(
                      initialData: null,
                      stream: _chatListBloc.chatsSubject,
                      builder: (context, snapshot) {
                        if (snapshot.data == null) {
                          return Center(child: CupertinoActivityIndicator());
                        }
                        if (snapshot.data.isEmpty) {
                          return AnnotatedRegion<SystemUiOverlayStyle>(
                              value: StatusBarUtils.systemUiOverlayStyle(context),
                              child: SmartRefresher(
                                controller: refreshController,
                                header: WaterDropHeader(),
                                onRefresh: () {
                                  refreshController.refreshCompleted();
                                },
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
                                ),
                              ));
                        }
                        return ProviderWidget<StoryModel>(
                          model: StoryModel(),
                          onModelReady: (model) {
                            model.fetchStory();
                          },
                          builder: (context, storyModel, child) {
                            return SmartRefresher(
                              controller: refreshController,
                              header: WaterDropHeader(),
                              onRefresh: () {
                                onRefresh(storyModel);
                              },
                              child: CustomScrollView(slivers: <Widget>[
                                if (storyModel.stories.isNotEmpty)
                                  StoryList(
                                    stories: storyModel.stories,
                                  ),
                                SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                          (context, index) {
                                        NewChat chat = snapshot.data[index];
                                        return _buildChatTile(chat);
                                      },
                                      childCount: snapshot.data.length
                                  ),
                                )
                              ]),
                            );
                          },
                        );
                      }
                    );
          },
        ),
      ),
    );
  }
}

/* return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Colors.grey[200]
          : null,
      appBar: AppbarWidget(),
      body: ScopedModelDescendant<ChatModel>(
        builder: (context, child, model) {
          model.connection();
          chatlist = model.conversationlist();
          if (chatlist.isEmpty) {
            return AnnotatedRegion<SystemUiOverlayStyle>(
                value: StatusBarUtils.systemUiOverlayStyle(context),
                child: SmartRefresher(
                  controller: refreshController,
                  header: WaterDropHeader(),
                  onRefresh: () {
                    model.init();
                    chatlist = model.conversationlist();
                    refreshController.refreshCompleted();
                  },
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
                  ),
                ));
          } else {
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
                    model.init();
                    chatlist = model.conversationlist();
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
    );*/