import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/container/roundedContainer.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/story.dart';
import 'package:moonblink/ui/pages/main/stories/story_item.dart';
import 'package:moonblink/view_model/login_model.dart';

class StoryList extends StatelessWidget {
  final List<Story> stories;
  StoryList({this.stories});
  @override
  Widget build(BuildContext context) {
    print("----------------------------------------------");
    // HomeModel homeModel = Provider.of(context);
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
          child: RoundedContainer(
              height: 80,
              color: Theme.of(context).scaffoldBackgroundColor,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: stories.length,
                  itemBuilder: (context, index) {
                    // Story singleUserStories = homeModel.stories[index];
                    int usertype =
                        StorageManager.sharedPreferences.getInt(mUserType);

                    if (usertype != 0 && index == 0) {
                      return InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed(RouteName.imagepick);
                        },
                        child: CircleAvatar(
                          radius: 33,
                          backgroundColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                          child: CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.grey[300],
                            child:
                                Icon(Icons.add, size: 24, color: Colors.black),
                          ),
                        ),
                      );
                    }
                    return StoryItemWidget(
                      stories,
                      index: index,
                    );
                  })),
        ),
        Divider(
          thickness: 1,
          color: Colors.black,
        ),
      ],
    );
  }
}
