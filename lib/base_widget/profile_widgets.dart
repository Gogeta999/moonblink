import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:moonblink/bloc_pattern/partner_game_history/bloc.dart';
import 'package:moonblink/bloc_pattern/partner_game_history/partner_game_history_bloc.dart';
import 'package:moonblink/global/resources_manager.dart';
import 'package:moonblink/models/transaction.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class PartnerRatingWidget extends StatelessWidget {
  final partnerName;
  final averageRating;
  PartnerRatingWidget(this.partnerName, this.averageRating);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(width: 1.5, color: Colors.grey),
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
      ),
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: <Widget>[
          Center(
            child: Image.asset(
              ImageHelper.wrapAssetsLogo('ratingsRabbit.png'),
              fit: BoxFit.fill,
            ),
          ),
          Positioned(
            bottom: 85,
            child: SmoothStarRating(
              rating: averageRating.roundToDouble(),
              isReadOnly: true,
              filledIconData: Icons.star,
              halfFilledIconData: Icons.star_half,
              defaultIconData: Icons.star_border,
              color: Theme.of(context).accentColor,
              starCount: 5,
              allowHalfRating: true,
              spacing: 5,
            ),
          ),
          Positioned(
              bottom: 50,
              child: Text(
                partnerName +
                    G.of(context).averageRating +
                    averageRating.roundToDouble().toString(),
                style: TextStyle(color: Colors.black),
              ))
        ],
      ),
    );
  }
}

class PartnerGameHistoryWidget extends StatefulWidget {
  final partnerName;
  final partnerId;
  final String totalBooking;
  PartnerGameHistoryWidget(this.partnerName, this.partnerId, this.totalBooking);

  @override
  _PartnerGameHistoryWidgetState createState() =>
      _PartnerGameHistoryWidgetState();
}

class _PartnerGameHistoryWidgetState extends State<PartnerGameHistoryWidget>
    with AutomaticKeepAliveClientMixin {
  //PartnerDetailModel partnerDetailModel;

  //RefreshController _refreshController = RefreshController();
  //Completer<void> _refreshCompleter;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    //_refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    //partnerDetailModel = Provider.of<PartnerDetailModel>(context);
    return BlocProvider<PartnerGameHistoryBloc>(
      create: (context) => PartnerGameHistoryBloc(
          /*partnerId: partnerDetailModel.partnerId ?? */ partnerId:
              widget.partnerId)
        ..add(PartnerGameHistoryFetched()),
      child: BlocBuilder<PartnerGameHistoryBloc, PartnerGameHistoryState>(
        builder: (context, state) {
          if (state is PartnerGameHistoryInitial) {
            return Center(
              child: CupertinoActivityIndicator(),
            );
          }
          if (state is PartnerGameHistoryFailure) {
            return Center(
              child: Text('${G.of(context).error}: ${state.error}.'),
            );
          }
          if (state is PartnerGameHistoryNoData) {
            return Center(
              child: Text(G.of(context).textnohistory),
            );
          }
          if (state is PartnerGameHistorySuccess) {
            if (state.data.isEmpty) {
              return Center(
                child: Text(G.of(context).textnohistory),
              );
            }
            return HistoryListView(
              state: state,
              totalBooking: widget.totalBooking,
            );
          }
          return null;
        },
      ),
    );
  }
}

class HistoryListView extends StatefulWidget {
  final PartnerGameHistorySuccess state;
  final String totalBooking;

  const HistoryListView({Key key, this.state, this.totalBooking})
      : super(key: key);
  @override
  _HistoryListViewState createState() => _HistoryListViewState();
}

class _HistoryListViewState extends State<HistoryListView> {
  final _scrollController = ScrollController();
  final _scrollThreshold = 200.0;
  //Completer<void> _refreshCompleter;
  //final _refreshController = RefreshController();

  @override
  void initState() {
    _scrollController.addListener(_onScroll);
    //_refreshCompleter = Completer<void>();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(
                flex: 2,
              ),
              Text(
                "Total Booking Count",
                style: Theme.of(context).textTheme.headline6,
              ),
              Spacer(
                flex: 1,
              ),
              CircleAvatar(
                radius: 10,
                backgroundColor: Theme.of(context).accentColor,
                child: Text(
                  widget.totalBooking,
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
              Spacer(
                flex: 2,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            physics: AlwaysScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return index >= widget.state.data.length
                  ? BottomLoader()
                  : HistoryWidget(history: widget.state.data[index]);
            },
            itemCount: widget.state.hasReachedMax
                ? widget.state.data.length
                : widget.state.data.length + 1,
            controller: _scrollController,
          ),
        ),
      ],
    );
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      BlocProvider.of<PartnerGameHistoryBloc>(context)
          .add(PartnerGameHistoryFetched());
    }
  }

  /*Future<void> _onRefresh() {
    BlocProvider.of<PartnerGameHistoryBloc>(context).add(PartnerGameHistoryRefreshed());
    return _refreshCompleter.future;
  }*/
}

///Use for both UserTransaction and PartnerGameUserHistory
class BottomLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Center(
        child: SizedBox(
          width: 33,
          height: 33,
          child: CupertinoActivityIndicator(),
        ),
      ),
    );
  }
}

///Use for both UserTransaction and PartnerGameUserHistory
class HistoryWidget extends StatelessWidget {
  final Transaction history;

  const HistoryWidget({Key key, this.history}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //var fo
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              spreadRadius: 0.5,
              // blurRadius: 2,
              offset: Offset(-3, 3), // changes position of shadow
            ),
          ],
        ),
        child: ListTile(
          leading: Image.asset(
            ImageHelper.wrapAssetsLogo('appbar.jpg'),
            height: 50,
            width: 45,
          ),
          title: Text(
            '${history.transaction}',
            style: Theme.of(context).textTheme.button,
            overflow: TextOverflow.visible,
          ),
          trailing: Text(DateFormat.yMd().format(DateTime.parse(history.date))),
        ) /*Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Image.asset(
            ImageHelper.wrapAssetsLogo('appbar.jpg'),
            height: 50,
            width: 45,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              '${history.transaction}',
              style: Theme.of(context).textTheme.bodyText2,
              overflow: TextOverflow.visible,
            ),
          ),
          SizedBox(width: 10),
          Text(DateFormat.yMd().format(DateTime.parse(history.date)))
        ],
      ),*/
        );
  }
}
