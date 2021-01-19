import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gradient_colors/flutter_gradient_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moonblink/base_widget/blinkIcon_Widget.dart';
import 'package:moonblink/base_widget/customDialog_widget.dart';
import 'package:moonblink/base_widget/customnavigationbar/src/convex_appBar/convex_bottom_bar.dart';
import 'package:moonblink/base_widget/customnavigationbar/src/convex_appBar/convex_items.dart';
import 'package:moonblink/base_widget/intro/flutter_intro.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/resources_manager.dart';
import 'package:moonblink/models/post.dart';
import 'package:moonblink/ui/pages/main/home/home_page.dart';
import 'package:moonblink/utils/constants.dart';

class HomePageDummy extends StatefulWidget {
  HomePageDummy({Key key}) : super(key: key);

  @override
  _HomePageDummyState createState() => _HomePageDummyState();
}

class _HomePageDummyState extends State<HomePageDummy> {
  Intro intro;

  _HomePageDummyState() {
    intro = Intro(
      stepCount: 1,
      borderRadius: BorderRadius.circular(15),
      onfinish: () {
        intro.dispose();
        Future.delayed(Duration(microseconds: 0), () {
          coplayerrules();
        });
      },

      /// use defaultTheme, or you can implement widgetBuilder function yourself
      widgetBuilder: StepWidgetBuilder.useDefaultTheme(
        texts: [
          'You will be in one of these tabs',
        ],
        buttonTextBuilder: (curr, total) {
          return curr < total - 1 ? 'Next' : 'Finish';
        },
      ),
    );
  }

  List<Post> posts = [];
  bool _isPageLoading = true;

  @override
  void initState() {
    _initData();
    super.initState();
  }

  void _initData() async {
    await Future.wait([
      loadJson(),
    ], eagerError: true)
        .then((value) {
      print("Debug: Then");
      setState(() {
        _isPageLoading = false;
      });
    }).whenComplete(() async {
      print("Debug: Complete");
      await Future.delayed(Duration(milliseconds: 1000));
      print("Debug: Start");
      intro.start(context);
    });
  }

  coplayerrules() {
    return showDialog(
      context: context,
      builder: (_) {
        return CustomDialog(
          outsideDismiss: false,
          isCancel: false,
          isContentLong: true,
          title: "Co-player rule",
          confirmButtonColor: Theme.of(context).accentColor,
          confirmContent: "Confirm",
          confirmCallback: () {
            Navigator.pop(context);
          },
          simpleContent:
              ("1. Customer booking ကိုလက်ခံပြီးလျှင်သူကစားမယ်ဘယ်ဂိမ်းမဆို voice chat ဖွင့်ပေးရမည်။\n2. Customer ကိုစိတ်ကြေနပ်အောင်ကစားပေးရမည်။ (Rating ကောင်းလျှင်လူများပို၍မြင်နိုင်သည်)\n3. လက်ခံပြီးလျှင်ဂိမ်းကစားပေးရပါမည်။ Customer ဘက်က report လာ၍အချက်လက်မှန်ကန်ပါက warning ပေးပြီး coin ပြန်ဖျက်သိမ်းပါမည်။ ဒုတိယတစ်ခါဖြစ်လျှင် account ban ပါမည်။\n4. မိမိ၏လှပသောပုံများကို post တင်ခြင်းဖြင့် customer များ follow လာလုပ်မည်။\n5. တခြား media profile များ screenshot ရိုက်ပြီးပုံတင်ခွင့်မရှိပါ။"),
        );
      },
    );
  }

  Future loadJson() async {
    String data = await DefaultAssetBundle.of(context)
        .loadString('assets/json/home.json');
    var jsonResult = json.decode(data);
    var results = jsonResult['data']['data']
        .map<Post>((item) => Post.fromJson(item))
        .toList();
    setState(() {
      posts = results;
    });
  }

  newtopTabs() {
    return Card(
      margin: EdgeInsets.zero,
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
                    child: Column(
                      children: [
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black,
                                    // spreadRadius: 1,
                                    blurRadius: 4,
                                    offset: Offset(
                                        -3, 3), // changes position of shadow
                                  )
                                ],
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: MoreGradientColors.azureLane,
                                ),
                              ),
                              child: Icon(Icons.supervisor_account,
                                  size: 23, color: Colors.white),
                            ),
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
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(),
                                  ],
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: MoreGradientColors.orangePinkTeal,
                                  )),
                              child: Icon(
                                FontAwesomeIcons.star,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Expanded(flex: 1, child: Text(G.current.usertypecele)),
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
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(),
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
                            ),
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
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(),
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
                            ),
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

                ///UnverifiedPartner
                Expanded(
                  flex: 1,
                  child: Container(
                    key: intro.keys[0],
                    child: Column(
                      children: [
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(),
                                  ],
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: MoreGradientColors.darkSkyBlue,
                                  )),
                              child: Icon(
                                FontAwesomeIcons.userAstronaut,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Expanded(
                            flex: 1, child: Text(G.current.usertypeUnverified)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  newmalefemale() {
    return Card(
      margin: EdgeInsets.zero,
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
                    onTap: () {},
                    child: Container(
                      width: 100,
                      height: 60,
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black,
                              // spreadRadius: 1,
                              blurRadius: 4,
                              offset:
                                  Offset(-3, 3), // changes position of shadow
                            )
                          ],
                          borderRadius: BorderRadius.circular(10),
                          // shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: MoreGradientColors.coolSky,
                          )),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(FontAwesomeIcons.mars, color: Colors.white),
                          Text(G.current.genderMale)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 100,
                      height: 60,
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black,
                              // spreadRadius: 1,
                              blurRadius: 4,
                              offset:
                                  Offset(-3, 3), // changes position of shadow
                            )
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
                          Icon(FontAwesomeIcons.venus, color: Colors.white),
                          Text(G.current.genderFemale)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget postprofile(posts) {
    return posts.profileImage == null
        ? Icon(Icons.error)
        : CachedNetworkImage(
            imageUrl: posts.profileImage,
            imageBuilder: (context, imageProvider) => CircleAvatar(
              radius: 41,
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey
                  : Colors.black,
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.transparent,
                backgroundImage: imageProvider,
                child: GestureDetector(),
              ),
            ),
            placeholder: (context, url) => Padding(
              padding: const EdgeInsets.only(top: 12, left: 15),
              child: CupertinoActivityIndicator(),
            ),
            errorWidget: (context, url, error) => CircleAvatar(
              radius: 41,
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey
                  : Colors.grey.shade600,
              // color: Colors.grey.shade600,
              child: IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.error,
                  color: Colors.grey.shade300,
                ),
              ),
            ),
          );
  }

  //Block Button
  Widget blockbtn() {
    return IconButton(icon: Icon(Icons.more_vert), onPressed: () {});
  }

  ///VIP
  Widget vipText(int vip) {
    switch (vip) {
      case 0:
        return Text(
          'VIP 0',
          style: TextStyle(color: Colors.grey.shade600),
        );
        break;
      case 1:
        return Text(
          'VIP 1',
          style: TextStyle(color: Colors.grey.shade600),
        );
        break;
      case 2:
        return Text(
          'VIP 2',
          style: TextStyle(color: Colors.grey.shade600),
        );
        break;
      case 3:
        return Text(
          'VIP 3',
          style: TextStyle(color: Colors.grey.shade600),
        );
        break;
      default:
        return Container();
        break;
    }
  }

  //Status
  Widget statusText(int status) {
    switch (status) {
      case ONLINE:
        return Text(
          G.of(context).statusOnline,
          style: TextStyle(color: Colors.green),
        );
        break;
      case BUSY:
        return Text(
          G.of(context).statusbusy,
          style: TextStyle(color: Colors.redAccent),
        );
        break;
      case AWAY:
        return Text(
          G.of(context).statusavailable,
          style: TextStyle(color: Colors.green[300]),
        );
        break;
      case IN_GAME:
        return Text(
          G.of(context).statusingame,
          style: TextStyle(color: Colors.blue),
        );
        break;
      case BAN:
        return Text(
          'Ban',
          style: TextStyle(color: Colors.red),
        );
        break;
      default:
        return Text(
          G.of(context).statuserror,
          style: TextStyle(color: Colors.red),
        );
        break;
    }
  }

  ///VIP
  Widget gemColor(int vip) {
    switch (vip) {
      case 0:
        return Icon(
          IconFonts.vipGem,
          color: Color.fromRGBO(0, 0, 0, 0),
        );
        break;
      case 1:
        return Icon(IconFonts.vipGem, color: Color.fromRGBO(169, 113, 66, 5));
        break;
      case 2:
        return Icon(
          IconFonts.vipGem,
          color: Color.fromRGBO(216, 216, 216, 5),
        );
        break;
      case 3:
        return Icon(
          IconFonts.vipGem,
          color: Color.fromRGBO(225, 215, 0, 5),
        );
        break;
      default:
        return Container();
        break;
    }
  }

  Widget postitemwidget(posts) {
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          shadowColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.black
              : Colors.grey,
          elevation: 4,
          child: Container(
              width: double.infinity,
              height: 120,
              // color: Colors.red,
              child: Flex(
                direction: Axis.horizontal,
                children: [
                  Expanded(flex: 3, child: postprofile(posts)),
                  Expanded(
                      flex: 5,
                      child: Stack(
                        children: [
                          Positioned(
                            top: 20,
                            child: Row(
                              children: [
                                Text(posts.userName,
                                    style: posts.id == 62
                                        ? TextStyle(
                                            color:
                                                Theme.of(context).accentColor)
                                        : Theme.of(context)
                                            .textTheme
                                            .bodyText1),
                                Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: gemColor(posts.vip)),
                                Padding(
                                    padding: EdgeInsets.only(left: 3),
                                    child: vipText(posts.vip)),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 43,
                            child: Text(posts.bios,
                                style: posts.id == 62
                                    ? TextStyle(
                                        color: Theme.of(context).accentColor)
                                    : Theme.of(context).textTheme.caption),
                          ),

                          //Status
                          Positioned(
                            bottom: 20,
                            child: statusText(posts.status),
                          )
                        ],
                      )),
                  Expanded(
                      flex: 3,
                      child: Stack(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        // crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Positioned(top: -5, right: 0, child: blockbtn()),
                          Positioned(
                            // top: 50,
                            bottom: 25,
                            // right: 22,
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: Container(
                                    child: BlinkWidget(
                                      children: [
                                        Icon(FontAwesomeIcons.book),
                                        Icon(
                                          FontAwesomeIcons.book,
                                          // size: 30,
                                          color: Colors.green,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Icon(
                                    posts.isReacted == 0
                                        ? FontAwesomeIcons.heart
                                        : FontAwesomeIcons.solidHeart,
                                    size: 30,
                                    color: posts.isReacted == 0
                                        ? Theme.of(context).iconTheme.color
                                        : Colors.red[400]),
                                Container(
                                  margin: const EdgeInsets.only(right: 15),
                                  child: CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    child: Icon(FontAwesomeIcons.share),
                                    onPressed: () {},
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                              bottom: 5,
                              child: Text(
                                  '${posts.reactionCount} ${G.of(context).likes}'))
                        ],
                      )),
                ],
              )),
        ),
        Divider(
          height: 1,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(),
      body: _isPageLoading || posts.isEmpty
          ? CupertinoActivityIndicator()
          : CustomScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverAppBar(
                  floating: true,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  collapsedHeight: 100,
                  flexibleSpace: newtopTabs(),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  sliver: SliverToBoxAdapter(
                    child: newmalefemale(),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      Post item = posts[index];
                      return postitemwidget(item);
                    },
                    childCount: posts.length,
                  ),
                ),
              ],
            ),
      bottomNavigationBar: ConvexAppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        style: TabStyle.fixedCircle,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.black
            : Theme.of(context).accentColor,
        items: [
          TabItem(
            icon: Image.asset(
              'images/mainTab/home.png',
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
            activeIcon: Image.asset(
              'images/mainTab/home1.png',
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
          TabItem(
            icon: Image.asset(
              'images/mainTab/following.png',
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
            activeIcon: Image.asset(
              'images/mainTab/following1.png',
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
          TabItem(
            icon: Icon(
              FontAwesomeIcons.plus,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.white,
            ),
            activeIcon: Icon(
              FontAwesomeIcons.plus,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black
                  : Colors.black,
            ),
          ),
          TabItem(
            icon: Image.asset(
              'images/mainTab/chat.png',
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
            activeIcon: Image.asset(
              'images/mainTab/chat1.png',
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
          TabItem(
            icon: Image.asset(
              'images/mainTab/mainProfile.png',
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
            activeIcon: Image.asset(
              'images/mainTab/mainProfile1.png',
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
        ],
        initialActiveIndex: 1 /*optional*/,
      ),
    );
  }
}
