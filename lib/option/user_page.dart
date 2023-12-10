import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:irun/login/login_api.dart';

final User? user = auth.currentUser;

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final String photoURL = user!.photoURL!;

  double height = 0.0;

  double weight = 0.0;

  int age = 0;

  bool gender = false;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      getUserData(user!.uid);
    }
  }

  Future<void> getUserData(String uid) async {
    DocumentSnapshot userSnapshot =
    await firestore.collection('Users').doc(uid).get();
    Map<String, dynamic> userData =
        userSnapshot.data() as Map<String, dynamic>? ?? {};

    setState(() {
      height = (userData['height'] as num).toDouble();
      weight = (userData['weight'] as num).toDouble();
      age = (userData['age'] as num).toInt();
      gender = userData['gender'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 프로필'),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 50.0, bottom: 30),
                    child: ClipRRect(
                      borderRadius:
                      BorderRadius.circular(100), // 이미지의 높이나 너비의 절반으로 설정
                      child: Image.network(photoURL),
                    ),
                  ),
                  Text(
                    user!.displayName ?? ' ',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            Divider(
              height: 30,
              indent: 30,
              endIndent: 30,
              color: Colors.grey[800],
            ),
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(
                    left: 40,
                    bottom: 5,
                  ),
                  child: Text(
                    '나이:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 40,
                    bottom: 10,
                  ),
                  child: Text(
                    '$age',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Divider(
              height: 30,
              indent: 30,
              endIndent: 30,
              color: Colors.grey[800],
            ),
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(
                    left: 40,
                    bottom: 5,
                  ),
                  child: Text(
                    '성별:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 40,
                    bottom: 10,
                  ),
                  child: Text(
                    gender ? '남자' : '여자',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Divider(
              height: 30,
              indent: 30,
              endIndent: 30,
              color: Colors.grey[800],
            ),
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(
                    left: 40,
                    bottom: 5,
                  ),
                  child: Text(
                    '키:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 75,
                    bottom: 10,
                  ),
                  child: Text(
                    '${height.toString()} cm',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Divider(
              height: 30,
              indent: 30,
              endIndent: 30,
              color: Colors.grey[800],
            ),
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(
                    left: 40,
                    bottom: 5,
                  ),
                  child: Text(
                    '몸무게:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 40,
                    bottom: 10,
                  ),
                  child: Text(
                    '${weight.toString()} kg',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}