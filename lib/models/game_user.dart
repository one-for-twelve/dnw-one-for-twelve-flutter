import '../services/user_game_settings.dart';

class GameUser {
  final String displayName;
  final String photoUrl;
  final String? _providerName;
  final bool hasSubscription;
  final bool isSuperUser;
  final UserGameSettings gameSettings;

  String get providerName =>
      _providerName?.split('.').first.toUpperCase() ?? '';

  GameUser(this.displayName, this.photoUrl, this._providerName,
      this.hasSubscription, this.isSuperUser, this.gameSettings);
}
