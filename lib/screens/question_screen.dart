import 'package:flutter/material.dart';

import '../app_localizations.dart';
import '../models/game.dart';

import '../widgets/size_config.dart';
import '../widgets/question_answer.dart';
import '../widgets/current_question.dart';

class QuestionScreen extends StatelessWidget {
  final PositionedQuestion _positionedQuestion;
  GameQuestion get _gameQuestion => _positionedQuestion.question;

  const QuestionScreen(this._positionedQuestion, {super.key});

  void _answerUpdated(String answer, BuildContext context) {
    _positionedQuestion.updateGivenAnswer(answer);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final sizeConfig = SizeConfig(context);

    final text = AppLocalizations.of(context);

    var appBar = AppBar(
      title: Text("${text.translate('question')} ${_gameQuestion.number}"),
      centerTitle: true,
    );

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: appBar,
      body: SingleChildScrollView(
        child: SafeArea(
          child: SizedBox(
            width: sizeConfig.safeBlockHorizontal * 100,
            height: (sizeConfig.safeBlockVertical * 100) -
                appBar.preferredSize.height,
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    child: CurrentQuestion(_gameQuestion.question),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: QuestionAnswer(
                      _gameQuestion,
                      (answer) => _answerUpdated(answer, context),
                      text.translate('change_answer')),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
