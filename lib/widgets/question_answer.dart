import 'package:flutter/material.dart';

import '../app_localizations.dart';
import '../models/game.dart';

class QuestionAnswer extends StatefulWidget {
  final GameQuestion _question;
  final String _answerButtonText;
  final Function(String answer) _answered;
  final String? answer;

  const QuestionAnswer(this._question, this._answered, this._answerButtonText,
      {Key? key, this.answer})
      : super(key: key);

  @override
  QuestionAnswerState createState() => QuestionAnswerState();
}

class QuestionAnswerState extends State<QuestionAnswer> {
  TextEditingController? _answerTextController;

  @override
  void initState() {
    super.initState();
    _answerTextController = TextEditingController();
    _answerTextController!.text = widget.answer != null
        ? widget.answer!
        : widget._question.givenAnswer ?? '';
  }

  @override
  void dispose() {
    super.dispose();
    _answerTextController?.dispose();
  }

  void answer() {
    widget._answered(_answerTextController!.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final text = AppLocalizations.of(context);

    return Row(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: TextField(
                readOnly: widget.answer != null ? true : false,
                decoration: InputDecoration(
                    labelText: widget.answer == null
                        ? text.translate('your_answer')
                        : text.translate('correct_answer'),
                    labelStyle: const TextStyle(fontSize: 20)),
                controller: _answerTextController,
                keyboardType: TextInputType.text,
                autocorrect: false,
                enableSuggestions: false),
          ),
        ),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 0)),
            onPressed: answer,
            child: Text(
              widget._answerButtonText,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}
