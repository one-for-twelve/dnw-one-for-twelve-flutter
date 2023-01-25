import 'package:flutter/material.dart';

import './letter.dart';
import '../models/game.dart';

class Word extends StatelessWidget {
  final Game game;

  const Word(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          ...game.questionsByNumber.map(
            (q) => Letter(q, game.currentQuestion.number == q.number),
          ),
        ],
      ),
    );
  }
}
