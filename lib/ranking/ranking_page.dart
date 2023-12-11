import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  _RankingPageState createState() => _RankingPageState();
}

User? currentUser = FirebaseAuth.instance.currentUser;
String? uid = currentUser?.uid;

Future<List<Map<String, dynamic>>> getAllUserProfiles() async {
  QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('Users').get();

  return querySnapshot.docs
      .map((doc) => {
            'uid': doc.id,
            ...doc.data() as Map<String, dynamic>,
          })
      .toList();
}

Future<double> getTotalDistance(String userId) async {
  double totalDistance = 0.0;

  QuerySnapshot runRecords = await FirebaseFirestore.instance
      .collection('Users')
      .doc(userId)
      .collection('Run record')
      .get();

  for (var record in runRecords.docs) {
    var data = record.data() as Map<String, dynamic>? ?? {};

    var distanceValue = data['distance'];
    double distance = 0.0;

    if (distanceValue is String) {
      distance = double.tryParse(distanceValue) ?? 0.0;
    } else if (distanceValue is double) {
      distance = distanceValue;
    }

    totalDistance += distance;
  }

  return totalDistance;
}

int calculateMyRankingIndex(
    String myUid, List<QueryDocumentSnapshot> userDocs) {
  for (int i = 0; i < userDocs.length; i++) {
    if (userDocs[i].id == myUid) {
      return i;
    }
  }
  return -1;
}

class _RankingPageState extends State<RankingPage> {
  String? name = currentUser?.displayName;
  String? email = currentUser?.email;
  String? photoUrl = currentUser?.photoURL;
  final String currentSeason = '시즌 2023';
  int myRankingIndex = 0;
  bool viewMyRanking = false;

  List<Map<String, dynamic>> users = [];
  Future<void> loadUserProfilesAndRank() async {
    List<Map<String, dynamic>> userProfiles = await getAllUserProfiles();
    List<Future<double>> distanceFutures = [];

    for (var userProfile in userProfiles) {
      distanceFutures.add(getTotalDistance(userProfile['uid']));
    }

    List<double> distances = await Future.wait(distanceFutures);

    for (int i = 0; i < userProfiles.length; i++) {
      userProfiles[i]['totalDistance'] = distances[i];
    }

    userProfiles.sort((a, b) => b['totalScore'].compareTo(a['totalScore']));

    int myIndex = userProfiles.indexWhere((user) => user['uid'] == uid);

    setState(() {
      users = userProfiles;
      myRankingIndex = myIndex;
    });
  }

  @override
  void initState() {
    super.initState();
    loadUserProfilesAndRank();
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
                  if (!viewMyRanking ||
                      (index >= myRankingIndex - 2 &&
                          index <= myRankingIndex + 3)) {
                    return Card(
                      color: index == myRankingIndex ? Colors.yellow : null,
                      child: ListTile(
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 30,
                              child: Text('${index + 1}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20)),
                            ),
                            const SizedBox(width: 20), // 숫자와 이미지 사이의 간격
                            user['photoURL'] != null
                                ? Image.network(user['photoURL'],
                                    width: 40, height: 40)
                                : const CircleAvatar(child: Icon(Icons.person)),
                          ],
                        ),
                        title: Text(user['displayName'] ?? 'No Name', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('점수 : ${user['totalScore'].toStringAsFixed(2)}'),
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
