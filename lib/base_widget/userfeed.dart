import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/profile_widgets.dart';
import 'package:moonblink/generated/l10n.dart';

class Feed extends StatefulWidget {
  final String partnerName;
  final int partnerId;
  final double partnerRating;
  Feed(this.partnerName, this.partnerId, this.partnerRating);
  @override
  _Feed createState() => new _Feed();
}

class _Feed extends State<Feed> with TickerProviderStateMixin {
  List<Tab> _tabs;
  List<Widget> _pages;
  TabController _controller;

  @override
  Widget build(BuildContext context) {
    _tabs = [
      Tab(text: S.of(context).rating),
      Tab(text: S.of(context).history),
    ];
    _pages = [
      PartnerRatingWidget(widget.partnerName, widget.partnerRating),
      PartnerGameHistoryWidget(widget.partnerName, widget.partnerId),
    ];
    _controller = TabController(
      length: _tabs.length,
      vsync: this,
    );
    return new Padding(
      padding: const EdgeInsets.all(16.0),
      child: new Column(
        children: <Widget>[
          new TabBar(
            labelColor: Theme.of(context).accentColor,
            controller: _controller,
            tabs: _tabs,
            indicatorColor: Theme.of(context).accentColor,
          ),
          new SizedBox.fromSize(
            size: const Size.fromHeight(300.0),
            child: new TabBarView(
              controller: _controller,
              children: _pages,
            ),
          ),
        ],
      ),
    );
  }
}
