import 'package:flutter/material.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class MBButtonWidget extends StatelessWidget {
  MBButtonWidget({Key key, this.onTap, this.title}) : super(key: key);
  final Function onTap;
  final title;
  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      child: Container(
        height: 80,
        width: 160,
        child: Center(
          child: Text(
            title,
            style: Theme.of(context).textTheme.button,
          ),
        ),
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border.all(width: 1, color: Colors.black),
            borderRadius: BorderRadius.circular(20.0),
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
      ),
    );
  }
}

class MB2StateButtonWidget extends StatelessWidget {
  MB2StateButtonWidget(
      {Key key, this.trueText, this.falseText, this.active, this.onChanged})
      : super(key: key);
  // final Function onTap;
  final trueText;
  final falseText;
  final bool active;
  final ValueChanged<bool> onChanged;
  void _handleTap() {
    onChanged(!active);
  }

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: _handleTap,
      child: Container(
        height: 80,
        width: 160,
        child: Center(
          child: Text(
            active ? trueText : falseText,
            style: Theme.of(context).textTheme.button,
          ),
        ),
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border.all(width: 1, color: Colors.black),
            borderRadius: BorderRadius.circular(20.0),
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
      ),
    );
  }
}

class MBBoxWidget extends StatelessWidget {
  MBBoxWidget({Key key, this.ontap, this.text, this.followers})
      : super(key: key);
  final ontap;
  final text;
  final followers;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ontap,
      child: Container(
        height: 100,
        width: 160,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            // Icon(
            //   iconData,
            //   color: Colors.white,
            //   size: 30.0,
            // ),
            Center(
              child: Text(text,
                  style: Theme.of(context).textTheme.bodyText1,
                  // TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                  softWrap: true),
            ),
            Text(
              followers,
              style: Theme.of(context).textTheme.button,
              softWrap: true,
            )
          ],
        ),
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border.all(width: 1, color: Colors.black),
            borderRadius: BorderRadius.circular(20.0),
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
      ),
    );
  }
}

class MBAverageWidget extends StatelessWidget {
  MBAverageWidget({Key key, this.title, this.averageRating}) : super(key: key);
  final title;
  final averageRating;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: 160,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Center(
            child: Text(title,
                style: Theme.of(context).textTheme.bodyText1,
                // TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                softWrap: true),
          ),
          SmoothStarRating(
            rating: averageRating.roundToDouble(),
            isReadOnly: true,
            filledIconData: Icons.star,
            halfFilledIconData: Icons.star_half,
            defaultIconData: Icons.star_border,
            color: Theme.of(context).iconTheme.color,
            borderColor: Theme.of(context).iconTheme.color,
            starCount: 5,
            allowHalfRating: true,
            spacing: 5,
          ),
          Text(
            averageRating.roundToDouble().toString(),
            style: Theme.of(context).textTheme.button,
            softWrap: true,
          )
        ],
      ),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border.all(width: 1, color: Colors.black),
          borderRadius: BorderRadius.circular(20.0),
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
    );
  }
}
