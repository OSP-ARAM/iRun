import 'package:flutter/material.dart';
import 'package:irun/login/login_api.dart';
import 'package:irun/home/home_page.dart';

import '/main.dart';

class LoginPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                signInWithGoogle().then((user){
                  if (user!=null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyHomePage()),
                    );
                  }
                }).catchError((e) {
                  print("an error occurred");
                });
              },
              child: Text('구글 로그인'),
            ),
          ],
        ),
      ),
    );
  }
}