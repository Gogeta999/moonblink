import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moonblink/base_widget/imageview.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/models/contact.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/ui/helper/cached_helper.dart';
import 'package:moonblink/ui/pages/user/partner_detail_page.dart';
import 'package:moonblink/view_model/home_model.dart';
import 'package:oktoast/oktoast.dart';
import 'package:share/share.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class ContactContainer extends StatefulWidget {
  final Contact contact;
  ContactContainer(this.contact);
  @override
  _ContactContainerState createState() => _ContactContainerState();
}

class _ContactContainerState extends State<ContactContainer> {
  String _profileUrl;
  Widget postprofile(Contact contact) {
    return CachedNetworkImage(
      imageUrl: widget.contact.contactUser.contactUserProfile,
      imageBuilder: (context, imageProvider) => Padding(
        padding: const EdgeInsets.only(top: 12, left: 15),
        child: CircleAvatar(
          radius: 30,
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey
              : Colors.black,
          child: CircleAvatar(
            radius: 28,
            backgroundColor: Colors.transparent,
            backgroundImage: imageProvider,
            child: GestureDetector(
              onTap: () {
                int detailPageId = widget.contact.contactUser.contactUserId;
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                PartnerDetailPage(detailPageId)))
                    .then((value) async {
                  // if (value != null) {
                  //   setState(() {
                  //     isBlocking = true;
                  //   });

                  //   ///Blocking user
                  //   await homeModel
                  //       .removeItem(
                  //           index: widget.index,
                  //           blockUserId: widget.posts.userID)
                  //       .then((value) {
                  //     value
                  //         ? showToast('Successfully Blocked')
                  //         : showToast('Error Blocking User');
                  //   });
                  //   setState(() {
                  //     isBlocking = false;
                  //   });
                  // }
                });
              },
            ),
          ),
        ),
      ),
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey.shade600,
        child: IconButton(
          onPressed: () {
            setState(() {
              _profileUrl = widget.contact.contactUser.contactUserProfile;
            });
          },
          icon: Icon(
            Icons.refresh,
            color: Colors.grey.shade300,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            width: 2.0,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey
                : Colors.black,
          ),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Stack(
          children: [
            Column(
              children: <Widget>[
                /// [user_Profile]
                Container(
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 80.0),
                        child: Text(widget.contact.contactUser.contactUserName),
                      ),
                      Spacer(),
                      // Align(
                      //     alignment: Alignment.centerRight,
                      //     child: blockbtn(homeModel)),
                    ],
                  ),
                ),

                /// [User_Image]
                ProviderWidget(
                  model: HomeModel(),
                  builder: (context, reactModel, child) {
                    return Column(
                      children: <Widget>[
                        InkWell(
                          child: Container(
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
                            constraints: BoxConstraints(
                                // minHeight: MediaQuery.of(context)
                                //         .size
                                //         .height /
                                //     2.5,
                                // maxHeight: MediaQuery.of(context)
                                //         .size
                                //         .height /
                                //     1.5,
                                minWidth: double.infinity,
                                maxWidth: double.infinity),
                            child: CachedNetworkImage(
                              fit: BoxFit.fill,
                              imageUrl:
                                  widget.contact.contactUser.contactUserCover,
                              placeholder: (context, url) => CachedLoader(
                                containerHeight: 200,
                              ),
                              errorWidget: (context, url, error) => CachedError(
                                containerHeight: 200,
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ImageView(widget
                                    .contact.contactUser.contactUserCover),
                              ),
                            );
                            print('object');
                          },
                          onDoubleTap: widget.contact.contactUser.reacted == 0
                              ? () {
                                  reactModel
                                      .reactProfile(
                                          widget.contact.contactUser
                                              .contactUserId,
                                          1)
                                      .then(
                                    (value) {
                                      if (value) {
                                        showToast(
                                            G.of(context).toastlikesuccess);
                                        setState(() {
                                          widget.contact.contactUser.reacted =
                                              1;
                                          widget.contact.contactUser
                                              .reactioncount += 1;
                                        });
                                      } else {
                                        reactModel.showErrorMessage(context);
                                      }
                                    },
                                  );
                                }
                              : () {
                                  reactModel
                                      .reactProfile(
                                          widget.contact.contactUser
                                              .contactUserId,
                                          0)
                                      .then(
                                    (value) {
                                      if (value) {
                                        showToast(
                                            G.of(context).toastunlikesuccess);
                                        setState(
                                          () {
                                            widget.contact.contactUser.reacted =
                                                0;
                                            widget.contact.contactUser
                                                .reactioncount -= 1;
                                          },
                                        );
                                      } else {
                                        reactModel.showErrorMessage(context);
                                      }
                                    },
                                  );
                                },
                        ),

                        /// [User_bottom data]
                        Container(
                          height: 30,
                          width: double.infinity,
                          margin: EdgeInsets.all(8.0),
                          child: Stack(
                            children: <Widget>[
                              Align(
                                alignment: Alignment.centerLeft,
                                child: InkWell(
                                  child: Icon(
                                      widget.contact.contactUser.reacted == 0
                                          ? FontAwesomeIcons.heart
                                          : FontAwesomeIcons.solidHeart,
                                      size: 30,
                                      color: widget.contact.contactUser
                                                  .reacted ==
                                              0
                                          ? Theme.of(context).iconTheme.color
                                          : Colors.red[400]),
                                  onTap: widget.contact.contactUser.reacted == 0
                                      ? () {
                                          reactModel
                                              .reactProfile(
                                                  widget.contact.contactUser
                                                      .contactUserId,
                                                  1)
                                              .then((value) {
                                            if (value) {
                                              showToast(G
                                                  .of(context)
                                                  .toastlikesuccess);
                                              setState(() {
                                                widget.contact.contactUser
                                                    .reacted = 1;
                                                widget.contact.contactUser
                                                    .reactioncount += 1;
                                              });
                                            } else {
                                              reactModel
                                                  .showErrorMessage(context);
                                            }
                                          });
                                        }
                                      : () {
                                          reactModel
                                              .reactProfile(
                                                  widget.contact.contactUser
                                                      .contactUserId,
                                                  0)
                                              .then((value) {
                                            if (value) {
                                              showToast(G
                                                  .of(context)
                                                  .toastunlikesuccess);
                                              setState(() {
                                                widget.contact.contactUser
                                                    .reacted = 0;
                                                widget.contact.contactUser
                                                    .reactioncount -= 1;
                                              });
                                            } else {
                                              reactModel
                                                  .showErrorMessage(context);
                                            }
                                          });
                                        },
                                ),
                              ),
                              Positioned(
                                  left: 40,
                                  bottom: 5,
                                  child: Text(
                                      '${widget.contact.contactUser.reactioncount} ${G.of(context).likes}')),
                              Center(
                                child: Container(
                                  margin: EdgeInsets.only(
                                      left: 8.0, top: 3, bottom: 5),
                                  // padding:
                                  //     EdgeInsets.symmetric(vertical: 6),
                                  child: Text(
                                    G.of(context).becomePartnerAt +
                                        //DateFormat.jm().format(DateTime.parse(widget.posts.createdAt)),
                                        timeAgo.format(
                                            DateTime.parse(
                                                widget.contact.createdAt),
                                            allowFromNow: true),
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 12.0),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  icon: Icon(FontAwesomeIcons.share),
                                  onPressed: () {
                                    final RenderBox box =
                                        context.findRenderObject();
                                    Share.share(
                                        'https://play.google.com/store/apps/details?id=com.moonuniverse.moonblink',
                                        subject: 'Please download our app',
                                        sharePositionOrigin:
                                            box.localToGlobal(Offset.zero) &
                                                box.size);
                                  },
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    );
                  },
                ),

                /// [bottom date]

                Divider(
                  height: 5,
                ),
              ],
            ),
            postprofile(widget.contact),
          ],
        ),
      ),
    );
  }
}
