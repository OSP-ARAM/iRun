import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn(
    clientId:
    "592989854108-lttqfekciv3pp1tvvji5oscvdojf177g.apps.googleusercontent.com");

Future<User?> signInWithGoogle() async {
  final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
  if (googleSignInAccount != null) {
    final GoogleSignInAuthentication googleSignInAuthentication =
    await googleSignInAccount.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential authResult =
    await auth.signInWithCredential(credential);
    final User? user = authResult.user;

    if (user != null) {
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final User? currentUser = auth.currentUser;
      assert(user.uid == currentUser?.uid);
      FirebaseFirestore.instance.collection('Users').doc(user.uid).update({
        'displayName': user.displayName,
        'email': user.email,
        'photoURL': user.photoURL,
      });

      print('Google SignIn Succeeded: ${user.uid}');
      return user;
    }
  }

  return null;
}
