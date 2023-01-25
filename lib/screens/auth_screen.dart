import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../firebase_options.dart';

import '../models/game_user.dart';

class AuthScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
      clientId: DefaultFirebaseOptions.currentPlatform.iosClientId);
  final GameUser? _user;

  AuthScreen(this._user, {super.key});

  Future<void> _handleSignInGoogle() async {
    final googleUser = await _googleSignIn.signIn();

    if (googleUser == null) return;

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await _auth.signInWithCredential(credential);
  }

  Future<void> _handleSignOut() async {
    await _auth.signOut();
  }

  Widget _buildColumn(BuildContext context, GameUser? user) {
    return user?.providerName == null
        ? _buildNotLoggedInColumn(context, user)
        : _buildLoggedInColumn(context, user!);
  }

  Widget _buildNotLoggedInColumn(BuildContext ctx, GameUser? user) {
    return Column(
      children: [
        const SizedBox(height: 20),
        SignInButton(Buttons.Google, text: 'Log in with Google',
            onPressed: () async {
          await _handleSignInGoogle();
        })
      ],
    );
  }

  Future<void> navigateHome(BuildContext ctx) async {
    await Navigator.of(ctx).pushNamedAndRemoveUntil('/home', (_) => false);
  }

  Widget _buildLoggedInColumn(BuildContext ctx, GameUser user) {
    return Column(
      children: [
        Text('Logged on using ${user.providerName} as ${user.displayName}'),
        const SizedBox(
          height: 10,
        ),
        ElevatedButton(
          onPressed: () async {
            await _handleSignOut();
            await navigateHome(ctx);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Logout'),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildColumn(context, _user),
        ),
      ),
    );
  }
}
