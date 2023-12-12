import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../login/login_api.dart';
import 'RoutePage.dart';
import 'log_provider.dart'; // LogProvider 파일에 맞게 수정해주세요.

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
    final logProvider = Provider.of<LogProvider>(context);
    final User? user = auth.currentUser;
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 0),
            const Text(
              '당신의 러닝 기록',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _buildRecordList(logProvider.cachedRecords),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordList(List<Map<String, dynamic>> cachedRecords) {
    return cachedRecords.isEmpty
        ? const Center(child: Text('No records available yet.'))
        : ListView.builder(
      itemCount: cachedRecords.length,
      itemBuilder: (BuildContext context, int index) {
        Map<String, dynamic> record = cachedRecords[index];
        Timestamp timestamp = record['timestamp'] as Timestamp;
        DateTime dateTime = timestamp.toDate();
        String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
        return Card(
          color: Colors.yellow,
          elevation: 2,
          margin: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 4.0,
          ),
          child: ListTile(
            leading: const Icon(Icons.run_circle, color: Colors.black),
            title: Text(
              '날짜: $formattedDate',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('거리: ${record['distance']} km'),
                Text('시간: ${record['duration']}'),
                // Add other fields as needed
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () {
                _viewRoute(context, record);
              },
            ),
          ),
        );
      },
    );
  }
}
