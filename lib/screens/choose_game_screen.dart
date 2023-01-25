import 'package:flutter/material.dart';
import 'package:one_for_twelve/services/game_service.dart';
import 'package:provider/provider.dart';

import '../models/game.dart';
import '../models/game_user.dart';
import '../models/question_selection_strategies.dart';

import '../app_localizations.dart';

import '../services/languages.dart';
import '../services/auth.dart';

import './game_screen.dart';

class ChooseGameScreen extends StatefulWidget {
  const ChooseGameScreen({super.key});

  @override
  ChooseGameScreenState createState() => ChooseGameScreenState();
}

class ChooseGameScreenState extends State<ChooseGameScreen> {
  GameUser? _user;
  String? _languageCode;
  QuestionSelectionStrategies? _questionSelectionStrategy;
  bool _showGameSelectionScreen = false;

  @override
  void initState() {
    super.initState();

    Auth.instance.getCurrentUser().then((user) {
      setState(() {
        _user = user;
        _languageCode = _user!.gameSettings.languageCode;
        _questionSelectionStrategy =
            _user!.gameSettings.questionSelectionStrategy;
      });
    });
  }

  Future<void> _updateUserGameSettings() async {
    await _user!.gameSettings.setLanguageCode(_languageCode!);
    await _user!.gameSettings
        .setQuestionSelectionStrategy(_questionSelectionStrategy!);
    await _user!.gameSettings
        .setShowGameSelectionScreen(_showGameSelectionScreen);
  }

  Future<Game?> _createGame() async {
    return GameService.create(_languageCode!, _questionSelectionStrategy!);
  }

  Future<void> _newGame(BuildContext context) async {
    final game = await _createGame();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute<GameScreen>(
        builder: (_) {
          return ChangeNotifierProvider<Game>.value(
            value: game!,
            child: GameScreen(),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
          title: Text(text.translate('choosegamescreen_title')),
          centerTitle: true),
      body: SafeArea(
        child: Center(
          child: _user == null
              ? const CircularProgressIndicator()
              : Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      ListTile(
                        leading:
                            Text(text.translate('show_this_screen_in_future')),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Switch.adaptive(
                              value: _showGameSelectionScreen,
                              onChanged: (value) {
                                setState(() {
                                  _showGameSelectionScreen = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      ListTile(
                        leading: Text(text.translate('language')),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            DropdownButton(
                                value: _languageCode,
                                items: Languages.getSupportedLanguageCodes()
                                    .map((languageCode) {
                                  return DropdownMenuItem(
                                      value: languageCode,
                                      child: Text(text.translate(
                                          'language_$languageCode')));
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _languageCode = value;
                                  });
                                })
                          ],
                        ),
                      ),
                      ListTile(
                        leading: Text(text.translate('game_level')),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            DropdownButton(
                                value: _questionSelectionStrategy,
                                items: Languages
                                        .getAvailableQuestionSelectionStrategies(
                                            _languageCode!)
                                    .map((strategy) {
                                  return DropdownMenuItem(
                                      value: strategy,
                                      child: Text(text.translate(
                                          'game_level_${strategy.index}')));
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _questionSelectionStrategy = value;
                                  });
                                })
                          ],
                        ),
                      ),
                      ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              child: Text(text.translate('start_game_text')),
                              onPressed: () async {
                                await _updateUserGameSettings();
                                await _newGame(context);
                              },
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
