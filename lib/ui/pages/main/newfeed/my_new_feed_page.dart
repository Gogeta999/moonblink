import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gradient_colors/flutter_gradient_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moonblink/base_widget/appbar/appbar.dart';
import 'package:moonblink/base_widget/blinkIcon_Widget.dart';
import 'package:moonblink/base_widget/gradient.dart';
import 'package:moonblink/base_widget/imageview.dart';
import 'package:moonblink/base_widget/nfpost_player.dart';
import 'package:moonblink/bloc_pattern/nfbloc/my_nf_bloc.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/models/new_feed_models/NFPost.dart';
import 'package:moonblink/provider/view_state.dart';
import 'package:moonblink/provider/view_state_error_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class MyNewFeedPage extends StatefulWidget {
  @override
  _MyNewFeedPageState createState() => _MyNewFeedPageState();
}

class _MyNewFeedPageState extends State<MyNewFeedPage>
    with AutomaticKeepAliveClientMixin {
  MyNFBloc _bloc;
  final _controller = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _bloc = MyNFBloc(_controller);
    _bloc.fetchInitialData();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _bloc.scrollThreshold = MediaQuery.of(context).size.height * 3;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _bloc.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Colors.grey[200]
          : null,
      appBar: AppbarWidget(title: Text('Manage Posts')),
      body: SafeArea(
        child: StreamBuilder<List<NFPost>>(
            initialData: null,
            stream: _bloc.myNfPostsSubject,
            builder: (context, snapshot) {
              return SmartRefresher(
                controller: _bloc.refreshController,
                enablePullDown: true,
                onRefresh: () {
                  _bloc.refreshData();
                },
                header: WaterDropHeader(),
                child: () {
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
                    return Center(child: Text('No Posts Available'));
                  return ListView.builder(
                    cacheExtent: MediaQuery.of(context).size.height * 10,
                    controller: _bloc.scrollController,
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
                      return MyNFPostItem(item: item, index: index, bloc: _bloc);
                    },
                  );
                }(),
              );
            }),
      ),
    );
  }
}

class MyNFPostItem extends StatefulWidget {
  final NFPost item;
  final int index;
  final MyNFBloc bloc;

  const MyNFPostItem({Key key, this.item, this.index, this.bloc})
      : super(key: key);
  @override
  _MyNFPostItemState createState() => _MyNFPostItemState();
}

class _MyNFPostItemState extends State<MyNFPostItem> {
  final _reactCountSubject = BehaviorSubject<int>();
  final _reactedSubject = BehaviorSubject<bool>();
  final _deleteSubject = BehaviorSubject.seeded(false);

  @override
  void initState() {
    _reactCountSubject.add(widget.item.reactionCount);
    _reactedSubject.add(widget.item.isReacted == 1);
    super.initState();
  }

  @override
  void dispose() {
    _reactCountSubject.close();
    _reactedSubject.close();
    _deleteSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40.0),
      ),
      shadowColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : Colors.grey,
      elevation: 4,
      child: Column(
        children: [
          ///User profile
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 15),
                    child: widget.item.profile == null
                        ? Icon(Icons.error)
                        : CachedNetworkImage(
                            fit: BoxFit.fill,
                            imageUrl: widget.item.profile,
                            imageBuilder: (context, provider) {
                              return CircleAvatar(
                                backgroundImage: provider,
                              );
                            },
                            placeholder: (_, __) =>
                                CupertinoActivityIndicator(),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                  ),
                  SizedBox(width: 10),
                  Text(widget.item.name.isEmpty
                      ? "Post's Username"
                      : widget.item.name),
                ],
              ),
              StreamBuilder<bool>(
                initialData: false,
                stream: this._deleteSubject,
                builder: (context, snapshot) {
                  if (snapshot.data) {
                    return IconButton(
                    padding: EdgeInsets.zero,
                    icon: CupertinoActivityIndicator(),
                    onPressed: () {},
                  );
                  }
                  return IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () {
                      widget.bloc.onTapDeleteIcon(
                          context, widget.index, widget.item.id).then((value) {
                            if (value) this._deleteSubject.add(value);
                          });
                    },
                  );
                }
              )
            ],
          ),

          ///Post Title
          if (widget.item.body.isNotEmpty) SizedBox(height: 5),
          if (widget.item.body.isNotEmpty)
            Container(
                margin: const EdgeInsets.only(left: 16),
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.item.body,
                  style: Theme.of(context).textTheme.subtitle1,
                )),
          SizedBox(height: 5),

          ///Post Media
          GestureDetector(
            onDoubleTap: () {
              this._reactedSubject.first.then((value) {
                if (value) {
                  ///reacted
                  this
                      ._reactCountSubject
                      .first
                      .then((value) => this._reactCountSubject.add(--value));
                  this._reactedSubject.add(false);
                } else {
                  this
                      ._reactCountSubject
                      .first
                      .then((value) => this._reactCountSubject.add(++value));
                  this._reactedSubject.add(true);
                }
                //after this call some api
              });
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    width: 3,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey
                        : Colors.black,
                  ),
                  bottom: BorderSide(
                    width: 3,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey
                        : Colors.black,
                  ),
                ),
              ),
              child: PostMediaItem(item: widget.item, nfBloc: widget.bloc),
            ),
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
    margin: const EdgeInsets.only(left: 15),
    child: Row(
      children: [
        StreamBuilder<bool>(
          initialData: false,
          stream: this._reactedSubject,
          builder: (context, snapshot) {
            return CupertinoButton(
              padding: EdgeInsets.zero,
              child: Icon(
                  snapshot.data
                      ? FontAwesomeIcons.solidHeart
                      : FontAwesomeIcons.heart,
                  size: 30,
                  color: snapshot.data
                      ? Colors.red[400]
                      : Theme.of(context).iconTheme.color),
              onPressed: () {
                if (snapshot.data) {
                  ///reacted
                  this
                      ._reactCountSubject
                      .first
                      .then((value) => this._reactCountSubject.add(--value));
                  this._reactedSubject.add(false);
                } else {
                  this
                      ._reactCountSubject
                      .first
                      .then((value) => this._reactCountSubject.add(++value));
                  this._reactedSubject.add(true);
                }
                //after this call some api
              },
            );
          }
        ),
        StreamBuilder<int>(
          initialData: 0,
          stream: this._reactCountSubject,
          builder: (context, snapshot) {
            return Text('${snapshot.data} ${snapshot.data <= 1 ? "Like" : "Likes"}');
          }
        ),
      ],
    ),
    ),
              Container(
                child: Text(
                  G.of(context).becomePartnerAt +
                      timeAgo.format(DateTime.parse(widget.item.createdAt),
                          allowFromNow: true),
                  style: TextStyle(color: Colors.grey, fontSize: 12.0),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 15),
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Icon(FontAwesomeIcons.share),
                  onPressed: () {
                    widget.bloc.onTapShare(context);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PostMediaItem extends StatefulWidget {
  final NFPost item;
  final MyNFBloc nfBloc;

  const PostMediaItem({Key key, this.item, this.nfBloc}) : super(key: key);

  @override
  _PostMediaItemState createState() => _PostMediaItemState();
}

class _PostMediaItemState extends State<PostMediaItem> {
  final _currentPageSubject = BehaviorSubject.seeded(1);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _currentPageSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Stack(
        children: [
          PageView.builder(
              physics: ClampingScrollPhysics(),
              itemCount: widget.item.media.length,
              onPageChanged: (value) {
                _currentPageSubject.add(value + 1);
              },
              itemBuilder: (context, index) {
                UrlType urlType =
                    widget.nfBloc.getUrlType(widget.item.media[index]);
                if (urlType == UrlType.REMOTE_IMAGE)
                  return CupertinoButton(
                    padding: EdgeInsets.zero,
                    pressedOpacity: 0.9,
                    onPressed: () {
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              fullscreenDialog: true,
                              builder: (_) => FullScreenImageView(
                                  imageUrl: widget.item.media[index])));
                    },
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: CachedNetworkImage(
                        fit: BoxFit.fill,
                        imageUrl: widget.item.media[index],
                        progressIndicatorBuilder: (context, url, progress) {
                          return Center(
                            child: CircularProgressIndicator(
                              value: progress.progress,
                              valueColor: AlwaysStoppedAnimation(
                                  Theme.of(context).accentColor),
                            ),
                          );
                        },
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                  );
                if (urlType == UrlType.REMOTE_VIDEO)
                  return Player(
                      url: widget.item.media[index], id: widget.item.id, index: index);
                return Text('Not Supported Format');
              }),
          StreamBuilder<int>(
              initialData: 0,
              stream: this._currentPageSubject,
              builder: (context, snapshot) {
                if (snapshot.data == null) return Container();
                return Positioned(
                    top: 5,
                    right: 5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 2, horizontal: 6),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.black.withOpacity(0.5)),
                      child: Text(
                          '${snapshot.data}/${widget.item.media.length}',
                          style: Theme.of(context).textTheme.bodyText2),
                    ));
              })
        ],
      ),
    );
  }
}

class SizeReportingWidget extends StatefulWidget {
  final Widget child;
  final ValueChanged<Size> onSizeChange;

  const SizeReportingWidget({
    Key key,
    @required this.child,
    @required this.onSizeChange,
  }) : super(key: key);

  @override
  _SizeReportingWidgetState createState() => _SizeReportingWidgetState();
}

class _SizeReportingWidgetState extends State<SizeReportingWidget> {
  Size _oldSize;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifySize());
    return widget.child;
  }

  void _notifySize() {
    final size = context?.size;
    if (_oldSize != size) {
      _oldSize = size;
      widget.onSizeChange(size);
    }
  }
}