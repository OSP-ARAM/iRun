import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RankingProvider with ChangeNotifier {
  List<Map<String, dynamic>> _rankingData = [];
  bool _isLoading = false;
  bool _isInitialLoadDone = false;
  int _myRankingIndex = -1;
  bool _viewMyRanking = false;

  bool get viewMyRanking => _viewMyRanking;
  bool get isInitialLoadDone => _isInitialLoadDone;
  List<Map<String, dynamic>> get rankingData => _rankingData;
  bool get isLoading => _isLoading;
  int get myRankingIndex => _myRankingIndex;

  void toggleViewMyRanking(bool view) {
    _viewMyRanking = view;
    notifyListeners();
  }

  Future<void> loadRankingData({bool forceLoad = false}) async {
    if (_isInitialLoadDone && !forceLoad) {
      return;
    }
print('ho');
    _isLoading = true;

    List<Map<String, dynamic>> userProfiles = await _getAllUserProfiles();
    List<Future<double>> scoreFutures = userProfiles.map((userProfile) {
      return _calculateUserScore(userProfile['uid']);
    }).toList();

    List<double> scores = await Future.wait(scoreFutures);

    for (int i = 0; i < userProfiles.length; i++) {
      userProfiles[i]['score'] = scores[i];
    }

    _rankingData = userProfiles..sort((a, b) => b['score'].compareTo(a['score']));
    _myRankingIndex = _calculateMyRankingIndex();

    _isInitialLoadDone = true;
    _isLoading = false;
    notifyListeners();
  }

  int _calculateMyRankingIndex() {
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    for (int i = 0; i < _rankingData.length; i++) {
      if (_rankingData[i]['uid'] == currentUserId) {
        return i;
      }
    }
    return -1; // 사용자를 찾지 못한 경우
  }

  Future<List<Map<String, dynamic>>> _getAllUserProfiles() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Users').get();
    return querySnapshot.docs.map((doc) => {'uid': doc.id, ...doc.data() as Map<String, dynamic>}).toList();
  }

  Future<double> _calculateUserScore(String userId) async {
    double missionScore = await _getUserMissionScore(userId);
    double totalDistance = await _getTotalDistance(userId);
    return totalDistance + missionScore;
  }

  double calculateScoreForMission(int num, double scorePerCompletion) {
    return num * scorePerCompletion;
  }

  Future<double> _getUserMissionScore(String userId) async {
    double totalScore = 0.0;

    final Map<String, double> missionScores = {
      'distance10': 1.5,
      'distance5': 1.0,
      'distance3': 0.5,
      'pace550': 1.5,
      'pace600': 1.0,
      'pace630': 0.5,
      'time15': 0.5,
      'time30': 1.0,
      'time60': 1.5,
    };

    CollectionReference missionsRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('Mission');

    for (var mission in missionScores.keys) {
      DocumentSnapshot missionDoc = await missionsRef.doc(mission).get();
      Map<String, dynamic> missionData = missionDoc.data() as Map<String, dynamic>? ?? {};
      int num = missionData['num'] ?? 0;
      totalScore += calculateScoreForMission(num, missionScores[mission]!);
    }

    return totalScore;
  }

  Future<double> _getTotalDistance(String userId) async {
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
}
