import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/appbar/appbar.dart';
import 'package:moonblink/bloc_pattern/nf_commnet_bloc/nf_commnet_bloc.dart';
import 'package:moonblink/models/new_feed_models/NFComment.dart';
import 'package:moonblink/provider/view_state.dart';
import 'package:moonblink/provider/view_state_error_widget.dart';
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
          child: RefreshIndicator(
            onRefresh: () {
              _bloc.refreshData();
              return _bloc.refreshCompleter.future;
            },
            child: Column(
              children: [
                Expanded(
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
                            _bloc.nfCommentsSubject.add(null);
                            _bloc.refreshData();
                          },
                        );
                      if (snapshot.data == null) {
                        return Center(child: CupertinoActivityIndicator());
                      }
                      if (snapshot.data.isEmpty)
                        return Center(child: Text('No Comments Available'));
                      return ListView.builder(
                        controller: _bloc.scrollController,
                        physics: AlwaysScrollableScrollPhysics(),
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
                Column(
                  children: [
                    StreamBuilder<Map<String, dynamic>>(
                      initialData: null,
                      stream: _bloc.replyingSubject,
                      builder: (context, snapshot) {
                        if (snapshot.data == null || snapshot.data.isEmpty)
                          return Container();
                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 10.0),
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.black45),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Replying to ${snapshot.data['username']}'),
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                child: Icon(Icons.cancel_outlined),
                                onPressed: () {
                                  _bloc.onTapCancelReply(context);
                                },
                              )
                            ],
                          ),
                        );
                      },
                    ),
                    StreamBuilder<int>(
                      initialData: null,
                      stream: _bloc.editingSubject,
                      builder: (context, snapshot) {
                        if (snapshot.data != null) {
                          final prevMessage = _bloc.commentController.text;
                          return Container(
                            width: double.infinity,
                            margin:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.black45),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text('Editing Comment: '),
                                Expanded(
                                  child: Text(
                                    '$prevMessage',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  child: Icon(Icons.cancel_outlined),
                                  onPressed: () {
                                    _bloc.onTapCancelReply(context);
                                  },
                                )
                              ],
                            ),
                          );
                        }
                        return Container();
                      },
                    ),
                    StreamBuilder<int>(
                        initialData: null,
                        stream: _bloc.editingSubject,
                        builder: (context, editingSnapshot) {
                          return Row(
                            children: [
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  child: CupertinoTextField(
                                    placeholder: 'Add a comment',
                                    controller: _bloc.commentController,
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 4),
                                    decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        border: Border.all(
                                            color:
                                                Theme.of(context).accentColor),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    keyboardType: TextInputType.text,
                                    prefix: editingSnapshot.data != null
                                        ? Padding(
                                            padding: EdgeInsets.only(
                                                bottom: 20, left: 5),
                                            child: Text('Editing: '))
                                        : null,
                                    prefixMode: OverlayVisibilityMode.always,
                                    maxLines: 2,
                                    textInputAction: TextInputAction.done,
                                    clearButtonMode:
                                        OverlayVisibilityMode.editing,
                                  ),
                                ),
                              ),
                              StreamBuilder<bool>(
                                  initialData: false,
                                  stream: _bloc.postButtonSubject,
                                  builder: (context, snapshot) {
                                    if (snapshot.data) {
                                      return CupertinoButton(
                                        padding: EdgeInsets.only(right: 5),
                                        child: CupertinoActivityIndicator(),
                                        onPressed: () {},
                                      );
                                    }
                                    return CupertinoButton(
                                      padding: EdgeInsets.only(right: 5),
                                      child: Text(editingSnapshot.data != null
                                          ? "Edit"
                                          : "Post"),
                                      onPressed: () {
                                        _bloc.postComment(context);
                                      },
                                    );
                                  })
                            ],
                          );
                        }),
                  ],
                )
              ],
            ),
          ),
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
  // final _repliesSubject = BehaviorSubject<List<NFReply>>.seeded([]);
  // int start = 0;
  // int end = 0;

  // @override
  // void initState() {
  //   end = widget.item.reply.length >= 3 ? 3 : widget.item.reply.length;
  //   addMoreReply();
  //   super.initState();
  // }

  // @override
  // void dispose() {
  //   _repliesSubject.close();
  //   super.dispose();
  // }

  // void addMoreReply() {
  //   List<NFReply> replies = [];
  //   end = min(widget.item.reply.length, end);
  //   while (start < end) {
  //     replies.add(widget.item.reply[start]);
  //     start++;
  //   }
  //   end += replies.length;
  //   _repliesSubject.first.then((prev) {
  //     _repliesSubject.add(prev + replies);
  //   });
  // }

  Widget commentListTile(dynamic item) {
    if (item is NFComment) {
      return Column(
        children: [
          Row(
            children: [
              item.userProfileImage == null
                  ? Icon(Icons.error)
                  : CachedNetworkImage(
                      fit: BoxFit.fill,
                      imageUrl: item.userProfileImage,
                      imageBuilder: (context, provider) {
                        return CircleAvatar(
                          backgroundImage: provider,
                        );
                      },
                      placeholder: (_, __) => CupertinoActivityIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
              SizedBox(width: 10),
              Expanded(
                  child: RichText(
                text: TextSpan(
                    text: item.username,
                    style: TextStyle(fontWeight: FontWeight.bold),
                    children: <TextSpan>[
                      TextSpan(
                          text: '  ${item.message}',
                          style: Theme.of(context).textTheme.bodyText1),
                    ]),
              ))
            ],
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                timeAgo.format(DateTime.parse(item.createdAt),
                    allowFromNow: true),
                style: TextStyle(color: Colors.grey, fontSize: 12.0),
              ),
              SizedBox(width: 10),

              ///If Comment's parentCommentId = -1 it's parent
              if (item.parentCommentId == -1 && widget.bloc.myId != item.userId)
                InkResponse(
                  onTap: () {
                    widget.bloc
                        .onTapReply(context, item.username, item.commentId);
                  },
                  child: Text('Reply',
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14.0)),
                ),
              if (item.userId == widget.bloc.myId)
                Row(
                  children: [
                    SizedBox(width: 10),
                    InkResponse(
                      onTap: () {
                        widget.bloc
                            .onTapEdit(context, item.commentId, item.message);
                      },
                      child: Text('Edit',
                          style: TextStyle(
                              color: Theme.of(context).accentColor,
                              fontSize: 14.0)),
                    ),
                    SizedBox(width: 10),
                    InkResponse(
                      onTap: () {
                        widget.bloc.onTapDelete(context, item.commentId);
                      },
                      child: Text('Delete',
                          style: TextStyle(
                              color: Colors.red[600], fontSize: 14.0)),
                    ),
                  ],
                )
            ],
          ),
        ],
      );
    } else if (item is NFReply) {
      return Column(
        children: [
          Row(
            children: [
              item.userProfileImage == null
                  ? Icon(Icons.error)
                  : CachedNetworkImage(
                      fit: BoxFit.fill,
                      imageUrl: item.userProfileImage,
                      imageBuilder: (context, provider) {
                        return CircleAvatar(
                          backgroundImage: provider,
                        );
                      },
                      placeholder: (_, __) => CupertinoActivityIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
              SizedBox(width: 10),
              Expanded(
                  child: RichText(
                text: TextSpan(
                    text: item.username,
                    style: TextStyle(fontWeight: FontWeight.bold),
                    children: <TextSpan>[
                      TextSpan(
                          text: '  ${item.message}',
                          style: Theme.of(context).textTheme.bodyText1),
                    ]),
              ))
            ],
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                timeAgo.format(DateTime.parse(item.createdAt),
                    allowFromNow: true),
                style: TextStyle(color: Colors.grey, fontSize: 12.0),
              ),
              SizedBox(width: 10),

              ///If Comment's parentCommentId = -1 it's parent
              if (item.parentCommentId == -1 && widget.bloc.myId != item.userId)
                InkResponse(
                  onTap: () {
                    widget.bloc
                        .onTapReply(context, item.username, item.commentId);
                  },
                  child: Text('Reply',
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14.0)),
                ),
              if (item.userId == widget.bloc.myId)
                Row(
                  children: [
                    SizedBox(width: 10),
                    InkResponse(
                      onTap: () {
                        widget.bloc
                            .onTapEdit(context, item.commentId, item.message);
                      },
                      child: Text('Edit',
                          style: TextStyle(
                              color: Theme.of(context).accentColor,
                              fontSize: 14.0)),
                    ),
                    SizedBox(width: 10),
                    InkResponse(
                      onTap: () {
                        widget.bloc.onTapDelete(context, item.commentId);
                      },
                      child: Text('Delete',
                          style: TextStyle(
                              color: Colors.red[600], fontSize: 14.0)),
                    ),
                  ],
                )
            ],
          ),
        ],
      );
    } else {
      return Text("Wrong Object Error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          commentListTile(widget.item),
          if (widget.item.reply.isNotEmpty) SizedBox(height: 5),
          if (widget.item.reply.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(left: 30.0),
              child: ListView(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                children: widget.item.reply.map((item) {
                  return commentListTile(item);
                }).toList(),
              ),
            ),
          // if (widget.item.reply.isNotEmpty)
          //   Container(
          //     margin: const EdgeInsets.symmetric(horizontal: 30.0),
          //     child: StreamBuilder<List<NFReply>>(
          //         initialData: [],
          //         stream: _repliesSubject,
          //         builder: (context, snapshot) {
          //           if (snapshot.data == null || snapshot.data.isEmpty) {
          //             return Container();
          //           }
          //           return ListView(
          //             shrinkWrap: true,
          //             physics: ClampingScrollPhysics(),
          //             children: snapshot.data.map((item) {
          //               return commentListTile(item);
          //             }).toList(),
          //           );
          //         }),
          //   ),
          // if (widget.item.reply.isNotEmpty) SizedBox(height: 5),
          // if (widget.item.reply.isNotEmpty)
          //   StreamBuilder<List<NFReply>>(
          //     initialData: [],
          //     stream: _repliesSubject,
          //     builder: (context, snapshot) {
          //       if (snapshot.data == null || snapshot.data.isEmpty) {
          //         return Container();
          //       }
          //       if (start >= widget.item.reply.length) return Container();
          //       return Container(
          //         margin: const EdgeInsets.symmetric(horizontal: 30.0),
          //         child: InkWell(
          //           onTap: () {
          //             addMoreReply();
          //           },
          //           child: Text(
          //             'View more replies',
          //             style: TextStyle(
          //                 color: Theme.of(context).accentColor),
          //           ),
          //         ),
          //       );
          //     },
          //   )
        ],
      ),
    );
  }
}
