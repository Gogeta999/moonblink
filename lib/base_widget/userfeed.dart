import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/profile_widgets.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/ui/pages/user/user_rating_page.dart';

class Feed extends StatefulWidget {
  final String partnerName;
  final int partnerId;
  final double partnerRating;
  Feed(this.partnerName, this.partnerId, this.partnerRating);
  @override
  _Feed createState() => _Feed();
}

class _Feed extends State<Feed> with TickerProviderStateMixin {
  List<Tab> _tabs;
  List<Widget> _pages;
  TabController _controller;

  @override
  Widget build(BuildContext context) {
    _tabs = [
      Tab(text: G.of(context).rating),
      Tab(text: G.of(context).history),
    ];
    _pages = [
      // PartnerRatingWidget(widget.partnerName, widget.partnerRating),
      UserRatingPage(userId: widget.partnerId),
      PartnerGameHistoryWidget(widget.partnerName, widget.partnerId),
    ];
    _controller = TabController(
      length: _tabs.length,
      vsync: this,
    );
    return Column(
      children: <Widget>[
        TabBar(
          labelColor: Theme.of(context).textTheme.bodyText1.color,
          controller: _controller,
          tabs: _tabs,
          indicatorColor: Theme.of(context).textTheme.bodyText1.color,
        ),
        Container(
          height: MediaQuery.of(context).size.height * 0.45,
          child: TabBarView(
            controller: _controller,
            children: _pages,
          ),
        )
        /*SizedBox.fromSize(
          size: const Size.fromHeight(300.0),
          child: ,
        ),*/
      ],
    );
  }
}
