import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/view_model/booking_model.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:moonblink/generated/l10n.dart';

class BookingBottomSheet extends StatefulWidget {
  final int partnerId;

  const BookingBottomSheet({Key key, this.partnerId}) : super(key: key);

  @override
  _BookingBottomSheetState createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends State<BookingBottomSheet> {
  TextStyle _textStyle;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _textStyle = Theme.of(context).textTheme.bodyText1;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingModel>(
      builder: (context, bookingModel, child) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(height: 10),
          Text(
              /*G.of(context).bookingChooseGameType*/ 'Choose game type to play',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 20.0),
          Container(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.3),
            child: ListView.builder(
              physics: ClampingScrollPhysics(),
              shrinkWrap: true,
              itemCount: bookingModel.gamesList.length,
              itemBuilder: (context, index) {
                return ListTile(
                    leading: CachedNetworkImage(
                      imageUrl: bookingModel.gamesList[index].icon,
                      imageBuilder: (context, imageProvider) => Container(
                        width: 46.0,
                        height: 46.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: imageProvider, fit: BoxFit.cover),
                        ),
                      ),
                      placeholder: (context, url) =>
                          CupertinoActivityIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                    title: Text(bookingModel.gamesList[index].gameType,
                        style: _textStyle),
                    subtitle:
                        Text('${bookingModel.gamesList[index].price} Coins'),
                    trailing: BookingButton(
                        partnerId: widget.partnerId,
                        gameTypeId: bookingModel.gamesList[index].gameTypeId));
              },
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                FontAwesomeIcons.coins,
                color: Colors.amber[500],
                size: 16,
              ),
              SizedBox(width: 10.0),
              Container(
                child: Text(
                    /*S.of(context).currentcoin*/ 'You have ' +
                        '${bookingModel.wallet.value} ${bookingModel.wallet.value > 1 ? 'coins.' : 'coin.'}',
                    style: _textStyle),
              ),
              if (bookingModel.wallet.value == 0)
                CupertinoButton(
                  onPressed: () {
                    Navigator.pushNamed(context, RouteName.wallet);
                  },
                  child: Text('Top Up Now', style: TextStyle(fontSize: 14)),
                )
            ],
          ),
          SizedBox(height: 40)
        ],
      ),
    );
  }
}

enum BookingButtonState {
  initial,
  loading,
}

class BookingButton extends StatefulWidget {
  final int partnerId;
  final int gameTypeId;

  BookingButton({Key key, this.gameTypeId, this.partnerId}) : super(key: key);

  @override
  _BookingButtonState createState() => _BookingButtonState();
}

class _BookingButtonState extends State<BookingButton> {
  BehaviorSubject<BookingButtonState> _buttonSubject;

  @override
  void initState() {
    super.initState();
    _buttonSubject = BehaviorSubject()..add(BookingButtonState.initial);
  }

  @override
  void dispose() {
    _buttonSubject.close();
    _buttonSubject = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _buttonSubject.stream,
      builder: (context, snapshot) {
        if (snapshot.data == BookingButtonState.initial) {
          return CupertinoButton(
            onPressed: () async {
              _buttonSubject.add(BookingButtonState.loading);
              try {
                await context
                    .read<BookingModel>()
                    .booking(widget.partnerId, widget.gameTypeId);
                Navigator.pop(context);
                Navigator.pushNamed(context, RouteName.chatBox,
                    arguments: widget.partnerId);
              } catch (e) {
                showToast(e.toString());
                _buttonSubject.add(BookingButtonState.initial);
              }
            },
            child: Text('Request', style: TextStyle(fontSize: 16)),
          );
        } else if (snapshot.data == BookingButtonState.loading) {
          return CupertinoActivityIndicator();
        } else {
          return Text('Something went wrong.');
        }
      },
    );
  }
}
