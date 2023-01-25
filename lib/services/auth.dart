import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/game_user.dart';
import 'user_game_settings.dart';

class Auth {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Auth._();

  static final Auth instance = Auth._();

  Future<GameUser?> getCurrentUser() async {
    if (_auth.currentUser == null) return null;

    final currentUser = _auth.currentUser!;
    final providerId = currentUser.providerData[0].providerId;

    // Determine if user is superUser or has subscription
    // final fireStoreUserDoc = await FirebaseFirestore.instance
    //     .doc('1for12/AUTH/USERS/${currentUser.uid.toString()}')
    //     .get();
    // final fireStoreUser = fireStoreUserDoc.data();

    // final hasSubscription = fireStoreUser?['hasSubscription'] ?? false;
    // final isSuperUser = fireStoreUser?['isSuperUser'] ?? false;

    final gamePrefs = await UserGameSettings.createFromSharedPreferences();

    return GameUser(currentUser.displayName ?? 'Anonymous',
        currentUser.photoURL ?? '', providerId, false, false, gamePrefs);
  }

  Stream<User?> get onAuthStateChanged {
    return _auth.authStateChanges();
  }
}
