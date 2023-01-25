import 'package:flutter/material.dart';
import '../models/game.dart';

class QuestionImage extends StatelessWidget {
  final Question _question;

  const QuestionImage(this._question, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(_question.text),
        const SizedBox(height: 20),
        Flexible(
          child: _question.imageUrl!.startsWith('http')
              ? Image.network(_question.imageUrl!)
              : Image(
                  image: AssetImage(_question.imageUrl!),
                ),
        ),
      ],
    );
  }
}
