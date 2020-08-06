import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/indicator/story_pageview_indicator.dart';
import 'package:moonblink/models/story.dart';
import 'package:story_view/story_view.dart';

class StoriesPage extends StatefulWidget {
  StoriesPage(this.stories, this.partnerProfile, this.name);
  final List stories;
  final partnerProfile;
  final name;
  @override
  _StoriesPageState createState() => _StoriesPageState();
}

class _StoriesPageState extends State<StoriesPage> {
  final storyController = StoryController();
  List<Stories> storys = [];

  @override
  void dispose() {
    storyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController();
    final _currentPageNotifier = ValueNotifier<int>(0);
    final StoryController storyController = StoryController();
    print(widget.stories.length);
    for (var i = 0; i < widget.stories.length; i++) {
      Stories stories = Stories.fromJson(widget.stories[i]);
      storys.add(stories);
    }
    print(storys);

    return Stack(
      children: <Widget>[
        Padding(
          padding: new EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(children: <Widget>[
            CircleAvatar(
              radius: 25,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              backgroundImage: NetworkImage(widget.partnerProfile),
            ),
            Text(
              widget.name,
              style: TextStyle(
                decoration: TextDecoration.none,
                fontSize: 18,
                color: Colors.white,
              ),
            )
          ]),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            color: Colors.black,
            padding: const EdgeInsets.all(16.0),
            child: StepPageIndicator(
              currentPageNotifier: _currentPageNotifier,
              itemCount: widget.stories.length,
              onPageSelected: (int pageIndex) {
                if (_currentPageNotifier.value > pageIndex)
                  pageController.jumpToPage(pageIndex);
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
                controller: pageController,
                itemCount: widget.stories.length,
                itemBuilder: (context, index) {
                  Stories story = storys[index];
                  print(story.id);
                  if (story.type == 2) {
                    return GestureDetector(
                      onTap: _currentPageNotifier.value ==
                              widget.stories.length - 1
                          ? () {
                              Navigator.pop(context);
                            }
                          : () {
                              _currentPageNotifier.value += 1;
                              pageController
                                  .jumpToPage(_currentPageNotifier.value);
                            },
                      child: Container(
                        child: StoryVideo.url(story.media,
                            controller: storyController),
                      ),
                    );
                  }
                  return GestureDetector(
                    onTap:
                        _currentPageNotifier.value == widget.stories.length - 1
                            ? () {
                                Navigator.pop(context);
                              }
                            : () {
                                _currentPageNotifier.value += 1;
                                pageController
                                    .jumpToPage(_currentPageNotifier.value);
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
      ],
    );
  }
}
