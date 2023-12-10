import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:irun/login/login_api.dart';

final User? user = auth.currentUser;

class DeletePage extends StatelessWidget {
  final BuildContext context;
  Future<void> deleteUserFromFirebase() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    firestore.collection('Users').doc(user?.uid).delete();
    user?.delete();
    await auth.signOut();
    await googleSignIn.signOut();
  }

  const DeletePage({super.key, required this.context});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('정말 회원 탈퇴 하시겠습니까?'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, '아니요'),
          child: const Text('아니오'),
        ),
        TextButton(
          onPressed: () async {
            try {
              await deleteUserFromFirebase();
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
