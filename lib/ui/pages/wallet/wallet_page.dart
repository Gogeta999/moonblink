import 'package:flutter/material.dart';
import 'package:moonblink/global/router_manager.dart';

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
          title: Text('Wallet'),
          bottom: TabBar(
            tabs: <Widget>[Tab(text: 'Top Up'), Tab(text: 'Transaction')],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            TopUpPage(),
            UserTransactionPage(),
          ],
        ),
      ),
    );
  }
}
