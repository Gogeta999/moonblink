import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moonblink/global/resources_manager.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class PartnerRatingWidget extends StatelessWidget {
  final partnerName;
  PartnerRatingWidget(this.partnerName);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(width: 1.5, color: Colors.grey),
        // color: Colors.grey,
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
      ),
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: <Widget>[
          Center(
            child: Image.asset(
              ImageHelper.wrapAssetsLogo('ratingsRabbit.png'),
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
              bottom: 85,
              child: SmoothStarRating(
                rating: 4.5,
                isReadOnly: true,
                filledIconData: Icons.star,
                halfFilledIconData: Icons.star_half,
                defaultIconData: Icons.star_border,
                color: Theme.of(context).accentColor,
                starCount: 5,
                allowHalfRating: true,
                spacing: 5,
                // onRated: (value) {
                //   print("rating value_ $value");
                // },
              )),
          Positioned(
              bottom: 60,
              child: Text(partnerName + '\'s average rating is 4.5'))
        ],
      ),
    );
  }
}

class PartnerGameHistoryWidget extends StatelessWidget {
  final partnerName;
  PartnerGameHistoryWidget(this.partnerName);
  final int a = 1;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: 7,
        itemBuilder: (context, index) {
          return Container(
            height: 70,
            // width: 1000,
            margin: EdgeInsets.fromLTRB(0, 1.5, 0, 1.5),
            decoration: BoxDecoration(
              border: Border.all(width: 1.5, color: Colors.grey),
              // color: Colors.grey,
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Image.asset(
                  ImageHelper.wrapAssetsLogo('appbar.jpg'),
                  height: 50,
                  width: 45,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Game Type Name',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    Text(
                      'Customer rated $partnerName in 4 stars',
                      style: Theme.of(context).textTheme.bodyText2,
                    )
                  ],
                ),
                Text('Date')
              ],
            ),
          );
        });
  }
}
