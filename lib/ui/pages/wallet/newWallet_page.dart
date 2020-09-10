import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/appbar/appbarlogo.dart';
import 'package:moonblink/base_widget/container/shadedContainer.dart';
import 'package:moonblink/base_widget/container/titleContainer.dart';

class WalletPage extends StatefulWidget {
  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.black,
            actions: [
              AppbarLogo(),
            ],
          ),
          SliverToBoxAdapter(
            child: Stack(
              children: [
                Container(
                  color: Colors.black,
                  height: 200,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 150),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(50.0)),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 30, horizontal: 50),
                  child: TitleContainer(
                    height: 100,
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: Center(
                        child: Text(
                      "My Coin",
                      style: TextStyle(fontSize: 30),
                    )),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 200),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ShadedContainer(
                              ontap: () {
                                print("TOp");
                              },
                              child: Text("Top Up"),
                            ),
                            ShadedContainer(
                              ontap: () {
                                print("cash");
                              },
                              child: Text("Cash Out"),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 20,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black,
                                spreadRadius: 1,
                                // blurRadius: 2,
                                offset:
                                    Offset(-5, 5), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Text(
                            "10000 KS",
                            style: TextStyle(fontSize: 32),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Divider(
                        height: 3,
                        color: Colors.grey,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          "Top Up History",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
