import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'achievements_page.dart';

class AchievementsProvider with ChangeNotifier {
  final List<Mission> _distanceData = [];
  final List<Mission> _timeData = [];
  final List<Mission> _paceData = [];
  bool _isInitialized = false;
  // 데이터베이스 초기화 여부를 반환하는 getter 메서드
  List<Mission> get distanceData => _distanceData;
  List<Mission> get timeData => _timeData;
  List<Mission> get paceData => _paceData;

  bool get isInitialized => _isInitialized;
  set isInitialized(bool value) {
    _isInitialized = value;
    notifyListeners(); // 변경 사항 알림
  }

  Future<void> refreshMissionData() async {
    _distanceData.clear();
    _timeData.clear();
    _paceData.clear();

    // 새로운 미션 데이터 가져오기
    await initializeDatabase();
  }

  void achieveFetch() {
    _isInitialized = false;
  }

  // Fetching data from Firestore
  Future<DocumentSnapshot<Map<String, dynamic>>> _fetchMissionData(
      String uid, String missionName) {
    return FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .collection('Mission')
        .doc(missionName)
        .get();
  }

  // Adding fetched data to respective lists
  Future<void> _addMissionData(
      List<Mission> missionList, String missionName) async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _fetchMissionData(
      FirebaseAuth.instance.currentUser!.uid,
      missionName,
    );

    final Map<String, dynamic> missionData =
        snapshot.data() as Map<String, dynamic>;
    final Mission mission = Mission.fromJson(missionData);
    missionList.add(mission);
  }

  // Initialize database and fetch mission data
  Future<void> initializeDatabase() async {
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    bool isCollectionExists = await _checkIfCollectionExists(uid, 'Mission');

    if (!isCollectionExists) {
      await _initializeMissionData(uid, firestore);
    }

    // Fetching and adding mission data for time15, time30, time60
    await _addMissionData(_timeData, 'time15');
    await _addMissionData(_timeData, 'time30');
    await _addMissionData(_timeData, 'time60');

    // Fetching and adding mission data for pace550, pace600, pace630
    await _addMissionData(_paceData, 'pace550');
    await _addMissionData(_paceData, 'pace600');
    await _addMissionData(_paceData, 'pace630');

    // Fetching and adding mission data for distance3, distance5, distance10
    await _addMissionData(_distanceData, 'distance3');
    await _addMissionData(_distanceData, 'distance5');
    await _addMissionData(_distanceData, 'distance10');
  }

  // Check if collection exists in Firestore
  Future<bool> _checkIfCollectionExists(
      String uid, String collectionName) async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .collection(collectionName)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  // Initialize mission data if not exists
  Future<void> _initializeMissionData(
      String uid, FirebaseFirestore firestore) async {
    final missions = [
      Mission(lottieFileName: 'distance3', state: 'bronze', num: 0, value: 0.1),
      Mission(lottieFileName: 'distance5', state: 'bronze', num: 0, value: 0.1),
      Mission(
          lottieFileName: 'distance10', state: 'bronze', num: 0, value: 0.1),
      Mission(lottieFileName: 'time15', state: 'bronze', num: 0, value: 0.1),
      Mission(lottieFileName: 'time30', state: 'bronze', num: 0, value: 0.1),
      Mission(lottieFileName: 'time60', state: 'bronze', num: 0, value: 0.1),
      Mission(lottieFileName: 'pace550', state: 'bronze', num: 0, value: 0.1),
      Mission(lottieFileName: 'pace600', state: 'bronze', num: 0, value: 0.1),
      Mission(lottieFileName: 'pace630', state: 'bronze', num: 0, value: 0.1),
    ];

    for (var mission in missions) {
      await firestore
          .collection('Users')
          .doc(uid)
          .collection('Mission')
          .doc(mission.lottieFileName)
          .set(mission.toJson());
    }
  }
}
