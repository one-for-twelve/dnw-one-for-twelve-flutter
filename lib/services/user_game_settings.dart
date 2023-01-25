// ignore_for_file: constant_identifier_names

import 'package:shared_preferences/shared_preferences.dart';

import '../models/question_selection_strategies.dart';
import 'languages.dart';

class UserGameSettings {
  static const _GAME_LANGUAGE_CODE = "GAME_LANGUAGECODE";
  static const _GAME_SHOW_UNREVISED_QUESTIONS = "GAME_SHOW_UNREVISED_QUESTIONS";
  static const _GAME_SHOW_SELECTION_SCREEN = "GAME_SHOW_SELECTION_SCREEN";
  static const _GAME_QUESTION_SELECTION_STRATEGY =
      "GAME_QUESTION_SELECTION_STRATEGY";

  String? _languageCode;
  String get languageCode => _languageCode ?? Languages.dutch;
  Future<void> setLanguageCode(String value) async {
    _languageCode = value;
    final sharedPrefs = await SharedPreferences.getInstance();
    await sharedPrefs.setString(_GAME_LANGUAGE_CODE, value);
    await _updateQuestionSelectionStrategyIfInvalid();
  }

  bool? _showUnrevisedQuestions;
  bool get showUnrevisedQuestions => _showUnrevisedQuestions ?? false;
  Future<void> setShowUnrevisedQuestions(bool value) async {
    _showUnrevisedQuestions = value;
    final sharedPrefs = await SharedPreferences.getInstance();
    await sharedPrefs.setBool(_GAME_SHOW_UNREVISED_QUESTIONS, value);
  }

  bool? _showGameSelectionScreen;
  bool get showGameSelectionScreen => _showGameSelectionScreen ?? true;
  Future<void> setShowGameSelectionScreen(bool value) async {
    _showGameSelectionScreen = value;
    final sharedPrefs = await SharedPreferences.getInstance();
    await sharedPrefs.setBool(_GAME_SHOW_SELECTION_SCREEN, value);
  }

  QuestionSelectionStrategies? _questionSelectionStrategy;
  QuestionSelectionStrategies get questionSelectionStrategy =>
      _questionSelectionStrategy ?? QuestionSelectionStrategies.RandomOnlyEasy;
  Future<void> setQuestionSelectionStrategy(
      QuestionSelectionStrategies value) async {
    _questionSelectionStrategy = value;
    final sharedPrefs = await SharedPreferences.getInstance();
    await sharedPrefs.setInt(_GAME_QUESTION_SELECTION_STRATEGY, value.index);
  }

  Future<void> _updateQuestionSelectionStrategyIfInvalid() async {
    final availableStrategies =
        Languages.getAvailableQuestionSelectionStrategies(languageCode);
    if (!availableStrategies
        .any((strategy) => strategy == questionSelectionStrategy)) {
      await setQuestionSelectionStrategy(availableStrategies.first);
    }
  }

  UserGameSettings(this._languageCode, this._showUnrevisedQuestions,
      this._showGameSelectionScreen, this._questionSelectionStrategy);

  static Future<UserGameSettings> createFromSharedPreferences() async {
    final sharedPrefs = await SharedPreferences.getInstance();

    return UserGameSettings(
      sharedPrefs.getString(_GAME_LANGUAGE_CODE),
      sharedPrefs.getBool(_GAME_SHOW_UNREVISED_QUESTIONS),
      sharedPrefs.getBool(_GAME_SHOW_SELECTION_SCREEN),
      sharedPrefs.getInt(_GAME_QUESTION_SELECTION_STRATEGY) == null
          ? QuestionSelectionStrategies.RandomOnlyEasy
          : QuestionSelectionStrategies
              .values[sharedPrefs.getInt(_GAME_QUESTION_SELECTION_STRATEGY)!],
    );
  }
}
