import 'dart:async' show Future, Timer;

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yte;

import '../app_localizations.dart';
import '../models/game.dart';

class QuestionRemoteYoutubeVideo extends StatefulWidget {
  final String _text;
  final RemoteVideo _video;

  const QuestionRemoteYoutubeVideo(this._text, this._video, {super.key});

  @override
  QuestionRemoteYoutubeVideoState createState() =>
      QuestionRemoteYoutubeVideoState();
}

class QuestionRemoteYoutubeVideoState
    extends State<QuestionRemoteYoutubeVideo> {
  VideoPlayerController? _controller;
  bool _playing = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    var yt = yte.YoutubeExplode();
    yt.videos.streamsClient.getManifest(widget._video.videoId).then((video) {
      var firstMuxed = video.muxed.first;
      var url = firstMuxed.url.toString().replaceFirst('c=WEB', '');

      _controller = VideoPlayerController.network(url)
        ..initialize().then((_) {
          _startVideo();
        });
    });
  }

  Future<void> _startVideo() async {
    if (!mounted) return;

    await _controller!.seekTo(Duration(seconds: widget._video.startAt));
    await _controller!.play();

    setState(() {
      _playing = true;
    });

    if (_timer != null) {
      _timer!.cancel();
    }

    _timer =
        Timer(Duration(seconds: widget._video.endAt - widget._video.startAt),
            () async {
      if (!mounted) return;

      setState(() {
        _playing = false;
      });

      await _controller!.pause();
      await _controller!.seekTo(Duration(seconds: widget._video.startAt));
    });
  }

  @override
  void dispose() {
    super.dispose();

    if (_controller != null) {
      _controller!.pause();
      _controller!.dispose();
    }

    if (_timer != null) {
      _timer!.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = AppLocalizations.of(context);

    return Column(
      children: [
        Text(widget._text),
        const SizedBox(height: 20),
        Flexible(
          child: _controller?.value != null && _controller!.value.isInitialized
              ? _playing
                  ? AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: VideoPlayer(_controller!),
                    )
                  : ElevatedButton(
                      onPressed: _startVideo,
                      child: Text(text.translate('play_video_again')))
              : const Center(
                  child: CircularProgressIndicator(),
                ),
        )
      ],
    );
  }
}
