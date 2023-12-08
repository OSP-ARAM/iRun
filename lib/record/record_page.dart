import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:irun/login/login_api.dart';
import 'package:irun/mission/mission_page.dart';
import 'package:irun/option/tts_setting_page.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatefulWidget {

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {

  final User? user = auth.currentUser;

  GoogleMapController? _controller;
  List<Marker> _markers = [];
  Polyline _polyline = Polyline(
    polylineId: PolylineId("runningRoute"),
    color: Colors.blue,
    points: [],
  );
  Position? _currentLocation;
  double _totalDistance = 0.0;
  Stopwatch _stopwatch = Stopwatch();
  StreamSubscription<Position>? _positionStreamSubscription;

  FlutterTts tts = FlutterTts();
  bool isSetted = false;

  Timer? _timer;

  LatLng? currentPosition;

  @override
  void initState() {
    super.initState();
    _initTTS();
    _getCurrentLocationAndStartRecording();
  }

  Future<void> _initTTS() async {
    isSetted = await TTSSettingState.getIsSetted();
    if (isSetted) {
      tts = await TTSSetting.getTtsWithSettings(); // tts 인스턴스를 설정으로 업데이트
      tts.speak('러닝을 시작합니다. 힘내세요!');
    }
  }

  void _speak(String message) async {
    if (isSetted) {
      await tts.speak(message);
    }
  }

  Future<void> _getCurrentLocationAndStartRecording() async {
    Position locationData = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentLocation = locationData;
      _updateCameraPosition(_currentLocation!);
      _markers.add(
        Marker(
          markerId: MarkerId('startLocation'),
          position: LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
          infoWindow: InfoWindow(title: 'Start Location'),
          visible: false,
        ),
      );
    });
    _startRecording();
  }

  void _startRecording() {
    _stopwatch.start();
    var locationSettings = LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 1);

    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
            (Position position) {
              _updateCameraPosition(position);
              _updatePolyline(position);
        }
    );

    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {}); // This will trigger a rebuild every second
    });
  }

  void _stopRecording() {
    _stopwatch.stop();
    _positionStreamSubscription?.cancel();
    _timer?.cancel();
    _uploadDataToFirestore();
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  void _updatePolyline(Position position) {

    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('point${_markers.length}'),
          position: LatLng(position.latitude, position.longitude),
          visible: false,
        ),
      );

      if (_markers.length >= 2) {
        LatLng lastPosition = _markers[_markers.length - 2].position;
        LatLng currentPosition = _markers[_markers.length - 1].position;
        double distance = _calculateDistance(
          lastPosition.latitude,
          lastPosition.longitude,
          currentPosition.latitude,
          currentPosition.longitude,
        );

        if (distance >= 0.1) {
          _totalDistance += distance;

          _polyline = Polyline(
            polylineId: PolylineId("runningRoute"),
            color: Colors.blue,
            points: _markers.map((marker) => marker.position).toList(),
          );

          if (_totalDistance >= 1000 * (_markers.length - 1)) {
            _speak('현재, ${(_totalDistance / 1000).toStringAsFixed(1)} 킬로미터 달렸습니다.');
          }
        }
      }
    });
  }

  void _updateCameraPosition(Position position) {
    setState(() {
      currentPosition = LatLng(position.latitude, position.longitude);
    });
    _controller?.animateCamera(
      CameraUpdate.newLatLng(currentPosition!),
    );
  }

  double _calculateDistance(double startLatitude, double startLongitude, double endLatitude, double endLongitude) {
    const int earthRadius = 6371000;
    double latDiff = _degreesToRadians(endLatitude - startLatitude);
    double lonDiff = _degreesToRadians(endLongitude - startLongitude);
    double a = (sin(latDiff / 2) * sin(latDiff / 2)) +
        (cos(_degreesToRadians(startLatitude)) * cos(_degreesToRadians(endLatitude)) * sin(lonDiff / 2) * sin(lonDiff / 2));
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;
    return distance;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  String _formatTime(int milliseconds) {
    int seconds = (milliseconds / 1000).floor();
    int minutes = (seconds / 60).floor();
    int hours = (minutes / 60).floor();
    String hoursStr = (hours % 60).toString().padLeft(2, '0');
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    return '$hoursStr:$minutesStr:$secondsStr';
  }

  String _calculatePace(double distance, int milliseconds) {
    if (distance == 0 || milliseconds == 0) {
      return "0'00''";
    }
    double minutes = milliseconds / 60000.0;
    double distanceKm = distance / 1000.0;
    double pace = minutes / distanceKm;

    // 분과 초로 분리
    int paceMinutes = pace.floor();
    int paceSeconds = ((pace - paceMinutes) * 60).round();

    // 두 자릿수 형식으로 맞춤
    String formattedSeconds = paceSeconds.toString().padLeft(2, '0');

    return "$paceMinutes'$formattedSeconds''";
  }


  void _uploadDataToFirestore() async {
    final missionData = Provider.of<MissionData>(context, listen: false);

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    if (_currentLocation != null && _markers.isNotEmpty) {
      String formattedTime = _formatTime(_stopwatch.elapsedMilliseconds);

      String formattedDistance = (_totalDistance / 1000).toStringAsFixed(2);

      String pace = _calculatePace(_totalDistance, _stopwatch.elapsedMilliseconds);

      DateTime now = DateTime.now();
      String timestamp = now.toIso8601String(); // ISO 8601 형식으로 변환

      List<Map<String, double>> routePoints = _markers.map((marker) {
        return {
          'latitude': marker.position.latitude,
          'longitude': marker.position.longitude
        };
      }).toList();

      List<String> parts = formattedTime.split(':');

      // 시(hour), 분(minute)을 각각 정수로 변환
      int hours = int.parse(parts[0]);
      int minutes = int.parse(parts[1]);

      // 총 시간을 분으로 계산
      int totalMinutes = hours * 60 + minutes;


      String calculatedPace = _calculatePace(_totalDistance, _stopwatch.elapsedMilliseconds);

// 페이스 문자열을 분과 초로 분리
      List<String> paceParts = calculatedPace.split("'");
      int paceMinutes = int.parse(paceParts[0]); // 분
      int paceSeconds = int.parse(paceParts[1].replaceAll("''", "")); // 초


      // distance3 객체 생성
      RunData runData = RunData(
        duration: formattedTime,
        distance: formattedDistance,
        timestamp: DateTime.now(),
        routePoints: routePoints,
        pace: pace,
      );

      // Run record 컬렉션에 저장
      await firestore
          .collection("Users")
          .doc(user!.uid)
          .collection("Run record")
          .doc(timestamp)
          .set(runData.toJson());

      // distance3 객체 생성
      MissionRecord missionRecord = MissionRecord(
        distance: formattedDistance,
        numberSuccesses: 0,
        missionLevel: 1,
      );

      // Mission 컬렉션에 저장
      if (missionData.distance == '3km') {
        if (double.parse(formattedDistance) >= 3.0){
          missionRecord.numberSuccesses = 1;
        }
        DocumentSnapshot snapshot = await firestore
            .collection("Users")
            .doc(user!.uid)
            .collection("Mission")
            .doc("distance3")
            .get();

        if (snapshot.exists) {
          // 문서가 존재하면, 기존 데이터를 가져옵니다.
          var data = snapshot.data() as Map<String, dynamic>;

          // 'numberSuccesses' 값을 가져와서 새로운 값을 더합니다.
          int currentNumberSuccesses = data['numberSuccesses'] ?? 0;
          int updatedNumberSuccesses = currentNumberSuccesses + missionRecord.numberSuccesses; // 또는 적절한 로직으로 값을 증가시킵니다.

          //total distance가져와서 합산
          double currentTotalDistance = double.parse(data['distance']);
          currentTotalDistance += double.parse(missionRecord.distance);
          String updatedDistance = currentTotalDistance.toString();

          int currentLevel = data['level'] ?? 0;
          int updatedLevel = currentLevel + missionRecord.missionLevel;

          // 변경된 데이터로 문서를 업데이트합니다.
          await firestore
              .collection("Users")
              .doc(user!.uid)
              .collection("Mission")
              .doc("distance3")
              .update({'numberSuccesses': updatedNumberSuccesses, 'distance': updatedDistance, 'level' : updatedLevel});
        } else {
          // 문서가 존재하지 않으면, 새 문서를 생성합니다.
          await firestore
              .collection("Users")
              .doc(user!.uid)
              .collection("Mission")
              .doc("distance3")
              .set(missionRecord.toJson()); // 초기 값으로 1 설정
        }
      }

      if (missionData.distance == '5km') {
        if (double.parse(formattedDistance) >= 5.0) {
          missionRecord.numberSuccesses = 1;
        }
        DocumentSnapshot snapshot = await firestore
            .collection("Users")
            .doc(user!.uid)
            .collection("Mission")
            .doc("distance5")
            .get();

        if (snapshot.exists) {
          // 문서가 존재하면, 기존 데이터를 가져옵니다.
          var data = snapshot.data() as Map<String, dynamic>;

          // 'numberSuccesses' 값을 가져와서 새로운 값을 더합니다.
          int currentNumberSuccesses = data['numberSuccesses'] ?? 0;
          int updatedNumberSuccesses = currentNumberSuccesses +
              missionRecord.numberSuccesses; // 또는 적절한 로직으로 값을 증가시킵니다.

          //total distance가져와서 합산
          double currentTotalDistance = double.parse(data['distance']);
          currentTotalDistance += double.parse(missionRecord.distance);
          String updatedDistance = currentTotalDistance.toString();

          int currentLevel = data['level'] ?? 0;
          int updatedLevel = currentLevel + missionRecord.missionLevel;

          // 변경된 데이터로 문서를 업데이트합니다.
          await firestore
              .collection("Users")
              .doc(user!.uid)
              .collection("Mission")
              .doc("distance5")
              .update({'numberSuccesses': updatedNumberSuccesses, 'distance': updatedDistance, 'level': updatedLevel});
        } else {
          // 문서가 존재하지 않으면, 새 문서를 생성합니다.
          await firestore
              .collection("Users")
              .doc(user!.uid)
              .collection("Mission")
              .doc("distance5")
              .set(missionRecord.toJson()); // 초기 값으로 1 설정
        }
      }

      if (missionData.distance == '10km') {
        if (double.parse(formattedDistance) >= 10.0){
          missionRecord.numberSuccesses = 1;
        }
        DocumentSnapshot snapshot = await firestore
            .collection("Users")
            .doc(user!.uid)
            .collection("Mission")
            .doc("distance10")
            .get();

        if (snapshot.exists) {
          // 문서가 존재하면, 기존 데이터를 가져옵니다.
          var data = snapshot.data() as Map<String, dynamic>;

          // 'numberSuccesses' 값을 가져와서 새로운 값을 더합니다.
          int currentNumberSuccesses = data['numberSuccesses'] ?? 0;
          int updatedNumberSuccesses = currentNumberSuccesses + missionRecord.numberSuccesses; // 또는 적절한 로직으로 값을 증가시킵니다.

          //total distance가져와서 합산
          double currentTotalDistance = double.parse(data['distance']);
          currentTotalDistance += double.parse(missionRecord.distance);
          String updatedDistance = currentTotalDistance.toString();

          int currentLevel = data['level'] ?? 0;
          int updatedLevel = currentLevel + missionRecord.missionLevel;

          // 변경된 데이터로 문서를 업데이트합니다.
          await firestore
              .collection("Users")
              .doc(user!.uid)
              .collection("Mission")
              .doc("distance10")
              .update({'numberSuccesses': updatedNumberSuccesses, 'distance': updatedDistance, 'level' : updatedLevel});
        } else {
          // 문서가 존재하지 않으면, 새 문서를 생성합니다.
          await firestore
              .collection("Users")
              .doc(user!.uid)
              .collection("Mission")
              .doc("distance10")
              .set(missionRecord.toJson()); // 초기 값으로 1 설정
        }
      }

      if (missionData.time == '15분') {
        if (totalMinutes >= 15){
          missionRecord.numberSuccesses = 1;
        }
        DocumentSnapshot snapshot = await firestore
            .collection("Users")
            .doc(user!.uid)
            .collection("Mission")
            .doc("time15")
            .get();

        if (snapshot.exists) {
          // 문서가 존재하면, 기존 데이터를 가져옵니다.
          var data = snapshot.data() as Map<String, dynamic>;

          // 'numberSuccesses' 값을 가져와서 새로운 값을 더합니다.
          int currentNumberSuccesses = data['numberSuccesses'] ?? 0;
          int updatedNumberSuccesses = currentNumberSuccesses + missionRecord.numberSuccesses; // 또는 적절한 로직으로 값을 증가시킵니다.

          //total distance가져와서 합산
          double currentTotalDistance = double.parse(data['distance']);
          currentTotalDistance += double.parse(missionRecord.distance);
          String updatedDistance = currentTotalDistance.toString();

          int currentLevel = data['level'] ?? 0;
          int updatedLevel = currentLevel + missionRecord.missionLevel;

          // 변경된 데이터로 문서를 업데이트합니다.
          await firestore
              .collection("Users")
              .doc(user!.uid)
              .collection("Mission")
              .doc("time15")
              .update({'numberSuccesses': updatedNumberSuccesses, 'distance': updatedDistance, 'level' : updatedLevel});
        } else {
          // 문서가 존재하지 않으면, 새 문서를 생성합니다.
          await firestore
              .collection("Users")
              .doc(user!.uid)
              .collection("Mission")
              .doc("time15")
              .set(missionRecord.toJson()); // 초기 값으로 1 설정
        }
      }

      if (missionData.time == '30분') {
        if (totalMinutes >= 30){
          missionRecord.numberSuccesses = 1;
        }
        DocumentSnapshot snapshot = await firestore
            .collection("Users")
            .doc(user!.uid)
            .collection("Mission")
            .doc("time30")
            .get();

        if (snapshot.exists) {
          // 문서가 존재하면, 기존 데이터를 가져옵니다.
          var data = snapshot.data() as Map<String, dynamic>;

          // 'numberSuccesses' 값을 가져와서 새로운 값을 더합니다.
          int currentNumberSuccesses = data['numberSuccesses'] ?? 0;
          int updatedNumberSuccesses = currentNumberSuccesses + missionRecord.numberSuccesses; // 또는 적절한 로직으로 값을 증가시킵니다.

          //total distance가져와서 합산
          double currentTotalDistance = double.parse(data['distance']);
          currentTotalDistance += double.parse(missionRecord.distance);
          String updatedDistance = currentTotalDistance.toString();

          int currentLevel = data['level'] ?? 0;
          int updatedLevel = currentLevel + missionRecord.missionLevel;

          // 변경된 데이터로 문서를 업데이트합니다.
          await firestore
              .collection("Users")
              .doc(user!.uid)
              .collection("Mission")
              .doc("time30")
              .update({'numberSuccesses': updatedNumberSuccesses, 'distance': updatedDistance, 'level' : updatedLevel});
        } else {
          // 문서가 존재하지 않으면, 새 문서를 생성합니다.
          await firestore
              .collection("Users")
              .doc(user!.uid)
              .collection("Mission")
              .doc("time30")
              .set(missionRecord.toJson()); // 초기 값으로 1 설정
        }
      }

      if (missionData.time == '1시간') {
        if (totalMinutes >= 60){
          missionRecord.numberSuccesses = 1;
        }
        DocumentSnapshot snapshot = await firestore
            .collection("Users")
            .doc(user!.uid)
            .collection("Mission")
            .doc("time60")
            .get();

        if (snapshot.exists) {
          // 문서가 존재하면, 기존 데이터를 가져옵니다.
          var data = snapshot.data() as Map<String, dynamic>;

          // 'numberSuccesses' 값을 가져와서 새로운 값을 더합니다.
          int currentNumberSuccesses = data['numberSuccesses'] ?? 0;
          int updatedNumberSuccesses = currentNumberSuccesses + missionRecord.numberSuccesses; // 또는 적절한 로직으로 값을 증가시킵니다.

          //total distance가져와서 합산
          double currentTotalDistance = double.parse(data['distance']);
          currentTotalDistance += double.parse(missionRecord.distance);
          String updatedDistance = currentTotalDistance.toString();

          int currentLevel = data['level'] ?? 0;
          int updatedLevel = currentLevel + missionRecord.missionLevel;

          // 변경된 데이터로 문서를 업데이트합니다.
          await firestore
              .collection("Users")
              .doc(user!.uid)
              .collection("Mission")
              .doc("time60")
              .update({'numberSuccesses': updatedNumberSuccesses, 'distance': updatedDistance, 'level' : updatedLevel});
        } else {
          // 문서가 존재하지 않으면, 새 문서를 생성합니다.
          await firestore
              .collection("Users")
              .doc(user!.uid)
              .collection("Mission")
              .doc("time60")
              .set(missionRecord.toJson()); // 초기 값으로 1 설정
        }
      }

      if (missionData.pace == '630') {
        if (paceMinutes < 6 || (paceMinutes == 6 && paceSeconds <= 30)){
          missionRecord.numberSuccesses = 1;
        }
        DocumentSnapshot snapshot = await firestore
            .collection("Users")
            .doc(user!.uid)
            .collection("Mission")
            .doc("pace630")
            .get();

        if (snapshot.exists) {
          // 문서가 존재하면, 기존 데이터를 가져옵니다.
          var data = snapshot.data() as Map<String, dynamic>;

          // 'numberSuccesses' 값을 가져와서 새로운 값을 더합니다.
          int currentNumberSuccesses = data['numberSuccesses'] ?? 0;
          int updatedNumberSuccesses = currentNumberSuccesses + missionRecord.numberSuccesses; // 또는 적절한 로직으로 값을 증가시킵니다.

          //total distance가져와서 합산
          double currentTotalDistance = double.parse(data['distance']);
          currentTotalDistance += double.parse(missionRecord.distance);
          String updatedDistance = currentTotalDistance.toString();

          int currentLevel = data['level'] ?? 0;
          int updatedLevel = currentLevel + missionRecord.missionLevel;

          // 변경된 데이터로 문서를 업데이트합니다.
          await firestore
              .collection("Users")
              .doc(user!.uid)
              .collection("Mission")
              .doc("pace630")
              .update({'numberSuccesses': updatedNumberSuccesses, 'distance': updatedDistance, 'level' : updatedLevel});
        } else {
          // 문서가 존재하지 않으면, 새 문서를 생성합니다.
          await firestore
              .collection("Users")
              .doc(user!.uid)
              .collection("Mission")
              .doc("pace630")
              .set(missionRecord.toJson()); // 초기 값으로 1 설정
        }
      }

      if (missionData.pace == '600') {
        if (paceMinutes < 6 || (paceMinutes == 6 && paceSeconds == 0)){
          missionRecord.numberSuccesses = 1;
        }
        DocumentSnapshot snapshot = await firestore
            .collection("Users")
            .doc(user!.uid)
            .collection("Mission")
            .doc("pace600")
            .get();

        if (snapshot.exists) {
          // 문서가 존재하면, 기존 데이터를 가져옵니다.
          var data = snapshot.data() as Map<String, dynamic>;

          // 'numberSuccesses' 값을 가져와서 새로운 값을 더합니다.
          int currentNumberSuccesses = data['numberSuccesses'] ?? 0;
          int updatedNumberSuccesses = currentNumberSuccesses + missionRecord.numberSuccesses; // 또는 적절한 로직으로 값을 증가시킵니다.

          //total distance가져와서 합산
          double currentTotalDistance = double.parse(data['distance']);
          currentTotalDistance += double.parse(missionRecord.distance);
          String updatedDistance = currentTotalDistance.toString();

          int currentLevel = data['level'] ?? 0;
          int updatedLevel = currentLevel + missionRecord.missionLevel;

          // 변경된 데이터로 문서를 업데이트합니다.
          await firestore
              .collection("Users")
              .doc(user!.uid)
              .collection("Mission")
              .doc("pace600")
              .update({'numberSuccesses': updatedNumberSuccesses, 'distance': updatedDistance, 'level' : updatedLevel});
        } else {
          // 문서가 존재하지 않으면, 새 문서를 생성합니다.
          await firestore
              .collection("Users")
              .doc(user!.uid)
              .collection("Mission")
              .doc("pace600")
              .set(missionRecord.toJson()); // 초기 값으로 1 설정
        }
      }

      if (missionData.pace == '550') {
        if (paceMinutes < 5 || (paceMinutes == 6 && paceSeconds <= 50)){
          missionRecord.numberSuccesses = 1;
        }
        DocumentSnapshot snapshot = await firestore
            .collection("Users")
            .doc(user!.uid)
            .collection("Mission")
            .doc("pace550")
            .get();

        if (snapshot.exists) {
          // 문서가 존재하면, 기존 데이터를 가져옵니다.
          var data = snapshot.data() as Map<String, dynamic>;

          // 'numberSuccesses' 값을 가져와서 새로운 값을 더합니다.
          int currentNumberSuccesses = data['numberSuccesses'] ?? 0;
          int updatedNumberSuccesses = currentNumberSuccesses + missionRecord.numberSuccesses; // 또는 적절한 로직으로 값을 증가시킵니다.

          //total distance가져와서 합산
          double currentTotalDistance = double.parse(data['distance']);
          currentTotalDistance += double.parse(missionRecord.distance);
          String updatedDistance = currentTotalDistance.toString();

          int currentLevel = data['level'] ?? 0;
          int updatedLevel = currentLevel + missionRecord.missionLevel;

          // 변경된 데이터로 문서를 업데이트합니다.
          await firestore
              .collection("Users")
              .doc(user!.uid)
              .collection("Mission")
              .doc("pace550")
              .update({'numberSuccesses': updatedNumberSuccesses, 'distance': updatedDistance, 'level' : updatedLevel});
        } else {
          // 문서가 존재하지 않으면, 새 문서를 생성합니다.
          await firestore
              .collection("Users")
              .doc(user!.uid)
              .collection("Mission")
              .doc("pace550")
              .set(missionRecord.toJson()); // 초기 값으로 1 설정
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedTime = _formatTime(_stopwatch.elapsedMilliseconds);
    // 미터 단위의 거리를 킬로미터 단위로 변환하고, 소수점 둘째 자리까지 표시
    String formattedDistance = (_totalDistance / 1000).toStringAsFixed(2) + ' km';
    String pace = _calculatePace(_totalDistance, _stopwatch.elapsedMilliseconds);

    return Scaffold(
      appBar: AppBar(
        title: Text('Running'),
      ),
      body: Column(
        children: [
          Container(
            height: 120, // 컨테이너 높이 조정
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Time: $formattedTime'),
                SizedBox(height: 4.0),
                Text('Distance: $formattedDistance'), // 수정된 거리 표시
                SizedBox(height: 4.0),
                Text('Pace: $pace'), // 페이스 표시
              ],
            ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                rootBundle.loadString('assets/map/mapstyle.json').then((String mapStyle) {
                  controller.setMapStyle(mapStyle);
                  _controller = controller;
                });
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  _currentLocation?.latitude ?? 0.0,
                  _currentLocation?.longitude ?? 0.0,
                ),
                zoom: 17.0,
              ),
              markers: Set.from(_markers),
              polylines: Set.from([_polyline]),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            ),
          ),
          Container(
            height: 110,
            padding: EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _stopRecording,
              child: Text('Stop Recording'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }

}

class RunData {
  final String duration;
  final String distance;
  final DateTime timestamp;
  final String pace;
  final List<Map<String, double>> routePoints;

  RunData({
    required this.duration,
    required this.distance,
    required this.pace,
    required this.timestamp,
    required this.routePoints,
  });

  Map<String, dynamic> toJson() {
    return {
      'duration': duration,
      'distance': distance,
      'timestamp': timestamp,
      'route': routePoints,
      'pace' : pace,
    };
  }
}

class MissionRecord {
  String distance;
  int numberSuccesses;
  int missionLevel;

  MissionRecord({
    required this.distance,
    required this.numberSuccesses,
    required this.missionLevel,
  });

  Map<String, dynamic> toJson() {
    return {
      'distance': distance,
      'numberSuccesses': numberSuccesses,
      'level' : missionLevel,
    };
  }
}