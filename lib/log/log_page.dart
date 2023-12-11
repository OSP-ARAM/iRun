import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:irun/log/RoutePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:irun/login/login_api.dart';

class LogPage extends StatelessWidget {
  const LogPage({Key? key}) : super(key: key);

  void _viewRoute(BuildContext context, Map<String, dynamic> routeData) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RoutePage(routeData: routeData)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = auth.currentUser;
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 20),
            Text(
              '당신의 러닝 기록',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("Users")
                    .doc(user!.uid)
                    .collection("Run record")
                    .orderBy('timestamp', descending: true).snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('데이터를 불러오는 중 오류가 발생했습니다.'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('아직 기록된 데이터가 없습니다.'));
                  }

                  return ListView(
                    children: snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                      Timestamp timestamp = data['timestamp'] as Timestamp;
                      DateTime dateTime = timestamp.toDate();
                      String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);

                      return Card(
                        color: Colors.yellow,
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                        child: ListTile(
                          leading: Icon(Icons.run_circle, color: Colors.black),
                          title: Text('날짜: $formattedDate', style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('거리: ${data['distance']} km'),
                              Text('시간: ${data['duration']}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.arrow_forward_ios),
                            onPressed: () => _viewRoute(context, data),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
