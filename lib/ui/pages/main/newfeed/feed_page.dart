import 'dart:math';

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
import 'package:moonblink/bloc_pattern/nfbloc/nf_bloc.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/models/new_feed_models/NFPost.dart';
import 'package:moonblink/provider/view_state.dart';
import 'package:moonblink/provider/view_state_error_widget.dart';
import 'package:moonblink/utils/constants.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timeago/timeago.dart' as timeAgo;

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
        leadingText: G.current.tabHome,
        leadingCallback: () {},
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () {
            _bloc.refreshData();
            return _bloc.refreshCompleter.future;
          },
          child: StreamBuilder<List<NFPost>>(
            initialData: null,
            stream: _bloc.nfPostsSubject,
            builder: (context, snapshot) {
              if (snapshot.hasError)
                return ViewStateErrorWidget(
                  error: ViewStateError(
                      snapshot.error == "No Internet Connection"
                          ? ViewStateErrorType.networkTimeOutError
                          : ViewStateErrorType.defaultError,
                      errorMessage: snapshot.error.toString()),
                  onPressed: () {
                    _bloc.nfPostsSubject.add(null);
                    _bloc.refreshData();
                  },
                );
              if (snapshot.data == null) {
                return Center(child: CupertinoActivityIndicator());
              }
              if (snapshot.data.isEmpty)
                return Center(child: Text(G.current.feedPageNoPostAvailable));
              return ListView.builder(
                //shrinkWrap: true,
                cacheExtent: MediaQuery.of(context).size.height * 7,
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
                  return NFPostItem(item: item, index: index, bloc: _bloc);
                },
              );
            },
          ),
        ),
      ),
    );
    // return Scaffold(
    //   backgroundColor: Theme.of(context).brightness == Brightness.light
    //       ? Colors.grey[200]
    //       : null,
    //   appBar: AppbarWidget(
    //     leadingText: G.current.follow,
    //     leadingCallback: () {
    //       Navigator.of(context)
    //           .push(MaterialPageRoute(builder: (_) => ContactsPage()));
    //     },
    //   ),
    //   body: SafeArea(
    //     child: SmartRefresher(
    //       controller: _bloc.refreshController,
    //       enablePullDown: true,
    //       scrollController: _bloc.scrollController,
    //       onRefresh: () {
    //         _bloc.refreshData();
    //       },
    //       header: WaterDropHeader(),
    //       child: StreamBuilder<List<NFPost>>(
    //         initialData: null,
    //         stream: _bloc.nfPostsSubject,
    //         builder: (context, snapshot) {
    //           if (snapshot.hasError)
    //             return ViewStateErrorWidget(
    //               error: ViewStateError(
    //                   snapshot.error == "No Internet Connection"
    //                       ? ViewStateErrorType.networkTimeOutError
    //                       : ViewStateErrorType.defaultError,
    //                   errorMessage: snapshot.error.toString()),
    //               onPressed: () {
    //                 _bloc.refreshData();
    //               },
    //             );
    //           if (snapshot.data == null) {
    //             return Center(child: CupertinoActivityIndicator());
    //           }
    //           if (snapshot.data.isEmpty)
    //             return Center(child: Text('No Posts Available'));
    //           return ListView.builder(
    //             shrinkWrap: true,
    //             physics: NeverScrollableScrollPhysics(),
    //             itemCount: _bloc.hasReachedMax
    //                 ? snapshot.data.length
    //                 : snapshot.data.length + 1,
    //             itemBuilder: (context, index) {
    //               if (index >= snapshot.data.length) {
    //                 return Center(
    //                     child: Padding(
    //                   padding: const EdgeInsets.only(bottom: 12.0),
    //                   child: CupertinoActivityIndicator(),
    //                 ));
    //               }
    //               final item = snapshot.data[index];
    //               return NFPostItem(item: item, index: index, bloc: _bloc);
    //             },
    //           );
    //         },
    //       ),
    //     ),
    //   ),
    // );
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
  final _readMoreButtonSubject = BehaviorSubject.seeded(false);
  final maxTitleAndCommentLenght = 80;

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
    _readMoreButtonSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.bloc.onTapWholeCard(context, widget.item.userId);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
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
                              errorWidget: (context, url, error) {
                                return Icon(Icons.error);
                              }),
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
                child: () {
                  return StreamBuilder<bool>(
                      initialData: false,
                      stream: _readMoreButtonSubject,
                      builder: (context, snapshot) {
                        if (widget.item.body.length >
                            maxTitleAndCommentLenght) {
                          if (snapshot.data) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.item.body,
                                  style: Theme.of(context).textTheme.subtitle1,
                                ),
                                SizedBox(height: 5),
                                InkWell(
                                  onTap: () {
                                    _readMoreButtonSubject.add(false);
                                  },
                                  child: Text(
                                    G.current.readLess,
                                    style: TextStyle(
                                        color: Theme.of(context).accentColor),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            String short = widget.item.body.substring(
                                0,
                                min(maxTitleAndCommentLenght,
                                    widget.item.body.length));
                            short += ' ....';
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  short,
                                  style: Theme.of(context).textTheme.subtitle1,
                                ),
                                SizedBox(height: 5),
                                InkWell(
                                  onTap: () {
                                    _readMoreButtonSubject.add(true);
                                  },
                                  child: Text(
                                    G.current.readMore,
                                    style: TextStyle(
                                        color: Theme.of(context).accentColor),
                                  ),
                                ),
                              ],
                            );
                          }
                        } else {
                          return Text(
                            widget.item.body,
                            style: Theme.of(context).textTheme.subtitle1,
                          );
                        }
                      });
                }(),
              ),
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
                    item: widget.item,
                    index: widget.index,
                    nfBloc: widget.bloc),
              ),
            ),
            SizedBox(height: 5),

            /// Post Actions
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
                              widget.item.bios,
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
                      placeholder: (_, __) => CupertinoActivityIndicator(),
                      errorWidget: (context, url, error) {
                        return Icon(Icons.error);
                      },
                    ),
                    SizedBox(width: 10),
                    Expanded(
                        child: RichText(
                      text: TextSpan(
                          text: widget.item.lastCommenterName,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.black
                                  : Colors.white),
                          children: <TextSpan>[
                            () {
                              String short = widget.item.lastComment.substring(
                                  0,
                                  min(maxTitleAndCommentLenght,
                                      widget.item.lastComment.length));
                              if (widget.item.lastComment.length >
                                  maxTitleAndCommentLenght) short += ' ....';
                              return TextSpan(
                                  text: ' $short',
                                  style: Theme.of(context).textTheme.bodyText2);
                            }(),
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
                      : Text(G.current.feedPagePostComments),
                  onPressed: () {
                    Navigator.pushNamed(context, RouteName.nfCommentPage,
                        arguments: widget.item);
                  }),
            )
          ],
        ),
      ),
    );
  }
}

class PostMediaItem extends StatefulWidget {
  final NFPost item;
  final NFBloc nfBloc;
  final int index;

  const PostMediaItem({Key key, this.item, this.index, this.nfBloc})
      : super(key: key);

  @override
  _PostMediaItemState createState() => _PostMediaItemState();
}

class _PostMediaItemState extends State<PostMediaItem> {
  final _currentPageSubject = BehaviorSubject.seeded(1);
  final _pageChildrenSubject = BehaviorSubject.seeded(<Widget>[]);
  //int maxHeight = 200;
  final _maxHeightSubject = BehaviorSubject.seeded(300.0);

  @override
  void initState() {
    this._pageChildrenSubject.add(widget.item.media
        .asMap()
        .map((index, url) {
          UrlType urlType = widget.nfBloc.getUrlType(url);
          if (urlType == UrlType.REMOTE_IMAGE)
            return MapEntry(
              index,
              CupertinoButton(
                padding: EdgeInsets.zero,
                pressedOpacity: 0.9,
                onPressed: () {
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                          fullscreenDialog: true,
                          builder: (_) => FullScreenImageView(imageUrl: url)));
                },
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: url,
                    imageBuilder: (context, imageProvider) {
                      final imageListener = ImageStreamListener((info, _) {
                        final _fittedSize = applyBoxFit(
                            BoxFit.contain,
                            Size(info.image.width.toDouble(),
                                info.image.height.toDouble()),
                            MediaQuery.of(context).size);
                        this
                            ._maxHeightSubject
                            .add(_fittedSize.destination.height);
                        // this._maxHeightSubject.first.then((value) {
                        //   this._maxHeightSubject.add(
                        //       //min(maxHeight, max(info.image.height, value)));
                        //       //max(_fittedSize.destination.height, value));
                        //       _fittedSize.destination.height);
                        // });
                      });
                      imageProvider
                          .resolve(ImageConfiguration())
                          .addListener(imageListener);
                      return Image(image: imageProvider, fit: BoxFit.fill);
                    },
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
              ),
            );
          if (urlType == UrlType.REMOTE_VIDEO)
            return MapEntry(
              index,
              Player(
                url: url,
                id: widget.item.id,
                index: widget.index,
                maxHeightCallBack: (double height) {
                  this._maxHeightSubject.add(
                      min(height, MediaQuery.of(context).size.height * 0.7));
                  // this._maxHeightSubject.first.then((value) {
                  //   this._maxHeightSubject.add(max(height, value));
                  //   // .add(max(maxHeight, max(height, value)));
                  // });
                },
              ),
            );
          return MapEntry(index, Text('Not Supported Format'));
        })
        .values
        .toList());
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
    _pageChildrenSubject.close();
    _currentPageSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        StreamBuilder<List<Widget>>(
          initialData: [],
          stream: this._pageChildrenSubject,
          builder: (context, childrenSnapshot) {
            return StreamBuilder<double>(
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
                      children: childrenSnapshot.data,
                    ),
                  );
                });
          },
        ),
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
