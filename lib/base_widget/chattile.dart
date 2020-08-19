import 'package:flutter/material.dart';

class ChatTile extends StatelessWidget {
  final ImageProvider image;
  final String username;
  final String lastmsg;
  final String time;
  ChatTile({this.username, this.lastmsg, this.time, this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              height: 65,
              padding: EdgeInsets.only(top: 8, bottom: 8, left: 80, right: 20),
              decoration: BoxDecoration(
                border: Border.all(width: 2, color: Colors.white),
                borderRadius: BorderRadius.circular(110),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        maxLines: 1,
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        lastmsg,
                        maxLines: 1,
                      )
                    ],
                  ),
                  Text(time)
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: CircleAvatar(
              radius: 42,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 40,
                onBackgroundImageError: (exception, stackTrace) =>
                    print(exception + stackTrace),
                backgroundImage: image,
              ),
            ),
          )
        ],
      ),
    );
  }
}
