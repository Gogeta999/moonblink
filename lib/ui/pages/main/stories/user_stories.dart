import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/indicator/story_pageview_indicator.dart';
import 'package:moonblink/models/story.dart';
import 'package:story_view/story_view.dart';

class StoriesPage extends StatefulWidget {
  StoriesPage({this.story, this.index});
  final List<Story> story;
  final int index;
  @override
  _StoriesPageState createState() => _StoriesPageState();
}

class _StoriesPageState extends State<StoriesPage> {
  // final storyController = StoryController();
  List<Stories> storys = [];
  // List<Story> userstories = [];
  // Story userstory;
  // List users = [];
  final StoryController storyController = StoryController();

  int current;
  @override
  void initState() {
    super.initState();
    setState(() {
      current = widget.index;
    });
  }

  @override
  void dispose() {
    storyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final PageController userController = PageController();
    final currentPageNotifier1 = ValueNotifier<int>(current);
    final _currentPageNotifier = ValueNotifier<int>(0);

    return PageView.builder(
        onPageChanged: (int index) {
          currentPageNotifier1.value = index;
        },
        controller: userController,
        itemCount: widget.story.length,
        itemBuilder: (context, index) {
          final PageController storypageController = PageController();
          // current = index + 1;
          print("Current is $current");
          List<Story> userstories = widget.story;
          print("userstories length ${userstories.length}");
          Story userstory = userstories[current];
          print("current story ${userstory.toString()}");
          List users = userstory.storys;
          // print("Stories ${users.length.toString()}");
          // print("Current index is $current");
          storys.clear();
          for (var i = 0; i < users.length; i++) {
            Stories stories = Stories.fromJson(users[i]);
            storys.add(stories);
          }
          return Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  color: Colors.black,
                  padding: const EdgeInsets.all(16.0),
                  child: StepPageIndicator(
                    currentPageNotifier: _currentPageNotifier,
                    itemCount: storys.length,
                    onPageSelected: (int pageIndex) {
                      if (_currentPageNotifier.value > pageIndex)
                        storypageController.jumpToPage(pageIndex);
                    },
                  ),
                ),
              ),
              Center(
                // height: 500,
                child: SizedBox(
                  height: 400,
                  child: PageView.builder(
                      onPageChanged: (int pageIndex) {
                        _currentPageNotifier.value = pageIndex;
                      },
                      controller: storypageController,
                      itemCount: storys.length,
                      itemBuilder: (context, pageindex) {
                        Stories story = storys[pageindex];
                        // print(story.id);
                        if (story.type == 2) {
                          return GestureDetector(
                            onTap: _currentPageNotifier.value ==
                                    storys.length - 1
                                ? () {
                                    if (current < userstories.length - 1) {
                                      setState(() {
                                        index = current++;
                                      });
                                      currentPageNotifier1.value += 1;
                                      userController.jumpToPage(
                                          currentPageNotifier1.value);
                                    } else {
                                      Navigator.pop(context);
                                    }
                                  }
                                : () {
                                    _currentPageNotifier.value += 1;
                                    storypageController
                                        .jumpToPage(_currentPageNotifier.value);
                                  },
                            onVerticalDragUpdate: (dragUpdateDetails) {
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              child: StoryVideo.url(story.media,
                                  controller: storyController),
                            ),
                          );
                        }
                        return GestureDetector(
                          onTap: _currentPageNotifier.value == storys.length - 1
                              ? () {
                                  if (current < userstories.length - 1) {
                                    setState(() {
                                      index = current++;
                                    });
                                    // Navigator.pop(context);

                                    currentPageNotifier1.value += 1;
                                    userController
                                        .jumpToPage(currentPageNotifier1.value);
                                  } else {
                                    Navigator.pop(context);
                                  }
                                }
                              : () {
                                  _currentPageNotifier.value += 1;
                                  storypageController
                                      .jumpToPage(_currentPageNotifier.value);
                                },
                          onVerticalDragUpdate: (dragUpdateDetails) {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            child: StoryImage.url(
                              story.media,
                              controller: storyController,
                            ),
                          ),
                        );
                      }),
                ),
              ),
              Padding(
                padding: new EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Column(children: <Widget>[
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
