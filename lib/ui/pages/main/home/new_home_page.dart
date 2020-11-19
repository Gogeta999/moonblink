import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide showSearch;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gradient_colors/flutter_gradient_colors.dart';
import 'package:flutter_intro/flutter_intro.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moonblink/base_widget/appbar/appbarlogo.dart';
import 'package:moonblink/base_widget/container/shadedContainer.dart';
import 'package:moonblink/base_widget/custom_flutter_src/search.dart';
import 'package:moonblink/bloc_pattern/home/bloc/home_bloc.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/post.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/provider/view_state_error_widget.dart';
import 'package:moonblink/ui/helper/icons.dart';
import 'package:moonblink/ui/helper/tutorial.dart';
import 'package:moonblink/ui/pages/main/home/home_provider_widget/post_item.dart';
import 'package:moonblink/ui/pages/main/home/shimmer_indicator.dart';
import 'package:moonblink/ui/pages/search/search_page.dart';
import 'package:moonblink/utils/status_bar_utils.dart';
import 'package:moonblink/view_model/home_model.dart';
import 'package:moonblink/view_model/scroll_controller_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

///coplayer = 1
///streamer = 2
///cele = 3
///pro = 4

class HomePage extends StatefulWidget {
  final ScrollController homecontroller;
  HomePage(this.homecontroller);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  final _homeBloc = HomeBloc();
  double _scrollThreshold = 800.0;
  Timer _debounce;

  Intro intro;
  _HomePageState() {
    intro = Intro(
      stepCount: 3,

      /// use defaultTheme, or you can implement widgetBuilder function yourself
      widgetBuilder: StepWidgetBuilder.useDefaultTheme(
        texts: [
          G.current.tutorialHome1,
          G.current.tutorialHome2,
          G.current.tutorialHome3,
          // 'Tap to get into user detail',
        ],
        btnLabel: G.current.next,
        showStepLabel: true,
      ),
    );
  }
  @override
  bool get wantKeepAlive => true;
  PageController _pageController;
  int catagories = 1;
  // String gender = "All";
  String gender = "All";
  bool tuto = true;

  @override
  void initState() {
    _homeBloc.fetchData();

    super.initState();
    // tutorialOn();
    bool showtuto = StorageManager.sharedPreferences.getBool(hometuto);
    if (showtuto == null) {
      tutorialOn();
      showtuto = StorageManager.sharedPreferences.getBool(hometuto);
    }
    setState(() {
      tuto = showtuto;
      _pageController = PageController(initialPage: 0);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollThreshold = MediaQuery.of(context).size.height * 3;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  newtopTabs(homeController) {
    return Container(
      key: intro.keys[0],
      height: 60,
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                key: intro.keys[2],
                child: Column(
                  children: [
                    InkWell(
                      onDoubleTap: () {
                        homeController.animateTo(
                          0.0,
                          curve: Curves.easeOut,
                          duration: const Duration(milliseconds: 300),
                        );
                      },
                      onTap: () {
                        if (catagories != 1) {
                          setState(() {
                            catagories = 1;
                            _homeBloc.fetchData(
                                type: catagories, gender: gender);
                            //_pageController.jumpToPage(0);
                          });
                        } else {
                          print("Already");
                        }
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: GradientColors.indigo,
                            )),
                        child: Icon(Icons.airline_seat_recline_normal,
                            color: Colors.white),
                      ),
                    ),
                    Text(G.current.usertypecoplayer),
                  ],
                ),
              ),
              Container(
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        if (catagories != 3) {
                          setState(() {
                            catagories = 3;
                            _homeBloc.fetchData(
                                type: catagories, gender: gender);
                            //_pageController.jumpToPage(1);
                          });
                        } else {
                          print("Already");
                        }
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: GradientColors.gradeGrey,
                            )),
                        child:
                            Icon(FontAwesomeIcons.crown, color: Colors.white),
                      ),
                    ),
                    Text(G.current.usertypecele),
                  ],
                ),
              ),
              Container(
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        if (catagories != 4) {
                          setState(() {
                            catagories = 4;
                            _homeBloc.fetchData(
                                type: catagories, gender: gender);
                            //_pageController.jumpToPage(2);
                          });
                        } else {
                          print("Already");
                        }
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: GradientColors.radish,
                            )),
                        child:
                            Icon(FontAwesomeIcons.gamepad, color: Colors.white),
                      ),
                    ),
                    Text(G.current.usertypepro),
                  ],
                ),
              ),
              Container(
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        if (catagories != 2) {
                          setState(() {
                            catagories = 2;
                            _homeBloc.fetchData(
                                type: catagories, gender: gender);
                            //_pageController.jumpToPage(3);
                          });
                        } else {
                          print("Already");
                        }
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: GradientColors.darkOcean,
                            )),
                        child:
                            Icon(FontAwesomeIcons.twitch, color: Colors.white),
                      ),
                    ),
                    Text(G.current.usertypestreamer),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  topTabs(homeController) {
    return Container(
      key: intro.keys[0],
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
                key: intro.keys[2],
                onDoubletap: () {
                  homeController.animateTo(
                    0.0,
                    curve: Curves.easeOut,
                    duration: const Duration(milliseconds: 300),
                  );
                },
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
                  G.of(context).usertypecoplayer,
                  textAlign: TextAlign.center,
                ),
              ),
              SmallShadedContainer(
                selected: catagories == 3 ? true : false,
                onDoubletap: () {
                  homeController.animateTo(
                    0.0,
                    curve: Curves.easeOut,
                    duration: const Duration(milliseconds: 300),
                  );
                },
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
                  G.of(context).usertypecele,
                  textAlign: TextAlign.center,
                ),
              ),
              SmallShadedContainer(
                selected: catagories == 4 ? true : false,
                onDoubletap: () {
                  homeController.animateTo(
                    0.0,
                    curve: Curves.easeOut,
                    duration: const Duration(milliseconds: 300),
                  );
                },
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
                  G.of(context).usertypepro,
                  textAlign: TextAlign.center,
                ),
              ),
              SmallShadedContainer(
                selected: catagories == 2 ? true : false,
                onDoubletap: () {
                  homeController.animateTo(
                    0.0,
                    curve: Curves.easeOut,
                    duration: const Duration(milliseconds: 300),
                  );
                },
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
                  G.of(context).usertypestreamer,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  newmalefemale() {
    return Container(
      key: intro.keys[1],
      decoration: BoxDecoration(
        border: Border.all(width: 1.5, color: Colors.grey),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: 10, bottom: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      if (gender != "Male") {
                        setState(
                          () {
                            gender = "Male";
                            _homeBloc.fetchData(
                                type: catagories, gender: gender);
                            //_pageController.jumpToPage(5);
                          },
                        );
                      } else {
                        setState(() {
                          gender = "All";
                          _homeBloc.fetchData(type: catagories, gender: gender);
                          //pageController.jumpToPage(4);
                        });
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: GradientColors.eveningSunshine,
                          )),
                      child: Icon(FontAwesomeIcons.mars, color: Colors.white),
                    ),
                  ),
                  Text(G.current.genderMale),
                ],
              ),
            ),
            Container(
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      if (gender != "Female") {
                        setState(
                          () {
                            gender = "Female";
                            _homeBloc.fetchData(
                                type: catagories, gender: gender);
                            //_pageController.jumpToPage(7);
                          },
                        );
                      } else {
                        setState(
                          () {
                            gender = "All";
                            _homeBloc.fetchData(
                                type: catagories, gender: gender);
                            //_pageController.jumpToPage(4);
                          },
                        );
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: GradientColors.juicyOrange,
                          )),
                      child: Icon(FontAwesomeIcons.venus, color: Colors.white),
                    ),
                  ),
                  Text(G.current.genderFemale),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  malefemaletabs() {
    return Container(
      key: intro.keys[1],
      decoration: BoxDecoration(
        border: Border.all(width: 1.5, color: Colors.black),
        borderRadius: BorderRadius.circular(15),
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
                child: Text(G.of(context).genderMale),
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
                child: Text(G.of(context).genderFemale),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? Colors.grey[200]
            : null,
        appBar: HomeAppBar(),
        body: BlocProvider.value(
          value: _homeBloc,
          child: SafeArea(
            child: ProviderWidget2<HomeModel, TapToTopModel>(
                autoDispose: true,
                model1: HomeModel(),
                model2: TapToTopModel(PrimaryScrollController.of(context),
                    height: kToolbarHeight),
                onModelReady: (homeModel, tapToTopModel) {
                  //homeModel.initData();
                },
                builder: (context, homeModel, tapToTopModel, child) {
                  return SmartRefresher(
                    controller: _homeBloc.refreshController,
                    header: WaterDropHeader(),
                    footer: ShimmerFooter(
                      text: CupertinoActivityIndicator(),
                    ),
                    enablePullDown: true,
                    onRefresh: () {
                      // await homeModel.refresh();
                      // homeModel.showErrorMessage(context);
                      _homeBloc.refreshData();
                    },
                    //enablePullUp: true,
                    // onLoading: () {
                    //   print('Loading');
                    //   _homeBloc.fetchMoreData();
                    // },
                    child: CustomScrollView(
                        controller: widget.homecontroller
                          ..addListener(_onScroll),
                        slivers: [
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            sliver: SliverToBoxAdapter(
                              child: newtopTabs(widget.homecontroller),
                            ),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            sliver: SliverToBoxAdapter(
                              child: newmalefemale(),
                            ),
                          ),
                          // if (homeModel.isError && homeModel.list.isEmpty)
                          //   SliverToBoxAdapter(
                          //     child: AnnotatedRegion<SystemUiOverlayStyle>(
                          //         value:
                          //             StatusBarUtils.systemUiOverlayStyle(
                          //                 context),
                          //         child: ViewStateErrorWidget(
                          //             error: homeModel.viewStateError,
                          //             onPressed: homeModel.initData)),
                          //   ),
                          HomePostList()
                        ]),
                  );
                }),
          ),
        ));
  }

  void _onScroll() {
    final maxScroll = widget.homecontroller.position.maxScrollExtent;
    final currentScroll = widget.homecontroller.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      _homeBloc.hasReachedMaxSubject.first.then((value) {
        if (value) {
          if (_debounce?.isActive ?? false) _debounce.cancel();
          _debounce = Timer(const Duration(milliseconds: 5000), () {
            _homeBloc.fetchMoreData();
          });
        } else {
          if (_debounce?.isActive ?? false) _debounce.cancel();
          _debounce = Timer(const Duration(milliseconds: 500), () {
            _homeBloc.fetchMoreData();
          });
        }
      });
    }
  }
}

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 10);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      leading: IconButton(
        color: Colors.white,
        icon: SvgPicture.asset(
          search,
          color: Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).accentColor
              : Colors.white,
          semanticsLabel: 'search',
          width: 30,
          height: 30,
        ),
        onPressed: () {
          showSearch(context: context, delegate: SearchPage());
        },
      ),
      actions: <Widget>[
        AppbarLogo(),
      ],
      flexibleSpace: null,
      bottom: PreferredSize(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).accentColor,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).accentColor,
                blurRadius: 4,
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
    return SliverToBoxAdapter(
      child: BlocProvider.value(
        value: BlocProvider.of<HomeBloc>(context),
        child: StreamBuilder<List<Post>>(
            initialData: [],
            stream: BlocProvider.of<HomeBloc>(context).postsSubject,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(snapshot.error.toString()),
                        SizedBox(height: 5),
                        CupertinoButton(
                            child: Text('Retry'),
                            onPressed: () {
                              BlocProvider.of<HomeBloc>(context).refreshData();
                              BlocProvider.of<HomeBloc>(context)
                                  .postsSubject
                                  .add([]);
                            })
                      ],
                    )));
              }
              if (snapshot.data.isEmpty) {
                return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: Center(child: CupertinoActivityIndicator()));
              }
              return ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  Post item = snapshot.data[index];
                  if (index == snapshot.data.length - 1) {
                    return Column(
                      children: [
                        PostItemWidget(item, index: index),
                        StreamBuilder<bool>(
                            initialData: false,
                            stream: BlocProvider.of<HomeBloc>(context)
                                .loadingSubject,
                            builder: (context, snapshot2) {
                              if (snapshot2.data) {
                                print('Loading new posts');
                                return Center(
                                    child: Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: CupertinoActivityIndicator(),
                                ));
                              } else {
                                return Container();
                              }
                            })
                      ],
                    );
                  } else {
                    return PostItemWidget(item, index: index);
                  }
                },
                itemCount: snapshot.data.length,
              );
            }),
      ),
    );
  }
}
