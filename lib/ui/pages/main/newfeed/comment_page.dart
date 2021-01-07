import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/appbar/appbar.dart';
import 'package:moonblink/bloc_pattern/nf_commnet_bloc/nf_commnet_bloc.dart';
import 'package:moonblink/models/new_feed_models/NFComment.dart';
import 'package:moonblink/provider/view_state.dart';
import 'package:moonblink/provider/view_state_error_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class CommentPage extends StatefulWidget {
  final int postId;

  const CommentPage(this.postId, {Key key}) : super(key: key);

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  NFCommentBloc _bloc;

  @override
  void initState() {
    _bloc = NFCommentBloc(widget.postId);
    _bloc.fetchInitialData();
    super.initState();
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppbarWidget(title: Text('Comments')),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SmartRefresher(
            controller: _bloc.refreshController,
            enablePullDown: true,
            scrollController: _bloc.scrollController,
            onRefresh: () {
              _bloc.refreshData();
            },
            header: WaterDropHeader(),
            child: StreamBuilder<List<NFComment>>(
              initialData: null,
              stream: _bloc.nfCommentsSubject,
              builder: (context, snapshot) {
                if (snapshot.hasError)
                  return ViewStateErrorWidget(
                    error: ViewStateError(
                        snapshot.error == "No Internet Connection"
                            ? ViewStateErrorType.networkTimeOutError
                            : ViewStateErrorType.defaultError,
                        errorMessage: snapshot.error.toString()),
                    onPressed: () {
                      _bloc.refreshData();
                    },
                  );
                if (snapshot.data == null) {
                  return Center(child: CupertinoActivityIndicator());
                }
                if (snapshot.data.isEmpty)
                  return Center(child: Text('No Comments Available'));
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _bloc.hasReachedMax
                      ? snapshot.data.length
                      : snapshot.data.length + 1,
                  itemBuilder: (context, index) {
                    if (index >= snapshot.data.length) {
                      return Center(
                          child: Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: CupertinoActivityIndicator(),
                      ));
                    }
                    final item = snapshot.data[index];
                    return NfCommentItem(item, index, _bloc);
                  },
                );
              },
            ),
          ),
        ),
        bottomNavigationBar: Row(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: CupertinoTextField(
                  placeholder: 'Add a comment',
                  controller: _bloc.commentController,
                  style: Theme.of(context).textTheme.bodyText1,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      border: Border.all(color: Theme.of(context).accentColor),
                      borderRadius: BorderRadius.circular(10)),
                  keyboardType: TextInputType.text,
                  maxLines: 2,
                  textInputAction: TextInputAction.done,
                  clearButtonMode: OverlayVisibilityMode.editing,
                ),
              ),
            ),
            StreamBuilder<bool>(
              initialData: false,
              stream: _bloc.postButtonSubject,
              builder: (context, snapshot) {
                if (snapshot.data) {
                  return CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: CupertinoActivityIndicator(),
                  onPressed: () {
                  },
                );
                }
                return CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Text('Post'),
                  onPressed: () {
                    _bloc.postComment();
                    FocusScope.of(context).unfocus();
                  },
                );
              }
            )
          ],
        ),
      ),
    );
  }
}

class NfCommentItem extends StatefulWidget {
  final NFComment item;
  final int index;
  final NFCommentBloc bloc;

  const NfCommentItem(this.item, this.index, this.bloc, {Key key})
      : super(key: key);

  @override
  _NfCommentItemState createState() => _NfCommentItemState();
}

class _NfCommentItemState extends State<NfCommentItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              widget.item.userProfileImage == null
                  ? Icon(Icons.error)
                  : CachedNetworkImage(
                      fit: BoxFit.fill,
                      imageUrl: widget.item.userProfileImage,
                      imageBuilder: (context, provider) {
                        return CircleAvatar(
                          backgroundImage: provider,
                        );
                      },
                      placeholder: (_, __) => CupertinoActivityIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
              SizedBox(width: 5),
              Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: widget.item.username,
                      style: TextStyle(fontWeight: FontWeight.bold),
                      children: <TextSpan>[
                        TextSpan(
                          text: '  ${widget.item.message}',
                          style: Theme.of(context).textTheme.bodyText1
                        ),
                      ]
                    ),
                  ))
            ],
          ),
          SizedBox(height: 5),
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              timeAgo.format(DateTime.parse(widget.item.createdAt),
                  allowFromNow: true),
              style: TextStyle(color: Colors.grey, fontSize: 12.0),
            ),
          ),
        ],
      ),
    );
  }
}
