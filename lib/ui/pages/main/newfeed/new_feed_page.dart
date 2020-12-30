import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gradient_colors/flutter_gradient_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moonblink/base_widget/appbar/appbar.dart';
import 'package:moonblink/base_widget/blinkIcon_Widget.dart';
import 'package:moonblink/base_widget/gradient.dart';
import 'package:moonblink/base_widget/imageview.dart';
import 'package:moonblink/bloc_pattern/nfbloc/nf_bloc.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/models/new_feed_models/NFPost.dart';
import 'package:moonblink/provider/view_state.dart';
import 'package:moonblink/provider/view_state_error_widget.dart';
import 'package:moonblink/ui/pages/main/contacts/contacts_page.dart';
import 'package:oktoast/oktoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rxdart/rxdart.dart';
import 'package:video_player/video_player.dart';
import 'package:timeago/timeago.dart' as timeAgo;
import 'package:visibility_detector/visibility_detector.dart';

class NewFeedPage extends StatefulWidget {
  final ScrollController scrollController;

  const NewFeedPage({Key key, this.scrollController}) : super(key: key);

  @override
  _NewFeedPageState createState() => _NewFeedPageState();
}

class _NewFeedPageState extends State<NewFeedPage>
    with AutomaticKeepAliveClientMixin {
  NFBloc _bloc;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _bloc = NFBloc(widget.scrollController);
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Colors.grey[200]
          : null,
      appBar: AppbarWidget(
        leadingCallback: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => ContactsPage()));
        },
      ),
      body: SafeArea(
        child: StreamBuilder<List<NFPost>>(
            initialData: null,
            stream: _bloc.nfPostsSubject,
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
                    cacheExtent: MediaQuery.of(context).size.height * 5,
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
                      return NFPostItem(item: item, index: index, bloc: _bloc);
                    },
                  );
                }(),
              );
            }),
      ),
    );
  }
}

class NFPostItem extends StatefulWidget {
  final NFPost item;
  final int index;
  final NFBloc bloc;

  const NFPostItem({Key key, this.item, this.index, this.bloc})
      : super(key: key);
  @override
  _NFPostItemState createState() => _NFPostItemState();
}

class _NFPostItemState extends State<NFPostItem> {
  final _reactCountSubject = BehaviorSubject<int>();
  final _reactedSubject = BehaviorSubject<bool>();

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.bloc.onTapWholeCard(context, widget.item.userId);
      },
      child: Card(
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
                IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.more_vert),
                  onPressed: () {
                    widget.bloc.onTapBlockIcon(
                        context, widget.index, widget.item.userId);
                  },
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
                                  this._reactCountSubject.first.then((value) =>
                                      this._reactCountSubject.add(--value));
                                  this._reactedSubject.add(false);
                                } else {
                                  this._reactCountSubject.first.then((value) =>
                                      this._reactCountSubject.add(++value));
                                  this._reactedSubject.add(true);
                                }
                                //after this call some api
                              },
                            );
                          }),
                      StreamBuilder<int>(
                          initialData: 0,
                          stream: this._reactCountSubject,
                          builder: (context, snapshot) {
                            return Text(
                                '${snapshot.data} ${snapshot.data <= 1 ? "Like" : "Likes"}');
                          }),
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
                  child: Row(
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: BlinkWidget(
                          children: [
                            Icon(FontAwesomeIcons.book, color: Colors.white),
                            RadiantGradientMask(
                              child: Icon(
                                FontAwesomeIcons.book,
                                color: Colors.white,
                              ),
                              colors: MoreGradientColors.instagram,
                            ),
                          ],
                        ),
                        onPressed: () {
                          widget.bloc.onTapInstaIcon(
                              context,
                              widget.item.userId,
                              widget.item.name,
                              'bios',
                              widget.item.profile);
                        },
                      ),
                      SizedBox(width: 10),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Icon(FontAwesomeIcons.share),
                        onPressed: () {
                          widget.bloc.onTapShare(context);
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LikeButton extends StatefulWidget {
  final int isReacted;
  final int reactCount;

  const LikeButton({Key key, this.isReacted, this.reactCount})
      : super(key: key);
  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  bool isReacted = false;
  int reactCount = 0;

  @override
  void initState() {
    setState(() {
      isReacted = widget.isReacted == 1;
      reactCount = widget.reactCount;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 15),
      child: Row(
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: Icon(
                isReacted
                    ? FontAwesomeIcons.solidHeart
                    : FontAwesomeIcons.heart,
                size: 30,
                color: isReacted
                    ? Colors.red[400]
                    : Theme.of(context).iconTheme.color),
            onPressed: () {
              setState(() {
                if (isReacted) {
                  reactCount--;
                  isReacted = false;
                } else {
                  reactCount++;
                  isReacted = true;
                }
              });
            },
          ),
          Text('${reactCount} ${reactCount <= 1 ? "Like" : "Likes"}'),
        ],
      ),
    );
  }
}

class PostMediaItem extends StatefulWidget {
  final NFPost item;
  final NFBloc nfBloc;

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
                      url: widget.item.media[index], id: widget.item.id);
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

class Player extends StatefulWidget {
  final String url;
  final int id;

  const Player({Key key, this.url, this.id}) : super(key: key);

  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  VideoPlayerController _controller;
  final _leftDuration = BehaviorSubject.seeded("");
  final _muteSubject = BehaviorSubject.seeded(false);
  bool didUserPause = false;

  @override
  void initState() {
    _controller = VideoPlayerController.network(widget.url);
    _controller.addListener(() {
      int left = (_controller.value.duration?.inSeconds ?? 1) -
          (_controller.value.position.inSeconds + 1);
      String leftSeconds = (left % 60).toString().padLeft(2, '0');
      int leftMinutes = left ~/ 60;
      _leftDuration.add("$leftMinutes:$leftSeconds");
    });
    _muteSubject.add(_controller.value.volume == 0.0);
    _controller.initialize().then((_) {
      _controller.play();
      _controller.setLooping(true);
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _muteSubject.close();
    _leftDuration.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: VisibilityDetector(
        key: Key('${widget.id}-${widget.url}'),
        onVisibilityChanged: (visibilityInfo) {
          if (visibilityInfo.visibleFraction >= 0.9) {
            if (!_controller.value.isPlaying && !didUserPause)
              _controller.play();
          } else {
            if (_controller.value.isPlaying) _controller.pause();
          }
        },
        child: Stack(
          children: [
            Center(
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  if (!_controller.value.initialized) return;
                  if (_controller.value.isPlaying) {
                    _controller.pause();
                    didUserPause = true;
                  } else {
                    _controller.play();
                    didUserPause = false;
                  }
                },
                child: _controller.value.initialized
                    ? VideoPlayer(_controller)
                    : CupertinoActivityIndicator(),
              ),
            ),
            StreamBuilder<String>(
                initialData: '',
                stream: this._leftDuration,
                builder: (context, snapshot) {
                  if (!_controller.value.initialized) return Container();
                  return Positioned(
                      top: 35,
                      right: 6,
                      child: Row(
                        children: [
                          Text(
                            '${snapshot.data}',
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                          SizedBox(width: 5),
                          CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                this._muteSubject.first.then((value) {
                                  if (value) {
                                    _controller.setVolume(1.0);
                                  } else {
                                    _controller.setVolume(0.0);
                                  }
                                  this._muteSubject.add(!value);
                                });
                              },
                              child: StreamBuilder<bool>(
                                  initialData: false,
                                  stream: this._muteSubject,
                                  builder: (context, snapshot) {
                                    return Icon(
                                      snapshot.data
                                          ? Icons.volume_off
                                          : Icons.volume_up,
                                      color: Colors.white,
                                    );
                                  }))
                        ],
                      ));
                }),
          ],
        ),
      ),
    );
  }
}
