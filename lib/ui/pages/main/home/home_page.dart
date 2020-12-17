import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide showSearch;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gradient_colors/flutter_gradient_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moonblink/base_widget/appbar/appbarlogo.dart';
import 'package:moonblink/base_widget/custom_flutter_src/search.dart';
import 'package:moonblink/base_widget/intro/flutter_intro.dart';
import 'package:moonblink/bloc_pattern/home/bloc/home_bloc.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/post.dart';
import 'package:moonblink/provider/view_state.dart';
import 'package:moonblink/provider/view_state_error_widget.dart';
import 'package:moonblink/ui/helper/icons.dart';
import 'package:moonblink/ui/helper/tutorial.dart';
import 'package:moonblink/ui/pages/main/home/home_provider_widget/post_item.dart';
import 'package:moonblink/ui/pages/main/home/shimmer_indicator.dart';
import 'package:moonblink/ui/pages/search/search_page.dart';
import 'package:moonblink/utils/constants.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rxdart/subjects.dart';

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
  final catagories = BehaviorSubject.seeded(1);
  final gender = BehaviorSubject.seeded("All");
  bool tuto = true;

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
        buttonTextBuilder: (curr, total) {
          return curr < total - 1 ? 'Next' : 'Finish';
        },
      ),
    );
  }
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _homeBloc.fetchData();
    widget.homecontroller.addListener(_onScroll);
    print('Initing');

    super.initState();
    // tutorialOn();
    bool showtuto = (StorageManager.sharedPreferences.getBool(hometuto) ?? true);
    if (showtuto == null) {
      tutorialOn();
      showtuto = (StorageManager.sharedPreferences.getBool(hometuto) ?? true);
    }
    setState(() {
      tuto = showtuto;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollThreshold = MediaQuery.of(context).size.height * 3;
  }

  @override
  void dispose() {
    Future.delayed(Duration.zero, () => intro.dispose());
    _debounce?.cancel();
    catagories.close();
    gender.close();
    _homeBloc.dispose();
    super.dispose();
  }

  newtopTabs(homeController) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Card(
        key: intro.keys[0],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(10.0),
          ),
        ),
        elevation: 4,
        shadowColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.black
            : Colors.grey,
        child: Container(
          padding: EdgeInsets.only(top: 8, bottom: 4),
          height: 85,
          child: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //CoPlayer
                  Expanded(
                    flex: 1,
                    child: Container(
                      key: intro.keys[2],
                      child: Column(
                        children: [
                          Expanded(
                            flex: 2,
                            child: GestureDetector(
                              onDoubleTap: () {
                                homeController.animateTo(
                                  0.0,
                                  curve: Curves.easeOut,
                                  duration: const Duration(milliseconds: 300),
                                );
                              },
                              onTap: () {
                                catagories.first.then((value) async {
                                  if (value != kCoPlayer) {
                                    catagories.add(kCoPlayer);
                                    final cata = await catagories.first;
                                    final gen = await gender.first;
                                    _homeBloc.fetchData(
                                        type: cata, gender: gen);
                                  }
                                });
                                // if (catagories != 1) {
                                //   catagories = 1;
                                //   _homeBloc.fetchData(
                                //       type: catagories, gender: gender);
                                // } else {
                                //   print("Already");
                                // }
                              },
                              child: StreamBuilder<int>(
                                  stream: catagories,
                                  builder: (context, snapshot) {
                                    return Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                          boxShadow: [
                                            snapshot.data == kCoPlayer
                                                ? BoxShadow(
                                                    color: Colors.black,
                                                    // spreadRadius: 1,
                                                    blurRadius: 4,
                                                    offset: Offset(-3,
                                                        3), // changes position of shadow
                                                  )
                                                : BoxShadow(),
                                          ],
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors:
                                                MoreGradientColors.azureLane,
                                          )),
                                      child: Icon(Icons.supervisor_account,
                                          size: 23, color: Colors.white),
                                    );
                                  }),
                            ),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Expanded(
                              flex: 1, child: Text(G.current.usertypecoplayer)),
                        ],
                      ),
                    ),
                  ),

                  ///Cele
                  Expanded(
                    flex: 1,
                    child: Container(
                      child: Column(
                        children: [
                          Expanded(
                            flex: 2,
                            child: GestureDetector(
                              onTap: () {
                                catagories.first.then((value) async {
                                  if (value != kCele) {
                                    catagories.add(kCele);
                                    final cata = await catagories.first;
                                    final gen = await gender.first;
                                    _homeBloc.fetchData(
                                        type: cata, gender: gen);
                                  }
                                });
                                // if (catagories != 3) {
                                //   catagories = 3;
                                //   _homeBloc.fetchData(
                                //       type: catagories, gender: gender);
                                // } else {
                                //   print("Already");
                                // }
                              },
                              child: StreamBuilder<int>(
                                  stream: catagories,
                                  builder: (context, snapshot) {
                                    return Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                          boxShadow: [
                                            snapshot.data == kCele
                                                ? BoxShadow(
                                                    color: Colors.black,
                                                    // spreadRadius: 1,
                                                    blurRadius: 4,
                                                    offset: Offset(-3,
                                                        3), // changes position of shadow
                                                  )
                                                : BoxShadow(),
                                          ],
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: MoreGradientColors
                                                .orangePinkTeal,
                                          )),
                                      child: Icon(
                                        FontAwesomeIcons.star,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    );
                                  }),
                            ),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Expanded(
                              flex: 1, child: Text(G.current.usertypecele)),
                        ],
                      ),
                    ),
                  ),

                  ///Pro
                  Expanded(
                    flex: 1,
                    child: Container(
                      child: Column(
                        children: [
                          Expanded(
                            flex: 2,
                            child: GestureDetector(
                              onTap: () {
                                catagories.first.then((value) async {
                                  if (value != kPro) {
                                    catagories.add(kPro);
                                    final cata = await catagories.first;
                                    final gen = await gender.first;
                                    _homeBloc.fetchData(
                                        type: cata, gender: gen);
                                  }
                                });
                                // if (catagories != 4) {
                                //   catagories = 4;
                                //   _homeBloc.fetchData(
                                //       type: catagories, gender: gender);
                                // } else {
                                //   print("Already");
                                // }
                              },
                              child: StreamBuilder<int>(
                                  stream: catagories,
                                  builder: (context, snapshot) {
                                    return Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                          boxShadow: [
                                            snapshot.data == kPro
                                                ? BoxShadow(
                                                    color: Colors.black,
                                                    // spreadRadius: 1,
                                                    blurRadius: 4,
                                                    offset: Offset(-3,
                                                        3), // changes position of shadow
                                                  )
                                                : BoxShadow(),
                                          ],
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: MoreGradientColors.lunada,
                                          )),
                                      child: Icon(
                                        FontAwesomeIcons.gamepad,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    );
                                  }),
                            ),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Expanded(flex: 1, child: Text(G.current.usertypepro)),
                        ],
                      ),
                    ),
                  ),

                  ///Streamer
                  Expanded(
                    flex: 1,
                    child: Container(
                      child: Column(
                        children: [
                          Expanded(
                            flex: 2,
                            child: GestureDetector(
                              onTap: () {
                                catagories.first.then((value) async {
                                  if (value != kStreamer) {
                                    catagories.add(kStreamer);
                                    final cata = await catagories.first;
                                    final gen = await gender.first;
                                    _homeBloc.fetchData(
                                        type: cata, gender: gen);
                                  }
                                });
                                // if (catagories != 2) {
                                //   catagories = 2;
                                //   _homeBloc.fetchData(
                                //       type: catagories, gender: gender);
                                // } else {
                                //   print("Already");
                                // }
                              },
                              child: StreamBuilder<int>(
                                  stream: catagories,
                                  builder: (context, snapshot) {
                                    return Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                          boxShadow: [
                                            snapshot.data == kStreamer
                                                ? BoxShadow(
                                                    color: Colors.black,
                                                    // spreadRadius: 1,
                                                    blurRadius: 4,
                                                    offset: Offset(-3,
                                                        3), // changes position of shadow
                                                  )
                                                : BoxShadow(),
                                          ],
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: MoreGradientColors.hazel,
                                          )),
                                      child: Icon(
                                        FontAwesomeIcons.twitch,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    );
                                  }),
                            ),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Expanded(
                              flex: 1, child: Text(G.current.usertypestreamer)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  newmalefemale() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Card(
        key: intro.keys[1],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        shadowColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.black
            : Colors.grey,
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.only(top: 15, bottom: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //Male
                    GestureDetector(
                      onTap: () {
                        gender.first.then((value) async {
                          if (value != "Male") {
                            gender.add("Male");
                            final cata = await catagories.first;
                            final gen = await gender.first;
                            _homeBloc.fetchData(type: cata, gender: gen);
                          } else {
                            gender.add("All");
                            final cata = await catagories.first;
                            final gen = await gender.first;
                            _homeBloc.fetchData(type: cata, gender: gen);
                          }
                        });
                        // if (gender != "Male") {
                        //   gender = "Male";
                        //   _homeBloc.fetchData(type: catagories, gender: gender);
                        // } else {
                        //   gender = "All";
                        //   _homeBloc.fetchData(type: catagories, gender: gender);
                        // }
                      },
                      child: StreamBuilder<String>(
                          stream: gender,
                          builder: (context, snapshot) {
                            return Container(
                              width: 100,
                              height: 60,
                              decoration: BoxDecoration(
                                  boxShadow: [
                                    snapshot.data == "Male"
                                        ? BoxShadow(
                                            color: Colors.black,
                                            // spreadRadius: 1,
                                            blurRadius: 4,
                                            offset: Offset(-3,
                                                3), // changes position of shadow
                                          )
                                        : BoxShadow(),
                                  ],
                                  borderRadius: BorderRadius.circular(10),
                                  // shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: MoreGradientColors.darkSkyBlue,
                                  )),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(FontAwesomeIcons.mars,
                                      color: Colors.white),
                                  Text(G.current.genderMale)
                                ],
                              ),
                            );
                          }),
                    ),
                  ],
                ),
              ),
              Container(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        gender.first.then((value) async {
                          if (value != "Female") {
                            gender.add("Female");
                            final cata = await catagories.first;
                            final gen = await gender.first;
                            _homeBloc.fetchData(type: cata, gender: gen);
                          } else {
                            gender.add("All");
                            final cata = await catagories.first;
                            final gen = await gender.first;
                            _homeBloc.fetchData(type: cata, gender: gen);
                          }
                        });
                        // if (gender != "Female") {
                        //   gender = "Female";
                        //   _homeBloc.fetchData(type: catagories, gender: gender);
                        // } else {
                        //   gender = "All";
                        //   _homeBloc.fetchData(type: catagories, gender: gender);
                        // }
                      },
                      child: StreamBuilder<String>(
                          stream: gender,
                          builder: (context, snapshot) {
                            return Container(
                              width: 100,
                              height: 60,
                              decoration: BoxDecoration(
                                  boxShadow: [
                                    snapshot.data == "Female"
                                        ? BoxShadow(
                                            color: Colors.black,
                                            // spreadRadius: 1,
                                            blurRadius: 4,
                                            offset: Offset(-3,
                                                3), // changes position of shadow
                                          )
                                        : BoxShadow(),
                                  ],
                                  borderRadius: BorderRadius.circular(10),
                                  // shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: MoreGradientColors.instagram,
                                  )),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(FontAwesomeIcons.venus,
                                      color: Colors.white),
                                  Text(G.current.genderFemale)
                                ],
                              ),
                            );
                          }),
                    ),
                  ],
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
    return Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? Colors.grey[200]
            : null,
        appBar: HomeAppBar(),
        body: BlocProvider.value(
          value: _homeBloc,
          child: SafeArea(
            child: StreamBuilder<List<Post>>(
                initialData: [],
                stream: _homeBloc.postsSubject,
                builder: (context, snapshot) {
                  return SmartRefresher(
                    controller: _homeBloc.refreshController,
                    header: WaterDropHeader(),
                    footer: ShimmerFooter(
                      text: CupertinoActivityIndicator(),
                    ),
                    enablePullDown: true,
                    onRefresh: () {
                      _homeBloc.refreshData();
                    },
                    child: CustomScrollView(
                        controller: widget.homecontroller,
                        physics: AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverAppBar(
                            floating: true,
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            collapsedHeight: 100,
                            flexibleSpace: newtopTabs(widget.homecontroller),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            sliver: SliverToBoxAdapter(
                              child: newmalefemale(),
                            ),
                          ),
                          if (snapshot.hasError)
                            SliverToBoxAdapter(
                              child: SizedBox(
                                  child: ViewStateErrorWidget(
                                error: ViewStateError(
                                    snapshot.error == "No Internet Connection"
                                        ? ViewStateErrorType.networkTimeOutError
                                        : ViewStateErrorType.defaultError,
                                    errorMessage: snapshot.error),
                                onPressed: () {
                                  _homeBloc.refreshData();
                                  _homeBloc.postsSubject.add([]);
                                },
                              )),
                            ),
                          if (snapshot.hasData)
                            if (snapshot.data.isEmpty)
                              SliverToBoxAdapter(
                                child: SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.5,
                                    child: Center(
                                        child: CupertinoActivityIndicator())),
                              ),
                          if (snapshot.hasData)
                            if (snapshot.data.isNotEmpty)
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                  if (index >= snapshot.data.length) {
                                    return Center(
                                        child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12.0),
                                      child: CupertinoActivityIndicator(),
                                    ));
                                  }
                                  Post item = snapshot.data[index];
                                  return PostItemWidget(item, index: index);
                                },
                                    childCount: _homeBloc.hasReachedMax
                                        ? snapshot.data.length
                                        : snapshot.data.length + 1),
                              ),
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
      if (_debounce?.isActive ?? false) _debounce.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        _homeBloc.fetchMoreData();
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
                    child: ViewStateErrorWidget(
                  error: ViewStateError(
                      snapshot.error == "No Internet Connection"
                          ? ViewStateErrorType.networkTimeOutError
                          : ViewStateErrorType.defaultError,
                      errorMessage: snapshot.error),
                  onPressed: () {
                    BlocProvider.of<HomeBloc>(context).refreshData();
                    BlocProvider.of<HomeBloc>(context).postsSubject.add([]);
                  },
                ));
              }
              if (snapshot.data.isEmpty) {
                return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: Center(child: CupertinoActivityIndicator()));
              }
              return ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                addAutomaticKeepAlives: true,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  if (index >= snapshot.data.length) {
                    return Center(
                        child: Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: CupertinoActivityIndicator(),
                    ));
                  }
                  Post item = snapshot.data[index];
                  return PostItemWidget(item, index: index);
                },
                itemCount: BlocProvider.of<HomeBloc>(context).hasReachedMax
                    ? snapshot.data.length
                    : snapshot.data.length + 1,
              );
            }),
      ),
    );
  }
}
