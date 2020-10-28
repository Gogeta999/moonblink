import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/appbar/appbar.dart';

class UserLevelPage extends StatefulWidget {
  @override
  _UserLevelPageState createState() => _UserLevelPageState();
}

class _UserLevelPageState extends State<UserLevelPage> {
  space10() {
    return SizedBox(
      height: 10,
    );
  }

  space20() {
    return SizedBox(
      height: 20,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: ListView(
          children: [
            Center(
              child: Text(
                "Acc level guideline",
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            space20(),
            Text(
                "Acc level means when you get order platform will take the service charges in every order of the game price(coin)"),
            space10(),
            Text(
                "eg; if you get an order and your order price is 100coins platform will charge the 30%percentage of the coin  so you will get 70coin in order "),
            space20(),
            Text(
              "Acc Level zero",
              style: Theme.of(context).textTheme.headline6,
            ),
            Text(
                "You can get 50% of the game price(coin per order) at the level zero of your account."),
            space10(),
            Text(
              "Acc Level one",
              style: Theme.of(context).textTheme.headline6,
            ),
            Text(
                "You can get 55% of the game price(coin per order) at the first level of your account when your order reaches the amount of 100orders.(orders amount will change depending on the platform)."),
            space10(),
            Text(
              "Acc Level two",
              style: Theme.of(context).textTheme.headline6,
            ),
            Text(
                "You can get 60% of the game price(coin per order) at level two of your account when your order reaches the amount of 100orders(orders amount will change depending on the platform)."),
            space10(),
            Text(
              "Acc Level three",
              style: Theme.of(context).textTheme.headline6,
            ),
            Text(
                "You can get 65% of the game price(coin per order) at level three of your account when your order reaches the amount of 120orders(orders amount will change depending on the platform)."),
            space10(),
            Text(
              "Acc Level four",
              style: Theme.of(context).textTheme.headline6,
            ),
            Text(
                "You can get 70% of the game price(coin per order) at level four of your account when your order reaches the amount of 120orders(orders amount will change depending on the platform)."),
            space10(),
            Text(
              "Acc Level five",
              style: Theme.of(context).textTheme.headline6,
            ),
            Text(
                "You can get 75% of the game price(coin per order) at level five of your account when your order reaches the amount of 150orders(orders amount will change depending on the platform)."),
            space10(),
            Text(
              "Acc Level six",
              style: Theme.of(context).textTheme.headline6,
            ),
            Text(
                "You can get 80% of the game price(coin per order) at level six of your account when your order reaches the amount of 200orders(orders amount will change depending on the platform)."),
            space10(),
            Text(
              "Acc Level seven",
              style: Theme.of(context).textTheme.headline6,
            ),
            Text(
                "You can get 85% of the game price(coin per order) at level seven of your account when your order reaches the amount of 250orders(orders amount will change depending on the platform)."),
            space10(),
            Text(
              "Acc Level eight",
              style: Theme.of(context).textTheme.headline6,
            ),
            Text(
                "You can get 90% of the game price(coin per order) at level eight of your account when your order reaches the amount of 300orders(orders amount will change depending on the platform)."),
            space20(),
            Text(
              "Note: Co players will only upgrade one level per a month.",
              style: Theme.of(context).textTheme.headline6,
            ),
          ],
        ),
      ),
    );
  }
}
