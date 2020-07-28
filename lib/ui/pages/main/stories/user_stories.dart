import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/indicator/story_pageview_indicator.dart';
import 'package:moonblink/models/story.dart';
import 'package:story_view/story_view.dart';

class StoriesPage extends StatefulWidget {
  StoriesPage(this.stories, this.partnerProfile);
  final List stories;
  final partnerProfile;
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
        // Align(
        //   alignment: Alignment.topLeft,
        //   child: CircleAvatar(
        //     radius: 20,
        //   ),
        // ),
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
                      onTap: () {
                        _currentPageNotifier.value == widget.stories.length - 1
                            ? Navigator.pop(
                                context) //{_currentPageNotifier.value = 0, Navigator.pop(context)}
                            : _currentPageNotifier.value += 1;
                      },
                      child: Container(
                        child: StoryVideo.url(story.media,
                            controller: storyController),
                      ),
                    );
                  }
                  return GestureDetector(
                    onTap: () {
                      _currentPageNotifier.value == widget.stories.length - 1
                          ? Navigator.pop(context)
                          : _currentPageNotifier.value += 1;
                    },
                    // onDoubleTap: () {
                    //   var userId = StorageManager.sharedPreferences.get(mUserId);
                    //   if(userId == 1) {
                    //     showDialog(
                    //         context: context,
                    //         builder: (context) {
                    //           return AlertDialog(
                    //             title: Text(
                    //                 'You are about to delete this story.'),
                    //             actions: <Widget>[
                    //               RaisedButton(
                    //                 onPressed: () => Navigator.pop(context),
                    //                 child: Text('Cancel'),
                    //               ),
                    //               RaisedButton(
                    //                 onPressed: () async{
                    //                   //Navigator.pop(context);
                    //                   await storyModel.dropStory(
                    //                       storyModel
                    //                           .stories[
                    //                       _currentPageNotifier.value]
                    //                           .id);
                    //                   Navigator.pushNamedAndRemoveUntil(context, RouteName.main, (route) => false);
                    //                 },
                    //                 child: Text('Delete'),
                    //               )
                    //             ],
                    //           );
                    //         });
                    //   }
                    // },
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

// class Indicator extends StatelessWidget {
//   Indicator({
//     this.controller,
//     this.itemCount: 0,
//   }) : assert(controller != null);

//   /// PageView Controller
//   final PageController controller;

//   /// Indicator Count
//   final int itemCount;

//   final Color normalColor = Colors.grey;

//   final Color selectedColor = Colors.white;

//   /// dot size
//   final double size = 8.0;

//   /// distnce between
//   final double spacing = 4.0;

//   /// dot indicator widget
//   Widget _buildIndicator(
//       int index, int pageCount, double dotSize, double spacing) {
//     // current dot is selected or not
//     // bool isCurrentPageSelected = index ==
//     //     (controller.page != null ? controller.page.round() % pageCount : 0);

//     return new Container(
//       height: size,
//       width: size + (2 * spacing),
//       child: new Center(
//         child: new Material(
//           color: normalColor,
//           type: MaterialType.circle,
//           child: new Container(
//             width: dotSize,
//             height: dotSize,
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return new Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: new List<Widget>.generate(itemCount, (int index) {
//         return _buildIndicator(index, itemCount, size, spacing);
//       }),
//     );
//   }
// }
