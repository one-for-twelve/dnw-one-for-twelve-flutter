import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class QuestionLocalVideo extends StatefulWidget {
  final String _text;
  final String _assetName;

  const QuestionLocalVideo(this._text, this._assetName, {super.key});

  @override
  QuestionLocalVideoState createState() => QuestionLocalVideoState();
}

class QuestionLocalVideoState extends State<QuestionLocalVideo> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset(widget._assetName)
      ..initialize().then((_) {
        _controller!.play();
        setState(() {});
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller!.pause();
    _controller!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(widget._text),
      const SizedBox(height: 20),
      Flexible(
        child: _controller!.value.isInitialized
            ? AspectRatio(
                aspectRatio: 1,
                child: VideoPlayer(_controller!),
              )
            : Container(),
      )
    ]);
  }
}
