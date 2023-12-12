import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LogProvider extends ChangeNotifier {
  late List<Map<String, dynamic>> _cachedRecords = [];
  bool _isDataLoaded = false;

  bool get isDataLoaded => _isDataLoaded;
  List<Map<String, dynamic>> get cachedRecords => _cachedRecords;

  Future<void> fetchAndCacheRecords() async {
    final User? user = FirebaseAuth.instance.currentUser;

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("Users")
          .doc(user!.uid)
          .collection("Run record")
          .orderBy('timestamp', descending: true)
          .get();

      _cachedRecords = querySnapshot.docs.map((DocumentSnapshot document) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        // Timestamp timestamp = data['timestamp'] as Timestamp;
        // DateTime dateTime = timestamp.toDate();
        // String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);

        // Return data directly here
        return data;
      }).cast<Map<String, dynamic>>().toList();
      _isDataLoaded = true;
      notifyListeners();
    } catch (e) {
      // Handle errors
      print('Error fetching and caching records: $e');
    }
  }
}
