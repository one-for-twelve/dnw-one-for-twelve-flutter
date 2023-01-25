import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/game.dart';

class GuessedWordLetter extends StatelessWidget {
  const GuessedWordLetter({super.key});

  @override
  Widget build(BuildContext context) {
    const color = Colors.blue;
    final opaqueColor = Color.fromRGBO(color.red, color.green, color.blue, 0.2);

    return Consumer<GameQuestion>(
      builder: (_, question, __) => Stack(
        children: [
          Card(
            margin: const EdgeInsets.all(2),
            color: question.guessed ? Colors.blue : opaqueColor,
            child: Center(
              child: Text(
                question.guessed
                    ? question.firstLetterGivenAnswer
                    : question.wordPosition.toString(),
                style: question.guessed
                    ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)
                    : const TextStyle(
                        fontWeight: FontWeight.normal, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
