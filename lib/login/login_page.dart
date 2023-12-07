import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:irun/login/login_api.dart';

class LoginPage extends StatelessWidget {

  void navigateAfterLogin(BuildContext context, User user) {
    FirebaseFirestore.instance.collection('Users').doc(user.uid).get().then((doc) {
      final data = doc.data();
      if (data != null && data.containsKey('height') && data.containsKey('weight')) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else {
        Navigator.pushNamedAndRemoveUntil(context, '/body', (route) => false);
      }
    }).catchError((e) {
      print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            //Image.asset('assets/images/irunlogo.png'),
            ElevatedButton(
                onPressed: () {
                  signInWithGoogle().then((user){
                    if (user!=null) {
                      navigateAfterLogin(context, user);
                    }
                  }).catchError((e) {
                    print(e);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff3e4784),
                  padding: const EdgeInsets.all(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/glogo.png'),
                    const SizedBox(width: 10),
                    const Text(
                      'Login with Google',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                )
            ),
          ],
        ),
      ),
    );
  }
}