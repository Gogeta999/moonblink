import 'package:flutter/material.dart';
import 'package:moonblink/models/story.dart';
import 'package:story_view/story_view.dart';

class StoriesPage extends StatefulWidget {
  StoriesPage(this.stories);
  final Story stories;
  @override
  _StoriesPageState createState() => _StoriesPageState();
}

class _StoriesPageState extends State<StoriesPage>{
  final storyController = StoryController();
  
  @override
  void dispose() {
    storyController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    if(widget.stories.mediaType == 1)
      return Scaffold(
        body: StoryView(
          storyItems: [
            StoryItem.pageImage(url: widget.stories.mediaUrl, 
            controller: storyController)
          ], 
          onStoryShow: (s) {
          print("Showing a story");
        },
        onComplete: () {
          print("Completed a cycle");
        },
        progressPosition: ProgressPosition.top,
        repeat: false,
        controller: storyController,),
      );
    return Scaffold(
    body: StoryView(
        storyItems: [
          StoryItem.pageVideo(
          widget.stories.mediaUrl,
            controller: storyController)
          // StoryItem.text(
          //   title: "I guess you'd love to see more of our food. That's great.",
          //   backgroundColor: Colors.blue,
          // ),
          // StoryItem.text(
          //   title: "Nice!\n\nTap to continue.",
          //   backgroundColor: Colors.red,
          // ),
          // StoryItem.pageImage(
          //   url:
          //       "https://image.ibb.co/cU4WGx/Omotuo-Groundnut-Soup-braperucci-com-1.jpg",
          //   caption: "Still sampling",
          //   controller: storyController,
          // ),
          // StoryItem.pageImage(
          //     url: "https://media.giphy.com/media/5GoVLqeAOo6PK/giphy.gif",
          //     caption: "Working with gifs",
          //     controller: storyController),
          // StoryItem.pageImage(
          //   url: "https://media.giphy.com/media/XcA8krYsrEAYXKf4UQ/giphy.gif",
          //   caption: "Hello, from the other side",
          //   controller: storyController,
          // ),
          // StoryItem.pageImage(
          //   url: "https://media.giphy.com/media/XcA8krYsrEAYXKf4UQ/giphy.gif",
          //   caption: "Hello, from the other side2",
          //   controller: storyController,
          // ),
        ],
        onStoryShow: (s) {
          print("Showing a story");
        },
        onComplete: () {
          print("Completed a cycle");
        },
        progressPosition: ProgressPosition.top,
        repeat: false,
        controller: storyController,
      ),
    );
  }
}