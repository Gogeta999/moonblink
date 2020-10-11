import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/global/storage_manager.dart';

const List<String> images = [
  'images/fb1.jpeg',
  'images/fb2.jpeg',
  'images/fb3.jpeg',
];

class FbLoginErrorPage extends StatefulWidget {
  @override
  _FbLoginErrorPageState createState() => _FbLoginErrorPageState();
}

class _FbLoginErrorPageState extends State<FbLoginErrorPage> {
  SwiperController _swiperController;
  int index = 0;

  @override
  void initState() {
    _swiperController = SwiperController();
    _swiperController.addListener(onSwipe);
    super.initState();
  }

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          // actions: <Widget>[
          //   FlatButton(
          //     // color: Colors.white,
          //     child: Text(G.of(context).splashSkip,
          //         style: Theme.of(context).accentTextTheme.bodyText1),
          //     onPressed: () {
          //       ///Define later
          //     },
          //   ),
          // ],
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
        ),
        body: Swiper(
          itemBuilder: (BuildContext context, int index) {
            return Image.asset(
              images[index],
              fit: BoxFit.fill,
            );
          },
          controller: _swiperController,
          onIndexChanged: (index) {
            setState(() {
              this.index = index;
            });
          },
          loop: false,
          autoplay: false,
          itemCount: images.length,
          pagination: SwiperPagination(),
          control: CustomSwiperControl(),
        ));
  }

  void onSwipe() {
    if (this.index + 1 == images.length) {
      ///Navigate back
      //Navigator.pushNamedAndRemoveUntil(
      //    context, RouteName.termsAndConditionsPage, (route) => false);
    }
  }
}

class CustomSwiperControl extends SwiperPlugin {
  ///IconData for previous
  final IconData iconPrevious;

  ///iconData fopr next
  final IconData iconNext;

  ///icon size
  final double size;

  ///Icon normal color, The theme's [ThemeData.primaryColor] by default.
  final Color color;

  ///if set loop=false on Swiper, this color will be used when swiper goto the last slide.
  ///The theme's [ThemeData.disabledColor] by default.
  final Color disableColor;

  final EdgeInsetsGeometry padding;

  final Key key;

  const CustomSwiperControl(
      {this.iconPrevious: Icons.arrow_back_ios,
        this.iconNext: Icons.arrow_forward_ios,
        this.color,
        this.disableColor,
        this.key,
        this.size: 30.0,
        this.padding: const EdgeInsets.all(5.0)});

  Widget buildButton(SwiperPluginConfig config, Color color, IconData iconDaga,
      int quarterTurns, bool previous) {
    return new GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (!previous) {
          config.controller.next(animation: true);
        }
        if (previous && config.activeIndex != 0) {
          config.controller.previous(animation: true);
        }
      },
      child: Padding(
          padding: padding,
          child: RotatedBox(
              quarterTurns: quarterTurns,
              child: Icon(
                iconDaga,
                semanticLabel: previous ? "Previous" : "Next",
                size: size,
                color: color,
              ))),
    );
  }

  @override
  Widget build(BuildContext context, SwiperPluginConfig config) {
    ThemeData themeData = Theme.of(context);

    Color color = this.color ?? themeData.primaryColor;
    Color prevColor;
    Color nextColor;

    if (config.loop) {
      prevColor = nextColor = color;
    } else {
      // ignore: unused_local_variable
      bool next = config.activeIndex < config.itemCount - 1;
      // ignore: unused_local_variable
      bool prev = config.activeIndex > 0;
      prevColor = color;
      nextColor = color;
    }

    Widget child;
    if (config.scrollDirection == Axis.horizontal) {
      child = Row(
        key: key,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          buildButton(config, prevColor, iconPrevious, 0, true),
          buildButton(config, nextColor, iconNext, 0, false)
        ],
      );
    } else {
      child = Column(
        key: key,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          buildButton(config, prevColor, iconPrevious, -3, true),
          buildButton(config, nextColor, iconNext, -3, false)
        ],
      );
    }

    return new Container(
      height: double.infinity,
      child: child,
      width: double.infinity,
    );
  }
}
