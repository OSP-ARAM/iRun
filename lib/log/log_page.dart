import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:irun/navi/navi.dart';
import 'package:intl/intl.dart';

class LogPage extends StatelessWidget {
  const LogPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('기록 페이지'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '당신의 러닝 기록',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('running_records').snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('데이터를 불러오는 중 오류가 발생했습니다.'),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text('아직 기록된 데이터가 없습니다.'),
                    );
                  }

                  return ListView(
                    children: snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                      Timestamp timestamp = data['timestamp'] as Timestamp;
                      DateTime dateTime = timestamp.toDate();

                      String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);

                      return ListTile(
                        title: Text('Date: $formattedDate'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Distance: ${data['distance']} meters'),
                            Text('Duration: ${data['duration']}'),
                          ],
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        isThreeLine: true,
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: MenuBottom(currentIndex: 0),
    );
  }
}
