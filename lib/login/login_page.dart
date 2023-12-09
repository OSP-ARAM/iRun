import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:irun/login/login_api.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  AnimationController? _logoAnimationController;
  AnimationController? _textAnimationController;
  Animation<Offset>? _slideAnimation;
  Animation<double>? _fadeInAnimation;

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
  void initState() {
    super.initState();

    _logoAnimationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _textAnimationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(-1.0, 0.0),
      end: Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _logoAnimationController!,
      curve: Curves.easeInOut,
    ));

    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textAnimationController!,
      curve: Curves.easeIn,
    ));

    _logoAnimationController!.forward().then((_) {
      _textAnimationController!.forward();
    });
  }

  @override
  void dispose() {
    _logoAnimationController!.dispose();
    _textAnimationController!.dispose();
    super.dispose();
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
            SlideTransition(
              position: _slideAnimation!,
              child: Image.asset(
                'assets/images/irunlogo.png',
                height: MediaQuery.of(context).size.height * 0.3,
              ),
            ),
            FadeTransition(
              opacity: _fadeInAnimation!,
              child: Column(
                children: [
                  const SizedBox(height: 25),
                  const Text(
                    'iRun',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: () {
                      signInWithGoogle().then((user) {
                        if (user != null) {
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
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}