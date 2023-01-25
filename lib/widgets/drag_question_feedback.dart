import 'package:flutter/material.dart';

import '../models/game.dart';

class DragQuestionFeedback extends StatefulWidget {
  final GameQuestion _question;
  final FeedbackController _controller;
  final double _width;
  final double _height;

  const DragQuestionFeedback(
      this._question, this._controller, this._width, this._height,
      {super.key});

  @override
  DragQuestionFeedbackState createState() => DragQuestionFeedbackState();
}

class DragQuestionFeedbackState extends State<DragQuestionFeedback> {
  bool? _allowDrop;
  bool _showLetterInWord = false;
  static const double _scaleFactor = 1.15;

  @override
  void initState() {
    super.initState();

    _allowDrop = !widget._question.guessed && widget._question.isAnswered;

    widget._controller.feedbackNeedsUpdateCallback =
        feedbackNeedsUpdateCallbackHandler;
  }

  @override
  void dispose() {
    widget._controller.feedbackNeedsUpdateCallback = null;
    super.dispose();
  }

  void feedbackNeedsUpdateCallbackHandler(GameQuestion dragged,
      GameQuestion? dropped, bool allowDrop, bool showLetterInWord) {
    setState(() {
      _allowDrop = allowDrop;
      _showLetterInWord = showLetterInWord;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _allowDrop!
        ? Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                width: widget._width * _scaleFactor,
                height: widget._height * _scaleFactor,
                child: Card(
                  color: Colors.blue,
                  child: Center(
                      child: Text(widget._question.firstLetterGivenAnswer,
                          style: const TextStyle(fontWeight: FontWeight.bold))),
                ),
              ),
              if (_showLetterInWord)
                Positioned(
                  right: -5,
                  top: -5,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [Icon(Icons.check_circle)],
                  ),
                )
            ],
          )
        : SizedBox(
            width: widget._width * _scaleFactor,
            height: widget._height * _scaleFactor,
            child: const FittedBox(
              fit: BoxFit.fill,
              child: Icon(Icons.not_interested, color: Colors.red),
            ),
          );
  }
}

class FeedbackController {
  Function(GameQuestion dragged, GameQuestion? dropped, bool allowDrop,
      bool showLetterInWord)? feedbackNeedsUpdateCallback;

  bool updateFeedback(
      GameQuestion dragged, GameQuestion? dropped, bool showLetterInWord) {
    bool allowDrop = true;

    if (dropped == null) {
      allowDrop = !dragged.guessed && dragged.isAnswered;
    } else {
      allowDrop = !dropped.guessed && !dragged.guessed && dragged.isAnswered;
    }

    if (feedbackNeedsUpdateCallback != null) {
      feedbackNeedsUpdateCallback!(
          dragged, dropped, allowDrop, showLetterInWord);
    }

    return allowDrop;
  }
}
