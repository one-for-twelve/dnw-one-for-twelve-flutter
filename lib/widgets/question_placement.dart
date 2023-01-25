import 'package:flutter/material.dart';

import '../models/game.dart';
import '../screens/question_screen.dart';

class QuestionPlacement extends StatelessWidget {
  final PositionedQuestion _positionedQuestion;
  GameQuestion get _question => _positionedQuestion.question;

  const QuestionPlacement(this._positionedQuestion, {super.key});

  @override
  Widget build(BuildContext context) {
    const color = Colors.blue;
    final opaqueColor =
        Color.fromRGBO(color.red, color.green, color.blue, 0.24);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute<QuestionScreen>(
            builder: (_) {
              return QuestionScreen(_positionedQuestion);
            },
          ),
        );
      },
      child: Stack(
        children: [
          Card(
            margin: const EdgeInsets.all(2),
            color: _positionedQuestion.question.guessed
                ? Colors.blue
                : opaqueColor,
            child: Center(
              child: Text(
                _question.firstLetterGivenAnswer,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
          ),
          if (_question.guessed)
            Positioned(
              right: 8,
              bottom: 8,
              child: Text(
                _question.wordPosition.toString(),
                style: const TextStyle(fontSize: 10),
              ),
            ),
        ],
      ),
    );
  }
}
