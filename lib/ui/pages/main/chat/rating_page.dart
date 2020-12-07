import 'dart:async';

import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/appbar/appbarlogo.dart';
import 'package:moonblink/base_widget/container/shadedContainer.dart';
import 'package:moonblink/base_widget/container/titleContainer.dart';
import 'package:moonblink/base_widget/intro/flutter_intro.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/ui/helper/tutorial.dart';
import 'package:moonblink/view_model/rate_model.dart';
import 'package:oktoast/oktoast.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class RatingPage extends StatefulWidget {
  final int userid;
  final int bookingid;
  RatingPage(this.bookingid, this.userid);
  @override
  _RatingPageState createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  Intro intro;
  double rate = 0;
  TextEditingController comment = TextEditingController();

  _RatingPageState() {
    intro = Intro(
      stepCount: 5,
      onfinish: () {
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(15),

      /// use defaultTheme, or you can implement widgetBuilder function yourself
      widgetBuilder: StepWidgetBuilder.useDefaultTheme(
        texts: [
          G.current.tutorialRating1,
          G.current.tutorialRating2,
          G.current.tutorialRating3,
          G.current.tutorialRating4,
          G.current.tutorialRating5,
        ],
        buttonTextBuilder: (curr, total) {
          return curr < total - 1 ? 'Next' : 'Finish';
        },
      ),
    );
  }

  @override
  void initState() {
    bool tuto = StorageManager.sharedPreferences.getBool(chatboxtuto);
    if (tuto) {
      Timer(Duration(microseconds: 0), () {
        intro.start(context);
      });
      StorageManager.sharedPreferences.setBool(chatboxtuto, false);
    }
    super.initState();
  }

  @override
  void dispose() {
    Timer(Duration(microseconds: 0), () {
      /// start the intro
      intro.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProviderWidget<RateModel>(
      model: RateModel(),
      builder: (context, model, child) {
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              key: intro.keys[0],
              leading: Container(),
              backgroundColor: Colors.black,
              actions: [
                AppbarLogo(),
              ],
            ),
            body: ListView(
              children: [
                Stack(
                  children: [
                    Container(
                      color: Colors.black,
                      height: MediaQuery.of(context).size.height / 2.5,
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 30, horizontal: 50),
                      child: TitleContainer(
                        height: 100,
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: Center(
                          child: Text(
                            G.of(context).rateplayer,
                            style: TextStyle(fontSize: 30),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: 200, left: 20, right: 20, bottom: 30),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Column(
                          children: [
                            Container(
                              key: intro.keys[1],
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: SmoothStarRating(
                                starCount: 5,
                                rating: rate,
                                color: Theme.of(context).accentColor,
                                isReadOnly: false,
                                size: 40,
                                filledIconData: Icons.star,
                                halfFilledIconData: Icons.star_half,
                                defaultIconData: Icons.star_border,
                                allowHalfRating: true,
                                spacing: 10.0,
                                //star value
                                onRated: (value) {
                                  print("rating value -> $value");
                                  setState(() {
                                    rate = value;
                                  });
                                },
                              ),
                            ),
                            SizedBox(
                              height: 50,
                            ),
                            Row(
                              key: intro.keys[2],
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SmallShadedContainer(
                                  selected: rate <= 2,
                                  child: Center(
                                    child: Text("Bad"),
                                  ),
                                ),
                                SmallShadedContainer(
                                  selected: rate < 5 && rate > 2,
                                  child: Center(
                                    child: Text("Good"),
                                  ),
                                ),
                                SmallShadedContainer(
                                  selected: rate == 5,
                                  child: Center(
                                    child: Text("Exellent"),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              key: intro.keys[3],
                              padding: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 18),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1.5, color: Colors.black),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30.0)),
                              ),
                              child: TextField(
                                textAlign: TextAlign.center,
                                maxLines: null,
                                controller: comment,
                                textInputAction: TextInputAction.done,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  hintText: G.of(context).labelcomment,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ShadedContainer(
                      ontap: () {
                        model.rate(
                            widget.userid, widget.bookingid, 5, comment.text);
                        Navigator.pop(context);
                      },
                      child: Text(G.of(context).cancel),
                    ),
                    SizedBox(
                      width: 30,
                    ),
                    ShadedContainer(
                      key: intro.keys[4],
                      ontap: () {
                        // Navigator.pop(context);
                        model
                            .rate(widget.userid, widget.bookingid, rate,
                                comment.text)
                            .then((value) => value
                                ? Navigator.pop(context)
                                : showToast(G.of(context).toastratingfail));
                      },
                      child: Text(G.of(context).submit),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
