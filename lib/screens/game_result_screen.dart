import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_localizations.dart';
import '../models/game.dart';
import './game_screen.dart';

class GameResultScreen extends StatelessWidget {
  const GameResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = AppLocalizations.of(context);
    final game = Provider.of<Game>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        title: Text(game.wordWasGuessedCorrectly
            ? text.translate('gameresultscreen_title_good')
            : text.translate('gameresultscreen_title_bad')),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              if (!game.wordWasGuessedCorrectly)
                Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(text.translate('sorry_the_word_was'),
                          style: const TextStyle(fontSize: 28)),
                    ),
                    Text(
                      '${game.word?.toUpperCase()}',
                      style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 36,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              Flexible(
                child: Image(
                  image: AssetImage(game.wordWasGuessedCorrectly
                      ? 'assets/happy_balloon_emoji.png'
                      : 'assets/sad_pixar.png'),
                ),
              ),
              ElevatedButton(
                  child: Text(text.translate('show_answers')),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute<GameScreen>(
                        builder: (_) {
                          return ChangeNotifierProvider<Game>.value(
                            // without creating a copy of the game the game._listeners still references old Consumers
                            // causing the _GameScreenState Consumer<Game>(builder: (_, game, __) method to execute twice
                            // for videos that means you will hear the audio playing simultaniously
                            value: game.copy(),
                            child: const GameScreen(),
                          );
                        },
                      ),
                    );
                  }),
              ElevatedButton(
                child: Text(text.translate('play_again')),
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed('/home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
