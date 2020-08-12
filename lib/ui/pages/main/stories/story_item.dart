import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:moonblink/models/story.dart';
import 'package:moonblink/ui/pages/main/stories/user_stories.dart';

class StoryItemWidget extends StatelessWidget {
  final List<Story> stories;
  final int index;
  StoryItemWidget(this.stories, {this.index}) : super(key: ValueKey(stories));

  @override
  Widget build(BuildContext context) {
    Story story = stories[index];
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        StoriesPage(story: stories, index: index)));
          },
          child: Align(
            child: CachedNetworkImage(
              imageUrl: stories.profile,
              imageBuilder: (context, imageProvider) => CircleAvatar(
                radius: 33,
                backgroundColor: Colors.grey[300],
                backgroundImage: imageProvider,
              ),
            ),
          )),
    );
  }
}
