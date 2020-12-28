import 'dart:io';

import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/appbar/appbar.dart';
import 'package:video_player/video_player.dart';

class Preview extends StatefulWidget {
  final String outputVideoPath;

  Preview(this.outputVideoPath);

  @override
  _PreviewState createState() => _PreviewState();
}

class _PreviewState extends State<Preview> {
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.file(File(widget.outputVideoPath))
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppbarWidget(title: Text("Preview"),),
      body: SafeArea(
        child: Center(
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: _controller.value.initialized
                ? Container(
                    child: VideoPlayer(_controller),
                  )
                : Container(
                    child: Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
