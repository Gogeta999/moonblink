import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/appbar/appbar.dart';
import 'package:moonblink/base_widget/container/shadedContainer.dart';
import 'package:moonblink/base_widget/imageview.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/models/partner.dart';

class PartnerGameProfilePage extends StatefulWidget {
  final List<PartnerGameProfile> gameprofile;
  PartnerGameProfilePage({this.gameprofile});
  @override
  _PartnerGameProfileState createState() => _PartnerGameProfileState();
}

class _PartnerGameProfileState extends State<PartnerGameProfilePage> {
  PartnerGameProfile profile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(
        title: Text(G.of(context).profilegame),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          if (widget.gameprofile.isEmpty)
            Center(
              child: Text(G.of(context).nogameprofile),
            ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: widget.gameprofile.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    ShadedContainer(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              InkResponse(
                                focusColor: Colors.red,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ImageView(widget
                                          .gameprofile[index].skillCoverImage),
                                    ),
                                  );
                                },
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.width / 4.5,
                                  width: MediaQuery.of(context).size.width / 3,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).accentColor,
                                    border: Border.all(color: Colors.black),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      widget.gameprofile[index].skillCoverImage,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text.rich(
                                    TextSpan(
                                      style: TextStyle(fontSize: 16),
                                      children: [
                                        TextSpan(
                                          text: "${G.of(context).rank} : ",
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        TextSpan(
                                          text: widget.gameprofile[index].level,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text.rich(
                                    TextSpan(
                                      style: TextStyle(fontSize: 16),
                                      children: [
                                        TextSpan(
                                          text: "${G.of(context).playerid} : ",
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        TextSpan(
                                            text: widget
                                                .gameprofile[index].playerId),
                                      ],
                                    ),
                                  ),
                                  // Text("Rank: ${widget.gameprofile[index].level}"),
                                ],
                              )
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            widget.gameprofile[index].gameName,
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    )
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
