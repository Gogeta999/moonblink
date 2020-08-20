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
  List<Stories> storys = [];
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
        onPageChanged: (int index) {},
        controller: userController,
        itemCount: widget.story.length,
        itemBuilder: (context, index) {
          final PageController storypageController = PageController();
          print("Current is $current");
          List<Story> userstories = widget.story;
          print("userstories length ${userstories.length}");
          Story userstory = userstories[current];
          print("current story ${userstory.toString()}");
          List users = userstory.storys;
          storys.clear();
          for (var i = 0; i < users.length; i++) {
            Stories stories = Stories.fromJson(users[i]);
            storys.insert(0, stories);
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
                        if (story.type == 2) {
                          return GestureDetector(
                            //Tap
                            onTapUp: (TapUpDetails details) {
                              //Tap on Right
                              if (details.globalPosition.dx > 200) {
                                if (_currentPageNotifier.value ==
                                    storys.length - 1) {
                                  if (current < userstories.length - 1) {
                                    setState(() {
                                      index = current++;
                                    });
                                    currentPageNotifier1.value += 1;
                                    userController
                                        .jumpToPage(currentPageNotifier1.value);
                                  } else {
                                    Navigator.pop(context);
                                  }
                                } else {
                                  _currentPageNotifier.value += 1;
                                  storypageController
                                      .jumpToPage(_currentPageNotifier.value);
                                }
                              }
                              //Tap on Left
                              else {
                                if (_currentPageNotifier.value != 0) {
                                  _currentPageNotifier.value -= 1;
                                  storypageController
                                      .jumpToPage(_currentPageNotifier.value);
                                } else {
                                  if (current > 1) {
                                    setState(() {
                                      index = current--;
                                    });
                                    currentPageNotifier1.value -= 1;
                                    userController
                                        .jumpToPage(currentPageNotifier1.value);
                                  } else {
                                    Navigator.pop(context);
                                  }
                                }
                              }
                            },
                            //Horizontal Swipe
                            onHorizontalDragEnd: (details) {
                              //Swipe left
                              if (details.primaryVelocity < 0) {
                                if (current < userstories.length - 1) {
                                  setState(() {
                                    index = current++;
                                  });
                                  currentPageNotifier1.value += 1;
                                  userController
                                      .jumpToPage(currentPageNotifier1.value);
                                } else {
                                  Navigator.pop(context);
                                }
                              }
                              //Swipe Right
                              else if (details.primaryVelocity > 0) {
                                if (current > 1) {
                                  setState(() {
                                    index = current--;
                                  });
                                  currentPageNotifier1.value -= 1;
                                  userController
                                      .jumpToPage(currentPageNotifier1.value);
                                } else {
                                  Navigator.pop(context);
                                }
                              }
                            },
                            //Vertical Swipe
                            onVerticalDragUpdate: (dragUpdateDetails) {
                              Navigator.of(context).pop();
                            },
                            //Story Video View
                            child: Container(
                              child: StoryVideo.url(story.media,
                                  controller: storyController),
                            ),
                          );
                        }
                        return GestureDetector(
                          //Tap
                          onTapUp: (TapUpDetails details) {
                            //Tap on Right
                            if (details.globalPosition.dx > 200) {
                              if (_currentPageNotifier.value ==
                                  storys.length - 1) {
                                if (current < userstories.length - 1) {
                                  setState(() {
                                    index = current++;
                                  });
                                  currentPageNotifier1.value += 1;
                                  userController
                                      .jumpToPage(currentPageNotifier1.value);
                                } else {
                                  Navigator.pop(context);
                                }
                              } else {
                                _currentPageNotifier.value += 1;
                                storypageController
                                    .jumpToPage(_currentPageNotifier.value);
                              }
                            }
                            //Tap on Left
                            else {
                              if (_currentPageNotifier.value != 0) {
                                _currentPageNotifier.value -= 1;
                                storypageController
                                    .jumpToPage(_currentPageNotifier.value);
                              } else {
                                if (current > 1) {
                                  setState(() {
                                    index = current--;
                                  });
                                  currentPageNotifier1.value -= 1;
                                  userController
                                      .jumpToPage(currentPageNotifier1.value);
                                } else {
                                  Navigator.pop(context);
                                }
                              }
                            }
                          },
                          //Horizontal Swipe
                          onHorizontalDragEnd: (details) {
                            //Swipe left
                            if (details.primaryVelocity < 0) {
                              if (current < userstories.length - 1) {
                                setState(() {
                                  index = current++;
                                });
                                currentPageNotifier1.value += 1;
                                userController
                                    .jumpToPage(currentPageNotifier1.value);
                              } else {
                                Navigator.pop(context);
                              }
                            }
                            //Swipe Right
                            else if (details.primaryVelocity > 0) {
                              if (current > 1) {
                                setState(() {
                                  index = current--;
                                });
                                currentPageNotifier1.value -= 1;
                                userController
                                    .jumpToPage(currentPageNotifier1.value);
                              } else {
                                Navigator.pop(context);
                              }
                            }
                          },
                          //Vertical Swipe
                          onVerticalDragUpdate: (dragUpdateDetails) {
                            Navigator.of(context).pop();
                          },
                          //Story Image View
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
              //User tile
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
