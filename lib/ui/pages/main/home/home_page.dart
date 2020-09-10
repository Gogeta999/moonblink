import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide showSearch;
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moonblink/base_widget/appbar/appbarlogo.dart';
import 'package:moonblink/base_widget/container/shadedContainer.dart';
import 'package:moonblink/base_widget/custom_flutter_src/search.dart';
import 'package:moonblink/global/resources_manager.dart';
import 'package:moonblink/models/post.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/provider/view_state_error_widget.dart';
import 'package:moonblink/ui/pages/main/home/home_provider_widget/post_item.dart';
import 'package:moonblink/ui/pages/main/home/shimmer_indicator.dart';
import 'package:moonblink/ui/pages/main/stories/storylist.dart';
import 'package:moonblink/ui/pages/search/search_page.dart';
import 'package:moonblink/utils/status_bar_utils.dart';
import 'package:moonblink/view_model/home_model.dart';
import 'package:moonblink/view_model/scroll_controller_model.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  int catagories = 0;
  int gender = 0;

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
        tapToTopModel.init(() => homeModel.loadMore());
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
                if (homeModel.isBusy &&
                    Theme.of(context).brightness == Brightness.light) {
                  return Container(
                    height: double.infinity,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(
                              ImageHelper.wrapAssetsImage('bookingWaiting.gif'),
                            ),
                            fit: BoxFit.fill)),
                  );
                }
                if (homeModel.isBusy &&
                    Theme.of(context).brightness == Brightness.dark) {
                  return Container(
                    height: double.infinity,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(
                              ImageHelper.wrapAssetsImage(
                                  'moonblinkWaitingDark.gif'),
                            ),
                            fit: BoxFit.fill)),
                  );
                }
                return SmartRefresher(
                    controller: homeModel.refreshController,
                    header: ShimmerHeader(
                      text: CupertinoActivityIndicator(),
                    ),
                    footer: ShimmerFooter(
                      text: CupertinoActivityIndicator(),
                    ),
                    enablePullDown: homeModel.list.isNotEmpty,
                    onRefresh: () async {
                      await homeModel.refresh();
                      homeModel.showErrorMessage(context);
                    },
                    enablePullUp: homeModel.list.isNotEmpty,
                    onLoading: homeModel.loadMore,
                    child: CustomScrollView(
                      // controller: tapToTopModel.scrollController,
                      slivers: <Widget>[
                        HomeAppBar(),
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: 10,
                          ),
                        ),
                        if (homeModel.isEmpty)
                          SliverToBoxAdapter(
                              child: Padding(
                            padding: const EdgeInsets.only(top: 50),
                            child: ViewStateEmptyWidget(
                                onPressed: homeModel.initData),
                          )),
                        // if (homeModel.stories?.isNotEmpty ?? false)
                        //   StoryList(stories: homeModel.stories),
                        TopTabs(
                          catagory: catagories,
                        ),
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: 20,
                          ),
                        ),
                        MaleFamleTabs(
                          gender: gender,
                        ),
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: 20,
                          ),
                        ),
                        HomePostList(),
                      ],
                    ));
              })),
        );
      },
    );
  }
}

class HomeAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TapToTopModel tapToTopModel = Provider.of(context);
    return SliverAppBar(
      // centerTitle: true,
      ///[Appbar]
      backgroundColor: Colors.black,
      leading: IconButton(
        icon: Icon(FontAwesomeIcons.search),
        onPressed: () {
          showSearch(context: context, delegate: SearchPage());
        },
      ),
      pinned: true,
      //toolbarHeight: kToolbarHeight - 5,
      // expandedHeight: kToolbarHeight,
      brightness: Theme.of(context).brightness == Brightness.light
          ? Brightness.light
          : Brightness.dark,
      actions: <Widget>[
        GestureDetector(
            onDoubleTap: tapToTopModel.scrollToTop, child: AppbarLogo()),
      ],
      flexibleSpace: null,
      bottom: AppBar(
        backgroundColor: Theme.of(context).accentColor,
        //toolbarHeight: 20,
      ),
    );
  }
}

class HomePostList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    HomeModel homeModel = Provider.of(context);
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        Post item = homeModel.list[index];
        return PostItemWidget(item, index: index);
      }, childCount: homeModel.list?.length ?? 0),
    );
  }
}

// ignore: must_be_immutable
class TopTabs extends StatefulWidget {
  int catagory;
  TopTabs({this.catagory});

  @override
  _TopTabsState createState() => _TopTabsState();
}

class _TopTabsState extends State<TopTabs> {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        height: 40,
        child: Stack(
          children: [
            Center(
              child: Divider(
                thickness: 2,
                color: Colors.black,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SmallShadedContainer(
                  selected: widget.catagory == 0 ? true : false,
                  ontap: () {
                    if (widget.catagory != 0) {
                      setState(() {
                        widget.catagory = 0;
                      });
                    } else {
                      print("Already");
                    }
                  },
                  child: Text(
                    "Coplayer",
                    textAlign: TextAlign.center,
                  ),
                ),
                SmallShadedContainer(
                  selected: widget.catagory == 1 ? true : false,
                  ontap: () {
                    if (widget.catagory != 1) {
                      setState(() {
                        widget.catagory = 1;
                      });
                    } else {
                      print("Already");
                    }
                  },
                  child: Text(
                    "Cele",
                    textAlign: TextAlign.center,
                  ),
                ),
                SmallShadedContainer(
                  selected: widget.catagory == 2 ? true : false,
                  ontap: () {
                    if (widget.catagory != 2) {
                      setState(() {
                        widget.catagory = 2;
                      });
                    } else {
                      print("Already");
                    }
                  },
                  child: Text(
                    "Pro",
                    textAlign: TextAlign.center,
                  ),
                ),
                SmallShadedContainer(
                  selected: widget.catagory == 3 ? true : false,
                  ontap: () {
                    if (widget.catagory != 3) {
                      setState(() {
                        widget.catagory = 3;
                      });
                    } else {
                      print("Already");
                    }
                  },
                  child: Text(
                    "Streamer",
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class MaleFamleTabs extends StatefulWidget {
  int gender;
  MaleFamleTabs({this.gender});
  @override
  _MaleFamleTabsState createState() => _MaleFamleTabsState();
}

class _MaleFamleTabsState extends State<MaleFamleTabs> {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              width: 2,
              color: Colors.black,
            ),
            bottom: BorderSide(
              width: 2,
              color: Colors.black,
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(top: 10, bottom: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SmallShadedContainer(
                selected: widget.gender == 0 ? true : false,
                ontap: () {
                  if (widget.gender != 0) {
                    setState(() {
                      widget.gender = 0;
                    });
                  }
                },
                child: Center(
                  child: Text("Male"),
                ),
              ),
              SmallShadedContainer(
                selected: widget.gender == 1 ? true : false,
                ontap: () {
                  if (widget.gender != 1) {
                    setState(() {
                      widget.gender = 1;
                    });
                  }
                },
                child: Center(
                  child: Text("Female"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
