import 'package:flutter/material.dart';

import '../models/game.dart';

import './question_blurred_image.dart';
import './question_remote_vimeo_video.dart';
import './question_local_video.dart';
import './question_image.dart';
import './question_remote_youtube_video.dart';
import './question_text_only.dart';

class CurrentQuestion extends StatelessWidget {
  final Question question;

  const CurrentQuestion(this.question, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (question.imageUrl != null) {
      return question.blur
          ? QuestionBlurredImage(question)
          : QuestionImage(question);
    } else if (question.videoUrl != null) {
      return QuestionLocalVideo(question.text, question.videoUrl!);
    } else if (question.remoteVideo != null) {
      return question.remoteVideo!.source == RemoteVideoSource.Youtube
          ? QuestionRemoteYoutubeVideo(question.text, question.remoteVideo!)
          : QuestionRemoteVimeoVideo(question.text, question.remoteVideo!);
    } else {
      return QuestionTextOnly(question);
    }
  }
}
