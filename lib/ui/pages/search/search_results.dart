import 'package:flutter/material.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/models/user.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/provider/view_state_error_widget.dart';
import 'package:moonblink/ui/pages/main/home/shimmer_indicator.dart';
import 'package:moonblink/ui/pages/user/partner_detail_page.dart';
import 'package:moonblink/view_model/search_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SearchResults extends StatelessWidget {
  final String keyword;
  final SearchHistoryModel searchHistoryModel;

  SearchResults({this.keyword, this.searchHistoryModel});
  @override
  Widget build(BuildContext context) {
    return ProviderWidget<SearchResultModel>(
        model: SearchResultModel(
            keyword: keyword, searchHistoryModel: searchHistoryModel),
        onModelReady: (model) {
          model.initData();
        },
        builder: (context, model, child) {
          if (model.isBusy) {
            return ViewStateBusyWidget();
          } else if (model.isError && model.list.isEmpty) {
            return ViewStateErrorWidget(
                error: model.viewStateError, onPressed: model.initData);
          } else if (model.isEmpty) {
            return ViewStateEmptyWidget(onPressed: model.initData);
          }
          return SmartRefresher(
              controller: model.refreshController,
              header: ShimmerHeader(
                  text: Text(S.of(context).pullDownToRefresh,
                      style: TextStyle(color: Colors.grey, fontSize: 22))),
              footer: ShimmerFooter(
                  text: Text(S.of(context).pullTopToLoad,
                      style: TextStyle(color: Colors.grey, fontSize: 22))),
              onRefresh: model.refresh,
              onLoading: model.loadMore,
              enablePullUp: model.list.isNotEmpty,
              child: ListView.builder(
                  itemCount: model.list.length,
                  itemBuilder: (context, index) {
                    User item = model.list[index];
                    return SearchUserWidget(item);
                  }));
        });
  }
}

class SearchUserWidget extends StatelessWidget {
  final User user;
  SearchUserWidget(this.user);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      // color: Colors.blue,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  int detailPageId = user.id;
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              PartnerDetailPage(detailPageId)));
                },
                child: CircleAvatar(
                    radius: 45,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    backgroundImage: NetworkImage(user.partnerProfileImage)),
              ),
              Text(user.name),
            ],
          ),
          Container(
            height: 0.5,
            color: Colors.grey,
          )
        ],
      ),
    );
  }
}
