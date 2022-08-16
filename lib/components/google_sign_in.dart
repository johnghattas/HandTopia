import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertestproject/constants.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;


class CGoogleSignIn{
  static FirebaseAuth _auth = FirebaseAuth.instance;
  static GoogleSignIn _signIn = GoogleSignIn();

  Future<User?> signInGoogle() async {
    try {
      final GoogleSignInAccount googleSignInAccount = await (_signIn.signIn() as FutureOr<GoogleSignInAccount>);
      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential authResult =
      await _auth.signInWithCredential(credential);
      final User user = authResult.user!;

      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final User currentUser = _auth.currentUser!;
      assert(user.uid == currentUser.uid);

      return currentUser;
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future loginRequest(User user,String method) async {
    var request = await http.post(Uri.parse('$kUrl/user/auth/loginMethod'), headers: {
      'Accept': 'application/json'
    }, body: {
      'token': (await user.getIdToken()),
      'method': method
    });

    return jsonDecode(request.body);
  }

  static signOut() {

    _signIn.signOut();
    _auth.signOut();
  }

}