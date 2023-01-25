import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:one_for_twelve/app_config.dart';
import 'package:one_for_twelve/logging.dart';
import 'package:one_for_twelve/services/languages.dart';

import '../models/game.dart';
import '../models/question_selection_strategies.dart';

class GameService {
  static Future<Game?> create(
      String languageCode, QuestionSelectionStrategies strategy,
      {bool ignoreIfAuthTokenIsMissing = false}) async {
    try {
      final authToken = await _getAuthToken();
      if (authToken == null && !ignoreIfAuthTokenIsMissing) return null;

      final headers = <String, String>{};
      headers["Authorization"] = "Bearer $authToken";

      final url =
          '${AppConfig.instance.backendBaseUrl}/games/${_getApiLanguage(languageCode)}/${strategy.name}';
      Log.instance.i('Calling: $url');
      final resp = await http.get(Uri.parse(url), headers: headers);
      final result = json.decode(resp.body);

      return Game.fromMap(result);
    } catch (e) {
      Log.instance.e(e);
      return null;
    }
  }

  static String _getApiLanguage(String languageCode) {
    return languageCode == Languages.dutch ? 'Dutch' : 'English';
  }

  static Future<String?> _getAuthToken() async {
    return FirebaseAuth.instance.currentUser == null
        ? null
        : await FirebaseAuth.instance.currentUser!.getIdToken();
  }
}
