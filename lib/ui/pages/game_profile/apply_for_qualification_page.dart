import 'package:flutter/material.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:oktoast/oktoast.dart';

class ApplyForQualification extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(G.of(context).applyforqualification),
      ),
      body: ListView(
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
        children: <Widget>[Entertainment(), Games()],
      ),
    );
  }
}

class Entertainment extends StatelessWidget {
  _buildIconWithText(IconData iconData, String text, Function onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(iconData, size: 46),
          SizedBox(height: 5),
          Text(text,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 10, left: 10),
          child: Text(G.of(context).entertainment,
              style: Theme.of(context).textTheme.bodyText1),
        ),
        GridView(
          addAutomaticKeepAlives: true,
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
          ),

          ///if items come from api will need to use builder.
          children: <Widget>[
            _buildIconWithText(
                Icons.image, 'Singing', () => showToast('onTap')),
            _buildIconWithText(
                Icons.image, 'Singing', () => showToast('onTap')),
            _buildIconWithText(
                Icons.image, 'Singing', () => showToast('onTap')),
            _buildIconWithText(
                Icons.image, 'Singing', () => showToast('onTap')),
          ],
        )
      ],
    );
  }
}

class Games extends StatelessWidget {
  _buildIconWithText(IconData iconData, String text, Function onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(iconData, size: 46),
          SizedBox(height: 5),
          Text(text,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text(G.of(context).games,
              style: Theme.of(context).textTheme.bodyText1),
        ),
        GridView(
          addAutomaticKeepAlives: true,
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
          ),

          ///if items come from api will need to use builder.
          children: <Widget>[
            _buildIconWithText(Icons.image, 'PUBG', () => showToast('onTap')),
            _buildIconWithText(
                Icons.image, 'VALORANT', () => showToast('onTap')),
            _buildIconWithText(Icons.image, 'PUBG MOBILE',
                () => Navigator.pushNamed(context, RouteName.pubgMobile)),
            _buildIconWithText(Icons.image, 'LOL', () => showToast('onTap')),
          ],
        )
      ],
    );
  }
}
