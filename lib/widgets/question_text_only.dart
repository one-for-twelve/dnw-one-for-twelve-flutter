import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/game.dart';

class QuestionTextOnly extends StatelessWidget {
  final Question _question;

  const QuestionTextOnly(this._question, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          _question.text,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Flexible(
          child: Image(
            image: AssetImage(
              'assets/${describeEnum(_question.category).toLowerCase()}.png',
            ),
          ),
        ),
      ],
    );
  }
}
