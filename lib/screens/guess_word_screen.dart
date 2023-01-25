import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dotted_border/dotted_border.dart';

import '../app_localizations.dart';
import '../models/game.dart';

import './game_result_screen.dart';

import '../widgets/size_config.dart';
import '../widgets/guessed_word_letter.dart';
import '../widgets/question_placement.dart';
import '../widgets/drag_question_feedback.dart';

import './help_screen.dart';

class GuessWordScreen extends StatefulWidget {
  const GuessWordScreen({super.key});

  @override
  GuessWordSreenState createState() => GuessWordSreenState();
}

class GuessWordSreenState extends State<GuessWordScreen> {
  TextEditingController? _guessedWordTextController;
  bool _guessingLetter = false;
  FeedbackController? _feedbackController;

  @override
  void initState() {
    super.initState();
    _guessedWordTextController = TextEditingController();
    _feedbackController = FeedbackController();
  }

  @override
  void dispose() {
    super.dispose();
    _guessedWordTextController?.dispose();
  }

  void _guessWord(Game game, BuildContext context) {
    final guessedWord = _guessedWordTextController?.text.trim();
    game.guessWord(guessedWord);

    Navigator.push(
      context,
      MaterialPageRoute<GuessWordScreen>(
        builder: (_) {
          return ChangeNotifierProvider<Game>.value(
            value: game,
            child: const GameResultScreen(),
          );
        },
      ),
    );
  }

  bool _onWillAccept(PositionedQuestion positionedQuestion) {
    final question = positionedQuestion.question;

    if (!question.isAnswered || question.guessed) return false;

    setState(() {
      _guessingLetter = true;
    });

    _feedbackController!.updateFeedback(question, null, true);

    return true;
  }

  void _onLeave(_) {
    setState(() {
      _guessingLetter = false;
    });
  }

  void _onAccept(PositionedQuestion positionedQuestion, Game game) {
    final questionNumber = positionedQuestion.questionNumber;
    game.guessQuestionNumber(questionNumber!);

    setState(() {
      _guessingLetter = false;
    });
  }

  void _showHelpDialog(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
          builder: (BuildContext context) {
            return const HelpScreen();
          },
          fullscreenDialog: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sizeConfig = SizeConfig(context);

    final text = AppLocalizations.of(context);

    final appBar = AppBar(
      title: Text(text.translate('guess_the_word')),
      centerTitle: true,
      leading: Container(),
    );

    const containerPadding = 5;
    final tileWidth =
        ((sizeConfig.safeBlockHorizontal * 100) - (containerPadding * 2)) / 12;
    final containerHeight = tileWidth;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: appBar,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Consumer<Game>(builder: (_, game, __) {
            return SizedBox(
              width: sizeConfig.safeBlockHorizontal * 100,
              height: (sizeConfig.safeBlockVertical * 100) -
                  appBar.preferredSize.height,
              child: Column(
                children: [
                  DragTarget<PositionedQuestion>(
                    onWillAccept: (question) => _onWillAccept(question!),
                    onLeave: _onLeave,
                    onAccept: (question) => _onAccept(question, game),
                    builder: (context, incoming, rejected) {
                      return Container(
                        decoration: BoxDecoration(
                          //color: Colors.red,
                          color: Color.fromRGBO(
                              31, 140, 247, _guessingLetter ? 0.2 : 0.0),
                        ),
                        height: containerHeight,
                        child: GridView.count(
                          crossAxisCount: 12,
                          children: game.questionsByWordPosition
                              .map((question) =>
                                  ChangeNotifierProvider<GameQuestion>.value(
                                    value: question,
                                    child: const GuessedWordLetter(),
                                  ))
                              .toList(),
                        ),
                      );
                    },
                  ),
                  Expanded(
                    child: DragTarget<PositionedQuestion>(
                        onWillAccept: (question) => _onWillAccept(question!),
                        onLeave: _onLeave,
                        onAccept: (question) => _onAccept(question, game),
                        builder: (context, incoming, rejected) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(5),
                            child: DottedBorder(
                              color: Colors.blue,
                              strokeWidth: 1,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(31, 140, 247,
                                      _guessingLetter ? 0.2 : 0.0),
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Center(
                                      child: GestureDetector(
                                        onTap: () => _showHelpDialog(context),
                                        child: SizedBox(
                                          width: 100,
                                          height: 100,
                                          child: Image.asset(
                                              'assets/question_mark.png'),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
                  SizedBox(
                    height: sizeConfig.safeBlockHorizontal * 100 <= 500.0
                        ? containerHeight * 4
                        : containerHeight,
                    child: GridView.count(
                      crossAxisCount:
                          sizeConfig.safeBlockHorizontal * 100 <= 500.0
                              ? 6
                              : 12,
                      children: game.positionedQuestions
                          .map(
                            (positionedQuestion) =>
                                DragTarget<PositionedQuestion>(
                              onWillAccept: (draggedQuestion) {
                                final allowDrop = _feedbackController!
                                    .updateFeedback(draggedQuestion!.question,
                                        positionedQuestion.question, false);

                                if (allowDrop) {
                                  final draggedQuestionNumber =
                                      draggedQuestion.questionNumber;
                                  draggedQuestion.updateQuestionNumber(
                                      positionedQuestion.questionNumber!);
                                  positionedQuestion.updateQuestionNumber(
                                      draggedQuestionNumber!);
                                }

                                return allowDrop;
                              },
                              onLeave: (draggedQuestion) {
                                draggedQuestion!.undoUpdateQuestionNumber();
                                positionedQuestion.undoUpdateQuestionNumber();

                                _feedbackController!.updateFeedback(
                                    draggedQuestion.question, null, false);
                              },
                              onAccept: (draggedQuestion) {
                                draggedQuestion.commitUpdateQuestionNumber();
                                positionedQuestion.commitUpdateQuestionNumber();
                              },
                              builder: (_, question, __) =>
                                  ChangeNotifierProvider<
                                      PositionedQuestion>.value(
                                value: positionedQuestion,
                                child: Consumer<PositionedQuestion>(
                                  builder: (_, positionedQuestion, __) {
                                    return LayoutBuilder(
                                        builder: (_, constraints) {
                                      return Draggable<PositionedQuestion>(
                                        data: positionedQuestion,
                                        feedback: DragQuestionFeedback(
                                            positionedQuestion.question,
                                            _feedbackController!,
                                            constraints.maxWidth,
                                            constraints.maxHeight),
                                        child: QuestionPlacement(
                                            positionedQuestion),
                                      );
                                    });
                                  },
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  SizedBox(
                    height: 55,
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: TextField(
                                controller: _guessedWordTextController,
                                decoration: InputDecoration(
                                    labelText:
                                        text.translate('what_is_the_word')),
                                keyboardType: TextInputType.text,
                                autocorrect: false,
                                enableSuggestions: false),
                          ),
                        ),
                        Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 4),
                          child: ElevatedButton(
                            onPressed: () => _guessWord(game, context),
                            style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 5)),
                            child: Text(
                              text.translate('check'),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
