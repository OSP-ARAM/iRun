import 'package:flutter/material.dart';

import 'package:irun/login/login_api.dart';

class LogoutPage extends StatelessWidget {
  final BuildContext context;
  Future<void> signOutGoogle() async {
    await auth.signOut();
    await googleSignIn.signOut();
  }

  const LogoutPage({super.key, required this.context});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('정말 로그아웃 하시겠습니까?'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, '아니요'),
          child: const Text('아니오'),
        ),
        TextButton(
          onPressed: () async {
            try {
              await signOutGoogle();
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            } catch (e) {
              print("an error occurred");
            }
          },
          child: const Text('네'),
        ),
      ],
    );
  }
}
