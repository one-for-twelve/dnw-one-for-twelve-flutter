import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_localizations.dart';
import '../services/ads.dart';

import '../models/game.dart';

import '../widgets/size_config.dart';
import '../widgets/word.dart';
import '../widgets/current_question.dart';
import '../widgets/question_answer.dart';

import './guess_word_screen.dart';
import './game_result_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  GameScreenState createState() {
    return GameScreenState();
  }
}

class GameScreenState extends State<GameScreen> {
  bool _adPlaying = false;

  Future<void> questionAnswered(Game game, String answer) async {
    if (game.currentQuestion.number == 6) {
      setState(() {
        _adPlaying = true;
      });

      Ads.showRewardedInterstitialVideoAd(() {
        _adPlaying = false;
        _continueWithNextQuestion(game, answer);
      });
    } else {
      _continueWithNextQuestion(game, answer);
    }
  }

  void _continueWithNextQuestion(Game game, String answer) {
    if (!game.nextQuestion(answer)) {
      if (game.wordWasGuessed) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute<GameResultScreen>(
            builder: (_) {
              return ChangeNotifierProvider<Game>.value(
                value: game,
                child: const GameResultScreen(),
              );
            },
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute<GuessWordScreen>(
            builder: (_) {
              return ChangeNotifierProvider<Game>.value(
                value: game,
                child: const GuessWordScreen(),
              );
            },
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = AppLocalizations.of(context);

    final sizeConfig = SizeConfig(context);

    return Consumer<Game>(builder: (_, game, __) {
      final appBar = AppBar(
        automaticallyImplyLeading: false,
        leading: Container(),
        title: Text(game.wordWasGuessed
            ? text.translate('the_correct_answers')
            : text.translate('there_we_go')),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () => Navigator.of(context).pushReplacementNamed('/home'),
            child: Tooltip(
              message: text.translate('cancel_game'),
              child: const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Icon(
                  Icons.exit_to_app,
                  size: 30,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      );

      return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: appBar,
        body: SingleChildScrollView(
          child: SafeArea(
            child: SizedBox(
              width: sizeConfig.safeBlockHorizontal * 100,
              height: (sizeConfig.safeBlockVertical * 100) -
                  appBar.preferredSize.height,
              child: Column(
                children: <Widget>[
                  Word(game),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20.0),
                      child: _adPlaying
                          ? Container()
                          : CurrentQuestion(
                              game.currentQuestion.question,
                              key: ValueKey(
                                game.currentQuestion.number.toString(),
                              ),
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: QuestionAnswer(
                        game.currentQuestion,
                        (answer) async => await questionAnswered(game, answer),
                        text.translate('next_question'),
                        answer: game.wordWasGuessed
                            ? game.currentQuestion.question.answer
                            : null,
                        key: ValueKey(game.currentQuestion.number.toString())),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
