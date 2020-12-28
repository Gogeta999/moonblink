import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/appbar/appbar.dart';
import 'package:moonblink/base_widget/imageview.dart';
import 'package:moonblink/bloc_pattern/nfbloc/nf_bloc.dart';
import 'package:moonblink/models/new_feed_models/NFPost.dart';
import 'package:moonblink/provider/view_state.dart';
import 'package:moonblink/provider/view_state_error_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rxdart/rxdart.dart';
import 'package:video_player/video_player.dart';
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
      appBar: AppbarWidget(),
      body: SafeArea(
        child: StreamBuilder<List<NFPost>>(
            initialData: [],
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
                  if (snapshot.data == null || snapshot.data.isEmpty)
                    return Center(child: Text('No Posts Available'));
                  return ListView.builder(
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
                      return GestureDetector(
                        onTap: () {
                          _bloc.onTapWholeCard(
                              context, snapshot.data[index].userId);
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40.0),
                          ),
                          shadowColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.black
                                  : Colors.grey,
                          elevation: 4,
                          child: Column(
                            children: [
                              // Row(
                              //   mainAxisAlignment:
                              //       MainAxisAlignment.spaceBetween,
                              //   children: [
                              //     Container(
                              //       margin: const EdgeInsets.only(left: 60),
                              //       child: Text('User Name'),
                              //     ),
                              //     IconButton(
                              //         padding: EdgeInsets.zero,
                              //         icon: Icon(Icons.more_vert),
                              //         onPressed: () {
                              //           _bloc.onTapBlockIcon(context);
                              //         })
                              //   ],
                              // ),
                              // if (item.body.isNotEmpty) Text('${item.body}'),
                              // Container(
                              //   margin: const EdgeInsets.only(left: 16),
                              //   alignment: Alignment.centerLeft,
                              //   child: Text("Post Title")),
                              ///User profile
                              ListTile(
                                dense: true,
                                leading: Icon(Icons.image),
                                title: Text(item.body.isEmpty
                                    ? "Post's Username"
                                    : item.body),
                                trailing: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(Icons.more_vert),
                                  onPressed: () {
                                    _bloc.onTapBlockIcon(context);
                                  },
                                ),
                              ),

                              ///Post Title
                              SizedBox(height: 5),
                              if (item.body.isEmpty)
                                Container(
                                    margin: const EdgeInsets.only(left: 16),
                                    alignment: Alignment.centerLeft,
                                    child: Text("Post Title")),
                              SizedBox(height: 5),

                              ///Post Media
                              Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      width: 2,
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.grey
                                          : Colors.black,
                                    ),
                                    bottom: BorderSide(
                                      width: 2,
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.grey
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.5,
                                  child: StreamBuilder<bool>(
                                      initialData: false,
                                      stream: _bloc.blockingSubject,
                                      builder: (context, snapshot) {
                                        if (snapshot.data) {
                                          return Center(
                                            child: CupertinoActivityIndicator(),
                                          );
                                        }
                                        return PostMediaItem(
                                            item: item, nfBloc: _bloc);
                                      }),
                                ),
                              ),
                              SizedBox(height: 5),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }(),
              );
            }),
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
    return Stack(
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
                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.black.withOpacity(0.5)
                    ),
                    child: Text('${snapshot.data}/${widget.item.media.length}',
                        style: Theme.of(context).textTheme.bodyText2),
                  ));
            })
      ],
    );
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

  @override
  void initState() {
    _controller = VideoPlayerController.network(widget.url);
    _controller.addListener(() {
      int left = _controller.value.duration.inSeconds -
          _controller.value.position.inSeconds;
      String leftSeconds = (left % 60).toString().padLeft(2, '0');
      int leftMinutes = left ~/ 60;
      _leftDuration.add("$leftMinutes:$leftSeconds");
    });
    _controller.initialize().then((_) {
      setState(() {});
      _controller.play();
      _controller.setLooping(true);
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    print("Debug: Disposing");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _controller.value.initialized
          ? VisibilityDetector(
              key: Key('${widget.id}-${widget.url}'),
              onVisibilityChanged: (visibilityInfo) {
                if (visibilityInfo.visibleFraction >= 0.8) {
                  if (!_controller.value.isPlaying) _controller.play();
                } else {
                  if (_controller.value.isPlaying) _controller.pause();
                }
              },
              child: Stack(
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      if (_controller.value.isPlaying)
                        _controller.pause();
                      else
                        _controller.play();
                    },
                    child: Container(
                      width: double.infinity,
                      //aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                  StreamBuilder<String>(
                      initialData: '',
                      stream: this._leftDuration,
                      builder: (context, snapshot) {
                        return Positioned(
                            top: 35, right: 6, child: Text('${snapshot.data}', style: Theme.of(context).textTheme.bodyText1,));
                      }),
                ],
              ),
            )
          : CupertinoActivityIndicator(),
    );
  }
}
