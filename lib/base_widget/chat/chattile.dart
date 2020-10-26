import 'package:flutter/material.dart';

class ChatTile extends StatelessWidget {
  final Widget image;
  final Widget name;
  final Widget lastmsg;
  final Widget trailing;
  final Function onTap;
  ChatTile({this.name, this.lastmsg, this.trailing, this.image, this.onTap});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 86,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
              child: Container(
                height: 70,
                padding:
                    EdgeInsets.only(top: 3, bottom: 3, left: 70, right: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.white
                      : null,
                  border: Border.all(
                    width: 1,
                    color: theme.brightness == Brightness.dark
                        ? Colors.grey
                        : Colors.black,
                  ),
                  borderRadius: BorderRadius.circular(110),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          name,
                          lastmsg,
                        ],
                      ),
                    ),
                    trailing
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                radius: 42,
                backgroundColor: theme.brightness == Brightness.dark
                    ? Colors.grey
                    : Colors.black,
                child: image,
              ),
            )
          ],
        ),
      ),
    );
  }
}
