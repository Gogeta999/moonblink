import 'package:flutter/material.dart';
// import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/models/story.dart';
import 'package:moonblink/ui/pages/main/stories/user_stories.dart';

class StoryItemWidget extends StatelessWidget {
  final Story stories;
  final int index;
  StoryItemWidget(this.stories, {this.index}) : super(key: ValueKey(stories));

  @override
  Widget build(BuildContext context) {
    print(stories);
    // if(stories.body == "null"){
    // return Padding(
    //   padding: const EdgeInsets.only(left: 15),
    //   child: InkWell(
    //     onTap: (){
    //       Navigator.push(context, MaterialPageRoute(builder: (context) => StoriesPage(stories)));
    //     },
    //     child: Align(
    //         child: CircleAvatar(
    //         radius: 33,
    //         backgroundColor: Colors.red,
    //         backgroundImage: NetworkImage(stories.mediaUrl),
    //         ),
    //     )
    //     ),
    //   );
    // }
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        StoriesPage(stories.storys, stories.profile)));
          },
          child: Align(
            child: CircleAvatar(
              radius: 33,
              backgroundColor: Colors.grey[300],
              backgroundImage: NetworkImage(stories.profile),
            ),
          )),
    );
  }
}
