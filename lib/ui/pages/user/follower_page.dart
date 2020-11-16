import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moonblink/base_widget/appbar/appbarlogo.dart';
import 'package:moonblink/base_widget/container/usercontainer.dart';
import 'package:moonblink/bloc_pattern/chat_box/chat_box_bloc.dart';
import 'package:moonblink/global/resources_manager.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/follower.dart';
import 'package:moonblink/provider/provider_widget.dart';
import 'package:moonblink/ui/pages/main/chat/chat_box_page.dart';
import 'package:moonblink/utils/status_bar_utils.dart';
import 'package:moonblink/view_model/follower_model.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:oktoast/oktoast.dart';

class FollowerPage extends StatefulWidget {
  final String name;
  final int id;
  FollowerPage(this.id, this.name);
  @override
  _FollowerPageState createState() => _FollowerPageState();
}

class _FollowerPageState extends State<FollowerPage> {
  List<Follower> followers = [];
  int usertype;
  @override
  void initState() {
    super.initState();
    setState(() {
      usertype = StorageManager.sharedPreferences.getInt(mUserType);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        actions: [
          AppbarLogo(),
        ],
      ),
      body: ProviderWidget<FollowersModel>(
        model: FollowersModel(widget.id),
        onModelReady: (followerModel) {
          followerModel.initData();
        },
        builder: (context, followerModel, child) {
          if (followerModel.isBusy &&
              Theme.of(context).brightness == Brightness.light) {
            return Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(
                        ImageHelper.wrapAssetsImage('bookingWaiting.gif'),
                      ),
                      fit: BoxFit.fill)),
            );
          }
          if (followerModel.isBusy &&
              Theme.of(context).brightness == Brightness.dark) {
            return Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(
                        ImageHelper.wrapAssetsImage('moonblinkWaitingDark.gif'),
                      ),
                      fit: BoxFit.fill)),
            );
          }
          if (followerModel.isError && followerModel.list.isEmpty) {
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: StatusBarUtils.systemUiOverlayStyle(context),
              child: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: Theme.of(context).brightness == Brightness.light
                            ? AssetImage(ImageHelper.wrapAssetsImage(
                                'noFollowingDay.png'))
                            : AssetImage(ImageHelper.wrapAssetsImage(
                                'noFollowingDark.jpg')),
                        fit: BoxFit.cover)),
                width: double.infinity,
                height: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 200,
                      child: CupertinoButton(
                        color: Colors.transparent,
                        child: Text(
                          "${followerModel.viewStateError.errorMessage}",
                          style: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.black
                                  : Colors.white,
                              fontSize: 20),
                        ),
                        onPressed: followerModel.initData,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          followers.clear();
          for (var i = 0; i < followerModel.list.length; i++) {
            Follower follower = followerModel.list[i];
            followers.add(follower);
          }
          return ListView.builder(
            itemBuilder: (context, index) {
              
              Follower follower = followers[index];
              print(follower.profileimage);
              print("++++++++++++++++++++++++++++++++++++++++++++++++++");
              return UserTile(
                onTap: () {
                  if (usertype != 0 || follower.type != 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewChatBoxPage(follower.userId),
                      ),
                    );
                  } else {
                    showToast("This user is Normal");
                  }
                },
                image: CachedNetworkImage(
                  imageUrl: follower.profileimage,
                  imageBuilder: (context, imageProvider) => CircleAvatar(
                    radius: 33,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    backgroundImage: imageProvider,
                  ),
                  placeholder: (context, url) => CircleAvatar(
                    radius: 33,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    // backgroundImage: ,
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
                name: Text(follower.name),
              );
            },
            itemCount: followerModel.list.length,
          );
        },
      ),
    );
  }
}
