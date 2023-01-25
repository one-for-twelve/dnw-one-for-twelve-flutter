import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

import '../app_localizations.dart';
import '../services/languages.dart';

class LanguagesScreen extends StatefulWidget {
  final String _currentLanguageCode;
  final Function(String languageCode) _onLanguageChosen;

  const LanguagesScreen(this._currentLanguageCode, this._onLanguageChosen,
      {super.key});

  @override
  LanguagesScreenState createState() => LanguagesScreenState();
}

class LanguagesScreenState extends State<LanguagesScreen> {
  @override
  Widget build(BuildContext context) {
    final text = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(text.translate('languages')),
        centerTitle: true,
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
              tiles: Languages.getSupportedLanguageCodes().map((languageCode) {
            return SettingsTile(
              title: Text(text.translate('language_$languageCode')),
              trailing:
                  trailingWidget(widget._currentLanguageCode == languageCode),
              onPressed: (_) {
                widget._onLanguageChosen(languageCode);
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
