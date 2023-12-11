import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:irun/Achievements/achievement_provider.dart';
import 'package:irun/login/login_api.dart';
import 'package:irun/mission/mission_page.dart';
import 'package:irun/record/firestore_service.dart';
import 'package:provider/provider.dart';

class StopMapScreen extends StatefulWidget {
  final String formattedTime;
  final String pace;
  final List<Map<String, double>> routeData;
  final Position? currentLocation;
  final List<Marker> markers;
  final Stopwatch stopwatch;
  final double totalDistance;
  final bool isRunning;

  StopMapScreen({
    required this.formattedTime,
    required this.pace,
    required this.routeData,
    required this.currentLocation,
    required this.markers,
    required this.stopwatch,
    required this.totalDistance,
    required this.isRunning,
  });

  @override
  _StopMapScreenState createState() => _StopMapScreenState();
}

class _StopMapScreenState extends State<StopMapScreen> {
  final User? user = auth.currentUser;

  GoogleMapController? _controller;
  final List<Marker> _markers = [];
  final Stopwatch _stopwatch = Stopwatch();
  StreamSubscription<Position>? _positionStreamSubscription;

  FlutterTts tts = FlutterTts();
  bool isSetted = false;

  Timer? _timer;

  LatLng? currentPosition;

  double caloriesBurned = 0.0;

  @override
  void initState() {
    super.initState();
    loadUserInfoAndCalculateCalories();
  }

  Future<void> loadUserInfoAndCalculateCalories() async {
    //칼로리 저장
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    double? height;
    double? weight;
    int? age;
    bool gender = true;

    // 정보 가져오기
    DocumentSnapshot userInfoSnapshot =
        await firestore.collection("Users").doc(user!.uid).get();

    if (userInfoSnapshot.exists) {
      height = userInfoSnapshot['height'];
      weight = userInfoSnapshot['weight'];
      age = userInfoSnapshot['age'];
      gender = userInfoSnapshot['gender'];
    }

    setState(() {
      caloriesBurned = calculateCalories(
          weight!, height!, age!, gender, widget.totalDistance / 1000);
    });
  }

  Future<void> _stopRecording(BuildContext context) async {
    _stopwatch.stop();
    _positionStreamSubscription?.cancel();
    _timer?.cancel();

    // FirestoreService를 사용하여 데이터 저장
    final missionData = Provider.of<MissionData>(context, listen: false);
    await FirestoreService.uploadDataToFirestore(
      user: user!,
      currentLocation: widget.currentLocation!,
      markers: widget.markers,
      stopwatch: widget.stopwatch,
      totalDistance: widget.totalDistance,
      missionData: missionData,
      caloriesBurned: caloriesBurned,
    );
    Provider.of<AchievementsProvider>(context, listen: false)
        .refreshMissionData();
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  // 경로 데이터를 기반으로 초기 확대 수준을 계산하는 함수
  double _calculateZoomLevel(List<Map<String, double>> routeData) {
    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;

    for (var data in routeData) {
      double latitude = data['latitude']!;
      double longitude = data['longitude']!;

      // 최소 및 최대 경도 및 위도 업데이트
      minLat = min(minLat, latitude);
      maxLat = max(maxLat, latitude);
      minLng = min(minLng, longitude);
      maxLng = max(maxLng, longitude);
    }

    // 경도와 위도의 차이를 계산하여 확대 수준 결정
    double latDiff = maxLat - minLat;
    double lngDiff = maxLng - minLng;
    double zoomLevel =
        min(log(360 / lngDiff) / log(2), log(180 / latDiff) / log(2));

    return zoomLevel; // 조정 가능한 값으로 조절
  }

  double calculateCalories(
      double weight, double height, int age, bool isMale, double distance) {
    double metValue = 7.0; // 달리기의 MET 값은 일반적으로 7.0입니다.

    // 운동 시간 (분)을 시간 (시간)으로 변환합니다.
    double hours = distance / 60.0;

    // 달리기로 인한 칼로리 소모 계산
    double runningCalories = metValue * weight * hours;

    return runningCalories; // 달리기로 인한 칼로리만 반환
  }

  @override
  Widget build(BuildContext context) {
    String formattedDistance = (widget.totalDistance / 1000).toStringAsFixed(2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Running'),
      ),
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        double height = MediaQuery.of(context).size.height * 1;
        return Column(
          children: [
            Container(
                height: height * 0.2, // 컨테이너 높이 조정
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Time, Distance, Pace, Calories를 각각 Row로 표시
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          '시간: ${widget.formattedTime}',
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '거리: $formattedDistance km',
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          '페이스: ${widget.pace}',
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '칼로리: ${caloriesBurned.toStringAsFixed(1)} kcal',
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                )),
            SizedBox(
              height: height * 0.5,
              child: GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  rootBundle
                      .loadString('assets/map/mapstyle.json')
                      .then((String mapStyle) {
                    controller.setMapStyle(mapStyle);
                    _controller = controller;

                    // 경로의 초기 확대 수준 설정
                    double initialZoom = _calculateZoomLevel(widget.routeData);

                    controller.moveCamera(
                      CameraUpdate.newLatLngZoom(
                        LatLng(
                          widget.routeData.last['latitude']!,
                          widget.routeData.last['longitude']!,
                        ),
                        initialZoom,
                      ),
                    );
                  });
                },
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    widget.routeData.last['latitude']!,
                    widget.routeData.last['longitude']!,
                  ),
                  zoom: 18.0, // 초기 확대 수준 설정
                ),
                markers: Set.from(_markers),
                polylines: Set.from([
                  Polyline(
                    polylineId: const PolylineId("runningRoute"),
                    color: Colors.blue,
                    points: widget.routeData
                        .map((data) =>
                            LatLng(data['latitude']!, data['longitude']!))
                        .toList(),
                  ),
                ]),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
              ),
            ),
            const SizedBox(width: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  height: height * 0.15,
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: const Text('재개'),
                  ),
                ), // 버튼 사이 간격 조절을 위한 SizedBox 사용
                Container(
                  height: height * 0.15,
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      _stopRecording(context);
                    },
                    child: const Text('종료'),
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }
}
