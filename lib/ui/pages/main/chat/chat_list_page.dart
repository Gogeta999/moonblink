import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moonblink/base_widget/appbar/appbar.dart';
import 'package:moonblink/base_widget/chat/chattile.dart';
import 'package:moonblink/bloc_pattern/chat_list/chat_list_bloc.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/models/chat_models/new_chat.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/ui/pages/main/stories/storylist.dart';
import 'package:moonblink/view_model/story_model.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class NewChatListPage extends StatefulWidget {
  @override
  _NewChatListPageState createState() => _NewChatListPageState();
}

class _NewChatListPageState extends State<NewChatListPage> {

  // ignore: close_sinks
  ChatListBloc _chatListBloc;
  final _storyModel = StoryModel();
  //RefreshController refreshController = RefreshController();

  @override
  void initState() {
    _chatListBloc = BlocProvider.of<ChatListBloc>(context);
    super.initState();
  }

  @override
  void dispose() {
    _storyModel?.dispose();
    super.dispose();
  }

  void onRefresh(StoryModel storyModel) async {
    // await storyModel.fetchStory().then((value) {
    //   refreshController.refreshCompleted();
    // }, onError: (e) => refreshController.refreshFailed());
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
        name: Text(
          chat.name,
          style: TextStyle(
              color: chat.userId == 48 || chat.userId == 62
                  ? Theme.of(context).accentColor
                  : null),
        ),

        ///[Last Message]
        lastmsg: Text(chat.lastMessage,
            maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing:
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Text(timeAgo.format(DateTime.parse(chat.updatedAt),
              allowFromNow: true)),
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
        onTap: () => Navigator.pushNamed(context, RouteName.chatBox,
            arguments: chat.userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await _storyModel.fetchStory();
          },
          child: Column(
            children: [
              ProviderWidget<StoryModel>(
                model: _storyModel,
                onModelReady: (model) {
                  model.fetchStory();
                },
                builder: (context, _, child) {
                  if (_storyModel.stories.isEmpty) {
                    return Container();
                  }
                  return StoryList(
                    stories: _storyModel.stories,
                  );
                },
              ),
              StreamBuilder<List<NewChat>>(
                  initialData: null,
                  stream: _chatListBloc.chatsSubject,
                  builder: (context, snapshot) {
                    if (snapshot.data == null) {
                      return Center(child: CupertinoActivityIndicator());
                    }
                    if (snapshot.data.isEmpty) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.7,
                            child: Image.asset(
                              'assets/images/noFollowing.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            bottom: MediaQuery.of(context).size.height * 0.5,
                            child: Text(
                              G.of(context).noChatHistory,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 20),
                            ),
                          )
                        ],
                      );
                    }
                    return Expanded(
                      child: ListView.builder(
                        physics: ClampingScrollPhysics(),
                        itemBuilder: (context, index) {
                          NewChat chat = snapshot.data[index];
                          return _buildChatTile(chat);
                        },
                        itemCount: snapshot.data.length,
                      ),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}

/*
SmartRefresher(
          controller: refreshController,
          header: WaterDropHeader(),
          enablePullDown: true,
          onRefresh: () {
            onRefresh(_storyModel);
          },
          child: Column(
            children: [
              ProviderWidget<StoryModel>(
                model: _storyModel,
                onModelReady: (model) {
                  model.fetchStory();
                },
                builder: (context, _, child) {
                  if (_storyModel.stories.isEmpty) {
                    return Container();
                  }
                  return StoryList(
                    stories: _storyModel.stories,
                  );
                },
              ),
              StreamBuilder<List<NewChat>>(
                  initialData: null,
                  stream: _chatListBloc.chatsSubject,
                  builder: (context, snapshot) {
                    if (snapshot.data == null) {
                      return Center(child: CupertinoActivityIndicator());
                    }
                    if (snapshot.data.isEmpty) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.7,
                            child: Image.asset(
                              'assets/images/noFollowing.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            bottom: MediaQuery.of(context).size.height * 0.5,
                            child: Text(
                              G.of(context).noChatHistory,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 20),
                            ),
                          )
                        ],
                      );
                    }
                    return Expanded(
                      child: ListView.builder(
                        physics: ClampingScrollPhysics(),
                        itemBuilder: (context, index) {
                          NewChat chat = snapshot.data[index];
                          return _buildChatTile(chat);
                        },
                        itemCount: snapshot.data.length,
                      ),
                    );
                  }),
            ],
          ),
        )
*/
