import '../models/question_selection_strategies.dart';

class Languages {
  static String dutch = 'nl';
  static String english = 'en';

  static List<String> getSupportedLanguageCodes() {
    return [
      Languages.english,
      Languages.dutch,
    ];
  }

  static List<QuestionSelectionStrategies>
      getAvailableQuestionSelectionStrategies(String languageCode) {
    if (languageCode == "en") return [QuestionSelectionStrategies.Demo];

    return QuestionSelectionStrategies.values;
  }
}
