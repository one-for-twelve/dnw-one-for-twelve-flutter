import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../app_localizations.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  HelpScreenState createState() => HelpScreenState();
}

class HelpScreenState extends State<HelpScreen> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset('assets/guess_word.mp4')
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
    final text = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(text.translate('help')),
        centerTitle: true,
      ),
      body: _controller!.value.isInitialized
          ? SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: VideoPlayer(_controller!),
            )
          : Center(
              child: Text(text.translate('help')),
            ),
    );
  }
}
