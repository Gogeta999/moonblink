import 'package:flutter/material.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/models/story.dart';
import 'package:moonblink/view_model/login_model.dart';
import 'package:story_view/story_view.dart';

class StoriesPage extends StatefulWidget {
  StoriesPage({this.story, this.index});
  final List<Story> story;
  final int index;
  @override
  _StoriesPageState createState() => _StoriesPageState();
}

class _StoriesPageState extends State<StoriesPage> {
  List<Stories> storys = [];
  List<Story> userstories = [];
  final StoryController storyController = StoryController();
  final PageController userController = PageController();
  int current;

  @override
  void initState() {
    super.initState();
    setState(() {
      current = widget.index;
      userstories = widget.story;
    });
  }

  @override
  void dispose() {
    userController.dispose();
    storyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
        onPageChanged: (int index) {
          print("current index is $index");
          setState(() {
            current = index;
          });
        },
        controller: userController,
        itemCount: widget.story.length,
        itemBuilder: (context, index) {
          print("Current is $current");
          print("userstories length ${userstories.length}");
          Story userstory = userstories[current];
          // print("current story ${userstory.toString()}");
          List users = userstory.storys;
          storys.clear();
          // print("User Stories is cleared");
          for (var i = 0; i < users.length; i++) {
            Stories stories = Stories.fromJson(users[i]);
            storys.insert(0, stories);
          }
          print("Before length ${storys.length}");
          return Stack(
            children: <Widget>[
              //Story View
              StoryViewScreen(
                items: storys,
                length: userstories.length,
                current: current,
                controller: userController,
                // valuenotifier: _currentPageNotifier,
              ),
              //User tile
              Padding(
                padding: new EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Row(children: <Widget>[
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    backgroundImage: NetworkImage(userstory.profile),
                  ),
                  Text(
                    userstory.name,
                    style: TextStyle(
                      decoration: TextDecoration.none,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  )
                ]),
              ),
            ],
          );
        });
  }
}

class StoryViewScreen extends StatefulWidget {
  StoryViewScreen({
    @required this.items,
    this.current,
    this.length,
    this.controller,
  });
  final List<Stories> items;
  final int current;
  final int length;
  final PageController controller;
  @override
  _StoryViewScreenState createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<StoryViewScreen> {
  final StoryController storyController = StoryController();
  List<StoryItem> storyItems = [];
  int usertype = StorageManager.sharedPreferences.getInt(mUserType);
  var notifier = ValueNotifier<int>(0);
  int index;
  @override
  void initState() {
    super.initState();
    setState(() {
      index = widget.current;
    });

    print("Storys Length is ${widget.items}");
    widget.items.forEach((story) {
      if (story.type == 1) {
        storyItems.add(StoryItem.pageImage(
          url: story.media,
          controller: storyController,
          // caption: story.caption,
          duration: Duration(
            seconds: (3).toInt(),
          ),
        ));
      }

      if (story.type == 2) {
        storyItems.add(
          StoryItem.pageVideo(
            story.media,
            controller: storyController,
            duration: Duration(seconds: (10).toInt()),
            // caption: story.caption,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: StoryView(
        controller: storyController,
        storyItems: storyItems,
        onComplete: () {
          print("Complete");
          // print(widget.length);
          // print(widget.current);
          if (widget.length > widget.current + 1) {
            print("increaseing index");
            index++;
            // router.value += 1;
            return widget.controller.jumpToPage(index);
            // return widget.current += 1;
          } else {
            Navigator.pop(context);
          }
        },
        onStoryShow: (story) {},
        onVerticalSwipeComplete: (v) {
          if (v == Direction.down) {
            Navigator.pop(context);
          }
        },
      ),
      onHorizontalDragEnd: (details) {
        // Swipe left
        if (details.primaryVelocity < 0) {
          print("Swipeing Left");
          if (index < widget.length - 1) {
            index++;
            return widget.controller.jumpToPage(index);
          } else {
            Navigator.pop(context);
          }
        }
        //Swipe Right
        else if (details.primaryVelocity > 0) {
          print("Swiping Right");
          print(index);
          if (usertype != 1) {
            if (index > 0) {
              setState(() {
                index--;
                return widget.controller.jumpToPage(index);
                // print("jumping Next Page");
              });
            } else {
              Navigator.pop(context);
            }
          } else {
            if (index > 1) {
              setState(() {
                index--;
                return widget.controller.jumpToPage(index);
                // print("jumping Next Page");
              });
            } else {
              Navigator.pop(context);
            }
          }
        }
      },
    );
  }
}
