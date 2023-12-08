import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RankingPage extends StatefulWidget {
  @override
  _RankingPageState createState() => _RankingPageState();
}

User? currentUser = FirebaseAuth.instance.currentUser;
String? uid = currentUser?.uid;

Future<List<Map<String, dynamic>>> getAllUserProfiles() async {
  QuerySnapshot querySnapshot =
  await FirebaseFirestore.instance.collection('Users').get();

  return querySnapshot.docs.map((doc) =>
  {
    'uid': doc.id,
    ...doc.data() as Map<String, dynamic>,
  }
  ).toList();
}

int calculateMyRankingIndex(String myUid, List<QueryDocumentSnapshot> userDocs) {
  for (int i = 0; i < userDocs.length; i++) {
    if (userDocs[i].id == myUid) {
      return i; // 순위 (0부터 시작하는 인덱스)
    }
  }
  return -1; // 사용자를 찾지 못한 경우
}

class _RankingPageState extends State<RankingPage> {
  String? name = currentUser?.displayName;
  String? email = currentUser?.email;
  String? photoUrl = currentUser?.photoURL;
  final String currentSeason = '시즌 2023';
  int myRankingIndex = 0;
  bool viewMyRanking = false;

  List<Map<String, dynamic>> users = [];
  Future<void> loadUserProfiles() async {
    var userProfiles = await getAllUserProfiles();
    int myIndex = userProfiles.indexWhere((user) => user['uid'] == uid);
    setState(() {
      users = userProfiles;
      myRankingIndex = myIndex;
    });
  }

  @override
  void initState() {
    super.initState();
    loadUserProfiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              currentSeason,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Scrollbar(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  var user = users[index];
                  if (!viewMyRanking || (index >= myRankingIndex - 2 && index <= myRankingIndex + 3)) {
                    return Card(
                      color: index == myRankingIndex ? Colors.yellow : null,
                      child: ListTile(
                        leading: user['photoURL'] != null
                            ? Image.network(user['photoURL'])
                            : CircleAvatar(child: Icon(Icons.person)),
                        title: Text(user['displayName'] ?? 'No Name'),
                        subtitle: Text('티어: ${user['tier']}'),
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  viewMyRanking = false;
                });
              },
              child: const Text('TOP 30'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  viewMyRanking = true;
                });
              },
              child: const Text('내 티어'),
            ),
          ],
        ),
      ),
    );
  }
}