import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moonblink/bloc_pattern/bloc.dart';
import 'package:moonblink/bloc_pattern/partner_game_history_bloc.dart';
import 'package:moonblink/global/resources_manager.dart';
import 'package:moonblink/view_model/partner_detail_model.dart';
import 'package:provider/provider.dart';
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

class PartnerGameHistoryWidget extends StatefulWidget {
  final partnerName;
  PartnerGameHistoryWidget(this.partnerName);

  @override
  _PartnerGameHistoryWidgetState createState() =>
      _PartnerGameHistoryWidgetState();
}

class _PartnerGameHistoryWidgetState extends State<PartnerGameHistoryWidget> {
  PartnerDetailModel partnerDetailModel;

  //RefreshController _refreshController = RefreshController();
  //Completer<void> _refreshCompleter;

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
    partnerDetailModel = Provider.of<PartnerDetailModel>(context);
    return BlocProvider<PartnerGameHistoryBloc>(
      create: (context) =>
          PartnerGameHistoryBloc(partnerId: partnerDetailModel.partnerId)
            ..add(PartnerGameHistoryFetched()),
      child: BlocBuilder<PartnerGameHistoryBloc, PartnerGameHistoryState>(
        builder: (context, state) {
          if (state is PartnerGameHistoryInitial) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state is PartnerGameHistoryFailure) {
            return Center(
              child: Text('Error Connecting to Server.'),
            );
          }
          if (state is PartnerGameHistoryNoData) {
            return Center(
              child: Text('This user has no history.'),
            );
          }
          if (state is PartnerGameHistorySuccess) {
            if (state.data.isEmpty) {
              return Center(
                child: Text('no data'),
              );
            }
            return HistoryListView(state: state);
          }
          return null;
        },
      ),
    );
  }
}

class HistoryListView extends StatefulWidget {
  final PartnerGameHistorySuccess state;

  const HistoryListView({Key key, this.state}) : super(key: key);
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
    return ListView.builder(
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

class BottomLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Center(
        child: SizedBox(
          width: 33,
          height: 33,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
          ),
        ),
      ),
    );
  }
}

class HistoryWidget extends StatelessWidget {
  final String history;

  const HistoryWidget({Key key, this.history}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: 1000,
      margin: EdgeInsets.fromLTRB(0, 1.5, 0, 1.5),
      padding: EdgeInsets.all(8.0),
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
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Game Type Name',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                Text(
                  '$history',
                  style: Theme.of(context).textTheme.bodyText2,
                  overflow: TextOverflow.visible,
                )
              ],
            ),
          ),
          Text('Date')
        ],
      ),
    );
  }
}

/*@override
  Widget build(BuildContext context) {
    partnerDetailModel = Provider.of<PartnerDetailModel>(context);
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
            child: GestureDetector(
              onTap: () => {
                init()
              },
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
                        'Customer rated ${widget.partnerName} in 4 stars',
                        style: Theme.of(context).textTheme.bodyText2,
                      )
                    ],
                  ),
                  Text('Date')
                ],
              ),
            ),
          );
        });
  }*/
