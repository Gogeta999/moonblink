import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moonblink/base_widget/appbar/appbar.dart';
import 'package:moonblink/base_widget/imageview.dart';
import 'package:moonblink/base_widget/nfpost_player.dart';
import 'package:moonblink/bloc_pattern/nfbloc/my_nf_bloc.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/models/new_feed_models/NFPost.dart';
import 'package:moonblink/provider/view_state.dart';
import 'package:moonblink/provider/view_state_error_widget.dart';
import 'package:moonblink/utils/constants.dart';
import 'package:readmore/readmore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class MyNewFeedPage extends StatefulWidget {
  @override
  _MyNewFeedPageState createState() => _MyNewFeedPageState();
}

class _MyNewFeedPageState extends State<MyNewFeedPage> {
  MyNFBloc _bloc;
  final _controller = ScrollController();

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
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Colors.grey[200]
          : null,
      appBar: AppbarWidget(
        leadingText: G.current.follow,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () {
            _bloc.refreshData();
            return _bloc.refreshCompleter.future;
          },
          child: StreamBuilder<List<NFPost>>(
            initialData: null,
            stream: _bloc.myNfPostsSubject,
            builder: (context, snapshot) {
              if (snapshot.hasError)
                return ViewStateErrorWidget(
                  error: ViewStateError(
                      snapshot.error == "No Internet Connection"
                          ? ViewStateErrorType.networkTimeOutError
                          : ViewStateErrorType.defaultError,
                      errorMessage: snapshot.error.toString()),
                  onPressed: () {
                    _bloc.myNfPostsSubject.add(null);
                    _bloc.refreshData();
                  },
                );
              if (snapshot.data == null) {
                return Center(child: CupertinoActivityIndicator());
              }
              if (snapshot.data.isEmpty)
                return Center(child: Text('No Posts Available'));
              return ListView.builder(
                //shrinkWrap: true,
                cacheExtent: MediaQuery.of(context).size.height * 3,
                controller: _bloc.scrollController,
                physics: ClampingScrollPhysics(),
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
                  item.media.forEach((element) {
                    UrlType urlType = _bloc.getUrlType(element.url);
                    if (urlType == UrlType.REMOTE_IMAGE) {
                      precacheImage(
                          CachedNetworkImageProvider(element.url), context);
                    }
                  });
                  return MyNFPostItem(item: item, index: index, bloc: _bloc);
                },
              );
            },
          ),
        ),
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
                  icon: Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () {
                    widget.bloc
                        .onTapDeleteIcon(context, widget.index, widget.item.id);
                  }),
            ],
          ),

          ///Post Title
          if (widget.item.body.isNotEmpty) SizedBox(height: 5),
          if (widget.item.body.isNotEmpty)
            Container(
                margin: const EdgeInsets.only(left: 16),
                alignment: Alignment.centerLeft,
                child: ReadMoreText(
                  widget.item.body,
                  style: Theme.of(context).textTheme.subtitle1,
                  trimLines: 3,
                  colorClickableText: Theme.of(context).accentColor,
                  trimMode: TrimMode.Line,
                  trimCollapsedText: G.of(context).readMore,
                  trimExpandedText: G.of(context).readLess,
                )),
          SizedBox(height: 5),

          ///Post Media
          GestureDetector(
            onDoubleTap: () {
              this._reactedSubject.first.then((value) {
                if (value) {
                  ///reacted
                  widget.bloc.onTapLikeIcon(widget.item.id, 0);
                  this
                      ._reactCountSubject
                      .first
                      .then((value) => this._reactCountSubject.add(--value));
                  this._reactedSubject.add(false);
                } else {
                  widget.bloc.onTapLikeIcon(widget.item.id, 1);
                  this
                      ._reactCountSubject
                      .first
                      .then((value) => this._reactCountSubject.add(++value));
                  this._reactedSubject.add(true);
                }
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
              child: PostMediaItem(
                  item: widget.item, index: widget.index, nfBloc: widget.bloc),
            ),
          ),
          SizedBox(height: 5),

          ///Post Actions
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
                                widget.bloc.onTapLikeIcon(widget.item.id, 0);
                                this._reactCountSubject.first.then((value) =>
                                    this._reactCountSubject.add(--value));
                                this._reactedSubject.add(false);
                              } else {
                                widget.bloc.onTapLikeIcon(widget.item.id, 1);
                                this._reactCountSubject.first.then((value) =>
                                    this._reactCountSubject.add(++value));
                                this._reactedSubject.add(true);
                              }
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
                  G.current.feedPagePosted +
                      " " +
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
          SizedBox(height: 3),

          ///Post Comment
          if (widget.item.lastComment != null &&
              widget.item.lastComment.isNotEmpty &&
              widget.item.lastCommenterName != null &&
              widget.item.lastCommenterName.isNotEmpty &&
              widget.item.lastCommenterProfileImage != null &&
              widget.item.lastCommenterProfileImage.isNotEmpty)
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  CachedNetworkImage(
                    fit: BoxFit.fill,
                    imageUrl: widget.item.lastCommenterProfileImage,
                    imageBuilder: (context, provider) {
                      return CircleAvatar(
                        backgroundImage: provider,
                      );
                    },
                    errorWidget: (context, url, error) {
                      return Icon(Icons.error);
                    },
                  ),
                  SizedBox(width: 10),
                  Expanded(
                      child: RichText(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                        text: widget.item.lastCommenterName,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.black
                                    : Colors.white),
                        children: <TextSpan>[
                          TextSpan(
                              text: ' ' + widget.item.lastComment,
                              style: Theme.of(context).textTheme.bodyText2)
                        ]),
                  ))
                ],
              ),
            ),
          Container(
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: CupertinoButton(
                padding: EdgeInsets.zero,
                child: (widget.item.lastComment != null &&
                        widget.item.lastComment.isNotEmpty &&
                        widget.item.lastCommenterName != null &&
                        widget.item.lastCommenterName.isNotEmpty &&
                        widget.item.lastCommenterProfileImage != null &&
                        widget.item.lastCommenterProfileImage.isNotEmpty)
                    ? Text(G.current.feedPageViewMoreComment)
                    : Text('Post comments'),
                onPressed: () {
                  Navigator.pushNamed(context, RouteName.nfCommentPage,
                      arguments: widget.item);
                }),
          )
        ],
      ),
    );
  }
}

class PostMediaItem extends StatefulWidget {
  final NFPost item;
  final MyNFBloc nfBloc;
  final int index;

  const PostMediaItem({Key key, this.item, this.index, this.nfBloc})
      : super(key: key);

  @override
  _PostMediaItemState createState() => _PostMediaItemState();
}

class _PostMediaItemState extends State<PostMediaItem> {
  final _currentPageSubject = BehaviorSubject.seeded(1);
  final _maxHeightSubject = BehaviorSubject.seeded(300.0);

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    //maxHeight = MediaQuery.of(context).size.height.toInt();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _maxHeightSubject.close();
    _currentPageSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        StreamBuilder<double>(
            initialData: 300.0,
            stream: this._maxHeightSubject,
            builder: (context, maxHeightSnapshot) {
              return AnimatedContainer(
                width: double.infinity,
                height: maxHeightSnapshot.data,
                duration: Duration(milliseconds: 300),
                child: PageView(
                  physics: ClampingScrollPhysics(),
                  onPageChanged: (value) {
                    _currentPageSubject.add(value + 1);
                  },
                  children: widget.item.media.map((element) {
                    UrlType urlType = widget.nfBloc.getUrlType(element.url);
                    if (urlType == UrlType.REMOTE_IMAGE) {
                      return CupertinoButton(
                        padding: EdgeInsets.zero,
                        pressedOpacity: 0.9,
                        onPressed: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  fullscreenDialog: true,
                                  builder: (_) => FullScreenImageView(
                                      imageUrl: element.url)));
                        },
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          child: CachedNetworkImage(
                            imageUrl: element.url,
                            imageBuilder: (context, imageProvider) {
                              final imageListener =
                                  ImageStreamListener((info, _) {
                                final _fittedSize = applyBoxFit(
                                    BoxFit.contain,
                                    Size(info.image.width.toDouble(),
                                        info.image.height.toDouble()),
                                    MediaQuery.of(context).size);
                                this
                                    ._maxHeightSubject
                                    .add(_fittedSize.destination.height);
                              });
                              imageProvider
                                  .resolve(ImageConfiguration())
                                  .addListener(imageListener);
                              return Image(
                                  image: imageProvider, fit: BoxFit.fill);
                            },
                            fadeOutDuration: Duration.zero,
                            fadeInDuration: Duration.zero,
                            placeholderFadeInDuration: Duration.zero,
                            progressIndicatorBuilder: (context, url, progress) {
                              return Center(
                                child: CircularProgressIndicator(
                                  value: progress.progress,
                                  valueColor: AlwaysStoppedAnimation(
                                      Theme.of(context).accentColor),
                                ),
                              );
                            },
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                        ),
                      );
                    }
                    if (urlType == UrlType.REMOTE_VIDEO)
                      return Player(
                        url: element.url,
                        id: widget.item.id,
                        index: widget.index,
                        maxHeightCallBack: (double height) {
                          this._maxHeightSubject.add(min(height,
                              MediaQuery.of(context).size.height * 0.7));
                        },
                      );
                    return Text('Not Supported Format');
                  }).toList(),
                ),
              );
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
                    padding:
                        const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.black.withOpacity(0.5)),
                    child: Text(
                        '${snapshot.data} / ${widget.item.media.length}',
                        style: TextStyle(color: Colors.white)),
                  ));
            })
      ],
    );
  }
}
