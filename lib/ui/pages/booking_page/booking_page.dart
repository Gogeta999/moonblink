import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moonblink/base_widget/MoonBlink_Box_widget.dart';
import 'package:moonblink/base_widget/appbar/appbarlogo.dart';
import 'package:moonblink/global/resources_manager.dart';
import 'package:moonblink/models/partner.dart';
import 'package:moonblink/ui/helper/cached_helper.dart';
import 'package:oktoast/oktoast.dart';

class BookingPage extends StatefulWidget {
  BookingPage({Key key, this.partnerUser}) : super(key: key);
  final PartnerUser partnerUser;
  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  int _matchNumber = 1;
  void add() {
    setState(() {
      _matchNumber++;
    });
  }

  void minus() {
    setState(() {
      if (_matchNumber != 1) _matchNumber--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Confirm Your Booking'),
        leading: IconButton(
            icon: Icon(CupertinoIcons.back),
            onPressed: () {
              Navigator.pop(context);
            }),
        // elevation: 15,
        // shadowColor: Colors.blue,
        bottom: PreferredSize(
            child: Container(
              height: 10,
              color: Theme.of(context).accentColor,
            ),
            preferredSize: null),
      ),
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          //Top Partner Information
          Padding(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 20),
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Theme.of(context).cardColor,
                // border:
                //     Border.all(color: Colors.black, style: BorderStyle.none),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.all(3),
                    child: CachedNetworkImage(
                      imageUrl:
                          widget.partnerUser.prfoileFromPartner.profileImage,
                      imageBuilder: (context, item) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(width: 2, color: Colors.black),
                          ),
                          child: CircleAvatar(
                            radius: 45,
                            backgroundImage: item,
                          ),
                        );
                      },
                      fit: BoxFit.cover,
                      placeholder: (context, url) => CachedLoader(
                        containerHeight: 50,
                        containerWidth: 50,
                      ),
                      errorWidget: (context, url, error) => CachedError(),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 200),
                    child: Text(
                      widget.partnerUser.partnerName,
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                  )
                ],
              ),
            ),
          ),
          Column(
            children: [
              ///[Game]
              Card(
                  child: Container(
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(
                          'Choos Games',
                          style: Theme.of(context).textTheme.subtitle1,
                        )),
                    Text('PUBG')
                  ],
                ),
              )),

              ///[Game's Mode]
              Card(
                  child: Container(
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(
                          'Game Mode',
                          style: Theme.of(context).textTheme.subtitle1,
                        )),
                    Icon(FontAwesomeIcons.arrowRight)
                  ],
                ),
              )),

              ///[Match Count]
              Card(
                  child: Container(
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(
                          'Match',
                          style: Theme.of(context).textTheme.subtitle1,
                        )),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Container(
                        width: 100,
                        decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.black),
                            borderRadius: BorderRadius.circular(20)),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: minus,
                                child: Icon(Icons.remove),
                              ),
                              Container(
                                height: 100,
                                width: 1,
                                color: Colors.black,
                              ),
                              Text(_matchNumber.toString()),
                              Container(
                                height: 100,
                                width: 1,
                                color: Colors.black,
                              ),
                              GestureDetector(
                                onTap: add,
                                child: Icon(Icons.add),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )),

              Card(
                  child: Container(
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Image.asset(
                          ImageHelper.wrapAssetsLogo('appbar.jpg'),
                          height: 50,
                          width: 100,
                          fit: BoxFit.contain,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.black
                              : Colors.black,
                          colorBlendMode: BlendMode.srcIn,
                        )),
                    Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Total Price',
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                            Text(
                              '100 Coins',
                              style: Theme.of(context).textTheme.subtitle2,
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              )),
            ],
          )
        ],
      ),
      bottomNavigationBar: Container(
        width: MediaQuery.of(context).size.width,
        height: 68,
        decoration: BoxDecoration(
            color: Theme.of(context).bottomAppBarColor,
            border: Border(top: BorderSide(width: 2, color: Colors.black))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                child: Text(
              'Total Price: 1000 Coins',
              style: Theme.of(context).textTheme.subtitle1,
            )),
            // MBButtonWidget(
            //   onTap: null,
            //   title: 'Button',
            // )
            // Container(child: Text('1000 Coins')),
            SizedBox(
              width: 40,
            ),
            Container(
              child: Center(
                child: Text(
                  'Confirm',
                  style: Theme.of(context).textTheme.button,
                ),
              ),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Theme.of(context).accentColor,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black
                          : Colors.black,
                      spreadRadius: 2,
                      // blurRadius: 2,
                      offset: Offset(-8, 7), // changes position of shadow
                    ),
                  ]),
              width: 100,
              height: 45,
            )
          ],
        ),
      ),
    );
  }
}
