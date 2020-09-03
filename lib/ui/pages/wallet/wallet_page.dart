import 'package:flutter/material.dart';
import 'package:moonblink/generated/l10n.dart';
import 'topup_page.dart';
import 'user_transaction_page.dart';

class WalletPage extends StatefulWidget {
  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(G.of(context).userStatusWallet),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(text: G.of(context).topup),
              Tab(text: G.of(context).transaction)
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            /*MyApp(),*/TopUpPage(),
            UserTransactionPage(),
          ],
        ),
      ),
    );
  }
}
