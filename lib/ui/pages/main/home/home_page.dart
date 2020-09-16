import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide showSearch;
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moonblink/base_widget/appbar/appbarlogo.dart';
import 'package:moonblink/base_widget/container/shadedContainer.dart';
import 'package:moonblink/base_widget/custom_flutter_src/search.dart';
import 'package:moonblink/models/post.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/provider/view_state_error_widget.dart';
import 'package:moonblink/ui/pages/main/home/home_provider_widget/post_item.dart';
import 'package:moonblink/ui/pages/main/home/shimmer_indicator.dart';
import 'package:moonblink/ui/pages/search/search_page.dart';
import 'package:moonblink/utils/status_bar_utils.dart';
import 'package:moonblink/view_model/home_model.dart';
import 'package:moonblink/view_model/scroll_controller_model.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

///coplayer = 1
///streamer = 2
///cele = 3
///pro = 4
final String search = 'assets/icons/search.svg';

class HomePage extends StatefulWidget {
  final homecontroller;
  HomePage(this.homecontroller);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  var _pageController;
  int catagories = 1;
  // String gender = "All";
  String gender = "Male";
  @override
  void initState() {
    super.initState();
    setState(() {
      _pageController = PageController(initialPage: 0);
    });
  }

  topTabs() {
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
                  onDoubletap: () {},
                  selected: catagories == 1 ? true : false,
                  ontap: () {
                    if (catagories != 1) {
                      setState(() {
                        catagories = 1;
                        _pageController.jumpToPage(0);
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
                  selected: catagories == 3 ? true : false,
                  ontap: () {
                    if (catagories != 3) {
                      setState(() {
                        catagories = 3;
                        _pageController.jumpToPage(1);
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
                  selected: catagories == 4 ? true : false,
                  ontap: () {
                    if (catagories != 4) {
                      setState(() {
                        catagories = 4;
                        _pageController.jumpToPage(2);
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
                  selected: catagories == 2 ? true : false,
                  ontap: () {
                    if (catagories != 2) {
                      setState(() {
                        catagories = 2;
                        _pageController.jumpToPage(3);
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

  malefemaletabs() {
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
              MediumShadedContainer(
                selected: gender == "Male" ? true : false,
                ontap: () {
                  if (gender != "Male") {
                    setState(
                      () {
                        gender = "Male";
                        _pageController.jumpToPage(5);
                      },
                    );
                  } else {
                    setState(() {
                      gender = "All";
                      _pageController.jumpToPage(4);
                    });
                  }
                },
                child: Center(
                  child: Text("Male"),
                ),
              ),
              MediumShadedContainer(
                selected: gender == "Female" ? true : false,
                ontap: () {
                  if (gender != "Female") {
                    setState(
                      () {
                        gender = "Female";
                        _pageController.jumpToPage(7);
                      },
                    );
                  } else {
                    setState(
                      () {
                        gender = "All";
                        _pageController.jumpToPage(4);
                      },
                    );
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print(catagories);
    return Scaffold(
      body: PageView.builder(
        itemCount: 8,
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return ProviderWidget2<HomeModel, TapToTopModel>(
            autoDispose: true,
            model1: HomeModel(type: catagories, gender: gender),
            model2: TapToTopModel(PrimaryScrollController.of(context),
                height: kToolbarHeight),
            onModelReady: (homeModel, tapToTopModel) {
              homeModel.initData();
              tapToTopModel.init(() => homeModel.loadMore());
            },
            builder: (context, homeModel, tapToTopModel, child) {
              return MediaQuery.removePadding(
                context: context,
                removeTop: false,
                child: Builder(builder: (_) {
                  // if (homeModel.isBusy &&
                  //     Theme.of(context).brightness == Brightness.light) {
                  //   return Container(
                  //     height: double.infinity,
                  //     decoration: BoxDecoration(
                  //         image: DecorationImage(
                  //             image: AssetImage(
                  //               ImageHelper.wrapAssetsImage(
                  //                   'bookingWaiting.gif'),
                  //             ),
                  //             fit: BoxFit.fill)),
                  //   );
                  // }
                  // if (homeModel.isBusy &&
                  //     Theme.of(context).brightness == Brightness.dark) {
                  //   return Container(
                  //     height: double.infinity,
                  //     decoration: BoxDecoration(
                  //         image: DecorationImage(
                  //             image: AssetImage(
                  //               ImageHelper.wrapAssetsImage(
                  //                   'moonblinkWaitingDark.gif'),
                  //             ),
                  //             fit: BoxFit.fill)),
                  //   );
                  // }
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
                      controller: widget.homecontroller,
                      // controller: tapToTopModel.scrollController,
                      slivers: <Widget>[
                        HomeAppBar(),
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: 10,
                          ),
                        ),

                        // if (homeModel.stories?.isNotEmpty ?? false)
                        //   StoryList(stories: homeModel.stories),
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: 10,
                          ),
                        ),
                        topTabs(),
                        // TopTabs(
                        //   catagory: catagories,
                        // ),
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: 20,
                          ),
                        ),
                        malefemaletabs(),
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: 20,
                          ),
                        ),
                        // if (homeModel.isEmpty)
                        //   SliverToBoxAdapter(
                        //     child: Padding(
                        //       padding: const EdgeInsets.only(top: 50),
                        //       child: ViewStateEmptyWidget(
                        //           onPressed: homeModel.initData),
                        //     ),
                        //   ),
                        if (homeModel.isError && homeModel.list.isEmpty)
                          SliverToBoxAdapter(
                            child: AnnotatedRegion<SystemUiOverlayStyle>(
                                value: StatusBarUtils.systemUiOverlayStyle(
                                    context),
                                child: ViewStateErrorWidget(
                                    error: homeModel.viewStateError,
                                    onPressed: homeModel.initData)),
                          ),
                        HomePostList(),
                      ],
                    ),
                  );
                }),
              );
            },
          );
        },
      ),
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
        icon: SvgPicture.asset(
          search,
          color: Theme.of(context).accentColor,
          semanticsLabel: 'search',
          width: 30,
          height: 30,
        ),
        onPressed: () {
          showSearch(context: context, delegate: SearchPage());
        },
      ),
      pinned: true,
      //toolbarHeight: kToolbarHeight,
      // expandedHeight: kToolbarHeight,
      // brightness: Theme.of(context).brightness == Brightness.light
      //     ? Brightness.light
      //     : Brightness.dark,
      actions: <Widget>[
        GestureDetector(
            onDoubleTap: tapToTopModel.scrollToTop, child: AppbarLogo()),
      ],
      flexibleSpace: null,
      bottom: PreferredSize(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).accentColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                // spreadRadius: 1,
                blurRadius: 3,
                offset: Offset(0, 0), // changes position of shadow
              ),
            ],
          ),
          height: 10,
        ),
        preferredSize: Size.fromHeight(10),
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
