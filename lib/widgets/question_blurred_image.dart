import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/game.dart';

class QuestionBlurredImage extends StatelessWidget {
  final Question _question;

  const QuestionBlurredImage(this._question, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(_question.text),
        const SizedBox(height: 20),
        Flexible(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image(
                image: AssetImage(_question.imageUrl!),
              ),
              _UnblurringImage(),
            ],
          ),
        ),
      ],
    );
  }
}

class _UnblurringImage extends StatefulWidget {
  @override
  _UnblurringImageState createState() => _UnblurringImageState();
}

class _UnblurringImageState extends State<_UnblurringImage> {
  Timer? _timer;
  double _sigmaX = 10;
  double _sigmaY = 10;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_sigmaX <= 0 || _sigmaY <= 0) {
        _timer?.cancel();
      }

      if (!mounted) return;

      setState(() {
        _sigmaX = _sigmaX - 0.5;
        _sigmaY = _sigmaY - 0.5;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();

    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: _sigmaX, sigmaY: _sigmaY),
        child: Container(
          color: Colors.black.withOpacity(0.1),
        ),
      ),
    );
  }
}
