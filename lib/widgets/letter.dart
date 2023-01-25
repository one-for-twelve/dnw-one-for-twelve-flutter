import 'package:flutter/material.dart';

import '../models/question_levels.dart';
import '../models/game.dart';

class Letter extends StatelessWidget {
  final GameQuestion gameQuestion;
  final bool isBeingAnswered;

  const Letter(this.gameQuestion, this.isBeingAnswered, {super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).textTheme.headline6!.color;
    final opaqueColor =
        Color.fromRGBO(color!.red, color.green, color.blue, 0.12);

    return Container(
      width: 25,
      height: 25,
      padding: const EdgeInsets.only(top: 5),
      decoration: !isBeingAnswered
          ? null
          : BoxDecoration(
              border: Border(
                top: BorderSide(
                  width: 1,
                  color: _getDifficultyColor(),
                ),
              ),
            ),
      child: Text(
        gameQuestion.number.toString(),
        style: TextStyle(
            color: isBeingAnswered ? _getDifficultyColor() : opaqueColor,
            fontSize: 20),
        textAlign: TextAlign.center,
      ),
    );
  }

  Color _getDifficultyColor() {
    if (gameQuestion.question.level == QuestionLevels.Normal) {
      return Colors.blue;
    }
    if (gameQuestion.question.level == QuestionLevels.Hard) return Colors.red;

    return Colors.green;
  }
}
