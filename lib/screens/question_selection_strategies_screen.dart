import 'package:flutter/material.dart';
import 'package:one_for_twelve/services/languages.dart';
import 'package:settings_ui/settings_ui.dart';

import '../models/question_selection_strategies.dart';
import '../app_localizations.dart';

class QuestionSelectionStrategiesScreen extends StatefulWidget {
  final String _languageCode;
  final QuestionSelectionStrategies _currentStrategy;
  final Function(QuestionSelectionStrategies strategy) _onStrategyChosen;

  const QuestionSelectionStrategiesScreen(
      this._languageCode, this._currentStrategy, this._onStrategyChosen,
      {super.key});

  @override
  QuestionSelectionStrategiesScreenState createState() =>
      QuestionSelectionStrategiesScreenState();
}

class QuestionSelectionStrategiesScreenState
    extends State<QuestionSelectionStrategiesScreen> {
  @override
  Widget build(BuildContext context) {
    final text = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(text.translate('game_level')),
        centerTitle: true,
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
              tiles: Languages.getAvailableQuestionSelectionStrategies(
                      widget._languageCode)
                  .map((strategy) {
            return SettingsTile(
              title: Text(text.translate('game_level_${strategy.index}')),
              trailing: trailingWidget(
                  widget._currentStrategy.index == strategy.index),
              onPressed: (_) {
                widget._onStrategyChosen(strategy);
                Navigator.of(context).pop();
              },
            );
          }).toList()),
        ],
      ),
    );
  }

  Widget trailingWidget(bool isSelected) {
    return (isSelected)
        ? const Icon(Icons.check, color: Colors.blue)
        : const Icon(null);
  }
}
