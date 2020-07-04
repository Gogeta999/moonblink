import 'package:flutter/material.dart' hide showSearch;
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moonblink/base_widget/appbarlogo.dart';
import 'package:moonblink/base_widget/custom_flutter_src/search.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/post.dart';
import 'package:moonblink/models/story.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/provider/view_state_error_widget.dart';
import 'package:moonblink/ui/pages/main/home/home_provider_widget/post_item.dart';
import 'package:moonblink/ui/pages/main/home/home_provider_widget/post_skeleton.dart';
import 'package:moonblink/ui/pages/main/home/home_provider_widget/skeleton.dart';
import 'package:moonblink/ui/pages/main/home/shimmer_indicator.dart';
import 'package:moonblink/ui/pages/search/search_page.dart';
import 'package:moonblink/utils/status_bar_utils.dart';
import 'package:moonblink/view_model/home_model.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:moonblink/view_model/scroll_controller_model.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:moonblink/ui/pages/main/stories/story_item.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  var esm = 1;
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ProviderWidget2<HomeModel, TapToTopModel>(
      autoDispose: false,
      model1: HomeModel(),
      model2: TapToTopModel(PrimaryScrollController.of(context),
          height: kToolbarHeight),
      onModelReady: (homeModel, tapToTopModel) {
        homeModel.initData();
        tapToTopModel.init();
      },
      builder: (context, homeModel, tapToTopModel, child) {
        return Scaffold(
          body: MediaQuery.removePadding(
              context: context,
              removeTop: false,
              child: Builder(builder: (_) {
                if (homeModel.isError && homeModel.list.isEmpty) {
                  return AnnotatedRegion<SystemUiOverlayStyle>(
                      value: StatusBarUtils.systemUiOverlayStyle(context),
                      child: ViewStateErrorWidget(
                          error: homeModel.viewStateError,
                          onPressed: homeModel.initData));
                }

                return SmartRefresher(
                    controller: homeModel.refreshController,
                    header: ShimmerHeader(
                        text: Text("PullToRefresh",
                            style:
                                TextStyle(color: Colors.grey, fontSize: 22))),
                    footer: ShimmerFooter(
                        text: Text("LoadMore",
                            style:
                                TextStyle(color: Colors.grey, fontSize: 22))),
                    enablePullDown: homeModel.list.isNotEmpty,
                    onRefresh: () async {
                      await homeModel.refresh();
                      homeModel.showErrorMessage(context);
                    },
                    enablePullUp: homeModel.list.isNotEmpty,
                    onLoading: homeModel.loadMore,
                    child: CustomScrollView(
                      controller: tapToTopModel.scrollController,
                      slivers: <Widget>[
                        SliverAppBar(
                          // centerTitle: true,
                          ///[Appbar]
                          title: GestureDetector(
                              onDoubleTap: tapToTopModel.scrollToTop,
                              child: AppbarLogo()),
                          pinned: true,
                          expandedHeight: kToolbarHeight,
                          brightness:
                              Theme.of(context).brightness == Brightness.light
                                  ? Brightness.light
                                  : Brightness.dark,
                          actions: <Widget>[
                            IconButton(
                                icon: Icon(FontAwesomeIcons.search),
                                onPressed: () {
                                  showSearch(
                                      context: context, delegate: SearchPage());
                                })
                          ],
                          flexibleSpace: null,
                        ),
                        if (homeModel.isEmpty)
                          SliverToBoxAdapter(
                              child: Padding(
                            padding: const EdgeInsets.only(top: 50),
                            child: ViewStateEmptyWidget(
                                onPressed: homeModel.initData),
                          )),
                        if (homeModel.stories?.isNotEmpty ?? false) StoryList(),
                        HomePostList(),
                      ],
                    ));
              })),
        );
      },
    );
  }
}

class HomePostList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    HomeModel homeModel = Provider.of(context);

    if (homeModel.isBusy) {
      return SliverToBoxAdapter(
        child: SkeletonList(builder: (context, index) => PostSkeletonItem()),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          Post item = homeModel.list[index];
          return PostItemWidget(item);
        },
        childCount: homeModel.list?.length ?? 0,
      ),
    );
  }
}

class StoryList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    HomeModel homeModel = Provider.of(context);
    return SliverToBoxAdapter(
        child: Column(
      children: <Widget>[
        Container(
            height: 100,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: homeModel.stories.length,
                itemBuilder: (context, index) {
                  Story item = homeModel.stories[index];
                  int usertype =
                      StorageManager.sharedPreferences.getInt(mUserType);

                  if (usertype == 1 && index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 14),
                      child: InkWell(
                        onTap: () {
                          // final storyItem = item.mediaUrl;
                          Navigator.of(context).pushNamed(RouteName.imagepick);
                        },
                        child: CircleAvatar(
                          radius: 33,
                          backgroundColor: Colors.grey[300],
                          child: Icon(Icons.add, size: 24, color: Colors.black),
                        ),
                        // child: Text(usertype.toString()),),
                      ),
                    );
                  }
                  // if(item.body == String){
                  //   return StoryItemWidget(item);
                  // }
                  return StoryItemWidget(item);
                }))
      ],
    ));
  }
}
