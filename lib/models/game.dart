import 'package:flutter/material.dart';

import './question_categories.dart';
import './question_levels.dart';

class Game extends ChangeNotifier {
  int _currentQuestionIndex = 0;
  GameQuestion get currentQuestion => questionsByNumber[_currentQuestionIndex];

  bool _allQuestionsAnswered = false;
  bool get allQuestionsAnswered => _allQuestionsAnswered;

  final String? word;
  final List<GameQuestion> _questions;

  bool _wordGuessed = false;
  bool get wordWasGuessed => _wordGuessed;

  bool _wordWasGuessedCorrectly = false;
  bool get wordWasGuessedCorrectly => _wordWasGuessedCorrectly;

  List<GameQuestion> get questionsByWordPosition {
    return [..._questions]
      ..sort((a, b) => a.wordPosition!.compareTo(b.wordPosition!));
  }

  List<PositionedQuestion>? _positionedQuestions;
  List<PositionedQuestion> get positionedQuestions {
    _positionedQuestions ??= questionsByNumber
        .map((q) => PositionedQuestion(q.number, this))
        .toList();

    return _positionedQuestions!;
  }

  List<GameQuestion> get questionsByNumber {
    return [..._questions]..sort((a, b) => a.number!.compareTo(b.number!));
  }

  Game(this.word, this._questions);

  static fromMap(Map<dynamic, dynamic> data) {
    final word = data['word'];
    final questionsData = data['questions'];
    final questions = (questionsData as List)
        .asMap()
        .map(
          (index, q) => MapEntry(
            index,
            GameQuestion.mapFrom(q),
          ),
        )
        .values
        .toList();
    final game = Game(word, questions);

    return game;
  }

  Game.finished(this.word, this._questions, bool wordQuessedCorrectly) {
    _wordGuessed = true;
    _wordWasGuessedCorrectly = wordQuessedCorrectly;
    _allQuestionsAnswered = true;
  }

  Game copy() {
    return Game.finished(word, _questions, _wordWasGuessedCorrectly);
  }

  void guessWord(String? word) {
    _wordGuessed = true;
    _wordWasGuessedCorrectly =
        (word?.toLowerCase() == this.word?.toLowerCase());
  }

  bool nextQuestion(String answer) {
    currentQuestion._givenAnswer = answer;

    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
      return true;
    } else {
      _allQuestionsAnswered = true;
      return false;
    }
  }

  void guessQuestionNumber(int questionNumber) {
    final questionToGuess = positionedQuestions
        .firstWhere((q) => q.questionNumber == questionNumber);
    final wordPosition = questionToGuess.question.wordPosition;
    final questionToSwap = positionedQuestions[wordPosition! - 1];
    final questionNumberToSwap = questionToSwap.questionNumber;

    questionToGuess.question.guess();

    questionToSwap.updateQuestionNumber(questionNumber);
    questionToSwap.commitUpdateQuestionNumber();

    questionToGuess.updateQuestionNumber(questionNumberToSwap!);
    questionToGuess.commitUpdateQuestionNumber();
  }
}

class PositionedQuestion extends ChangeNotifier {
  final Game _game;

  int? questionNumber;
  int? _prevQuestionNumber;
  bool get isDropTarget => _prevQuestionNumber != null;

  GameQuestion get question {
    return _game.questionsByNumber
        .firstWhere((q) => q.number == questionNumber);
  }

  PositionedQuestion(this.questionNumber, this._game);

  void updateGivenAnswer(String answer) {
    question.updateGivenAnswer(answer);
    notifyListeners();
  }

  void updateQuestionNumber(int questionNumber) {
    _prevQuestionNumber = this.questionNumber;
    this.questionNumber = questionNumber;
    notifyListeners();
  }

  void commitUpdateQuestionNumber() {
    _prevQuestionNumber = null;
  }

  void undoUpdateQuestionNumber() {
    if (_prevQuestionNumber != null) {
      questionNumber = _prevQuestionNumber;
      _prevQuestionNumber = null;
      notifyListeners();
    }
  }
}

class Question extends ChangeNotifier {
  final int id;
  final String text;
  final String answer;
  final QuestionCategories category;
  final QuestionLevels level;

  bool blur;

  String? imageUrl;
  String? videoUrl;
  RemoteVideo? remoteVideo;

  Question(this.id, this.text, this.answer, this.category, this.level,
      {this.imageUrl, this.videoUrl, this.remoteVideo, this.blur = false});

  static Question mapFrom(Map<dynamic, dynamic> from) {
    return Question(
        int.parse(from['id'].toString()),
        from['text'],
        from['answer'],
        QuestionCategories.values.byName(from['category']),
        QuestionLevels.values.byName(from['level']),
        imageUrl: from['imageUrl'],
        blur: from['blurImage'],
        remoteVideo: _convertRemoteVideo(from['video']));
  }

  static RemoteVideo? _convertRemoteVideo(dynamic videoData) {
    return videoData != null
        ? RemoteVideo(
            videoData['videoId'],
            videoData['startAt'],
            videoData['endAt'],
            RemoteVideoSource.values.byName(videoData['source']),
          )
        : null;
  }
}

class GameQuestion extends ChangeNotifier {
  final int? number;
  final int? wordPosition;
  final Question question;

  String? _givenAnswer;

  String? get givenAnswer => _givenAnswer;

  bool get isAnswered => _givenAnswer != null && _givenAnswer!.isNotEmpty;

  String get firstLetterGivenAnswer =>
      _givenAnswer == null || _givenAnswer!.isEmpty
          ? '?'
          : _givenAnswer![0].toUpperCase();

  void updateGivenAnswer(String answer) {
    _givenAnswer = answer;
    notifyListeners();
  }

  bool _guessed = false;
  bool get guessed => _guessed;

  guess() {
    _guessed = true;
    notifyListeners();
  }

  GameQuestion(this.question, this.number, this.wordPosition);

  static GameQuestion mapFrom(Map<dynamic, dynamic> from) {
    return GameQuestion(
        Question.mapFrom(from), from['number'], from['wordPosition']);
  }
}

class RemoteVideo {
  final String videoId;
  final int startAt;
  final int endAt;
  final RemoteVideoSource source;

  const RemoteVideo(this.videoId, this.startAt, this.endAt, this.source);
}

enum RemoteVideoSource { Youtube, Vimeo }
