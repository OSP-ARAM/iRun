import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:irun/login/login_api.dart';
import 'package:irun/mission/mission_page.dart';
import 'package:irun/music/music_page.dart';
import 'package:irun/option/tts_setting_page.dart';
import 'package:irun/record/firestore_service.dart';
import 'package:irun/record/stop_record_page.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final User? user = auth.currentUser;

  GoogleMapController? _controller;
  final List<Marker> _markers = [];
  Polyline _polyline = const Polyline(
    polylineId: PolylineId("runningRoute"),
    color: Colors.blue,
    points: [],
  );
  Position? _currentLocation;
  double _totalDistance = 0.0;
  final Stopwatch _stopwatch = Stopwatch();
  StreamSubscription<Position>? _positionStreamSubscription;

  FlutterTts tts = FlutterTts();
  bool isSetted = false;

  Timer? _timer;

  LatLng? currentPosition;

  bool isrunningflag = false;

  @override
  void initState() {
    super.initState();
    _initTTS();
    _getCurrentLocationAndStartRecording();
    isrunningflag = true;
  }

  Future<void> _pauseRecording() async {
    setState(() {
      isrunningflag = false; // 러닝 재개
    });

    _stopwatch.stop();
    _positionStreamSubscription?.pause();
    _timer?.cancel();

    // 경로 데이터 생성
    List<Map<String, double>> routeData = _markers.map((marker) {
      return {
        'latitude': marker.position.latitude,
        'longitude': marker.position.longitude,
      };
    }).toList();

    // StopMapScreen으로 경로 데이터 전달
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StopMapScreen(
          formattedTime: _formatTime(_stopwatch.elapsedMilliseconds),
          pace: _calculatePace(_totalDistance, _stopwatch.elapsedMilliseconds),
          routeData: routeData, // 경로 데이터 전달
          currentLocation: _currentLocation,
          markers: _markers,
          stopwatch: _stopwatch,
          totalDistance: _totalDistance,
          isRunning: isrunningflag,
        ),
      ),
    );

    if (result == true) {
      resumeRunning();
    }
  }

  void resumeRunning() {
    setState(() {
      isrunningflag = true;
      _resumeRecording();
    });
  }

  void _resumeRecording() {
    _stopwatch.start();

    var locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high, distanceFilter: 1);

    if (_positionStreamSubscription == null) {
      _positionStreamSubscription =
          Geolocator.getPositionStream(locationSettings: locationSettings)
              .listen((Position position) {
        _updateCameraPosition(position);
        if (isrunningflag) {
          _updatePolyline(position);
        }
      });
    } else {
      _positionStreamSubscription?.resume();
    }

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {}); // 매 초마다 화면을 새로 고침
    });
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
    Position locationData = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentLocation = locationData;
      _updateCameraPosition(_currentLocation!);
      _markers.add(
        Marker(
          markerId: const MarkerId('startLocation'),
          position:
              LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
          infoWindow: const InfoWindow(title: 'Start Location'),
          visible: false,
        ),
      );
    });
    _startRecording();
  }

  void _startRecording() {
    _stopwatch.start();
    var locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high, distanceFilter: 1);

    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      _updateCameraPosition(position);
      _updatePolyline(position);
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {}); // This will trigger a rebuild every second
    });
  }

  void _stopRecording() async {
    _stopwatch.stop();
    _positionStreamSubscription?.cancel();
    _timer?.cancel();

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

    double caloriesBurned = calculateCalories(
        weight!, height!, age!, gender, _totalDistance / 1000); // m를 km로 변환

    // FirestoreService를 사용하여 데이터 저장
    final missionData = Provider.of<MissionData>(context, listen: false);

    await FirestoreService.uploadDataToFirestore(
      user: user!,
      currentLocation: _currentLocation!,
      markers: _markers,
      stopwatch: _stopwatch,
      totalDistance: _totalDistance,
      missionData: missionData,
      caloriesBurned: caloriesBurned,
    );

    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  void _updatePolyline(Position position) {
    if (isrunningflag) {
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
              polylineId: const PolylineId("runningRoute"),
              color: Colors.blue,
              points: _markers.map((marker) => marker.position).toList(),
            );

            if (_totalDistance >= 1000 * (_markers.length - 1)) {
              _speak(
                  '현재, ${(_totalDistance / 1000).toStringAsFixed(1)} 킬로미터 달렸습니다.');
            }
          }
        }
      });
    }
  }

  void _updateCameraPosition(Position position) {
    setState(() {
      currentPosition = LatLng(position.latitude, position.longitude);
    });
    _controller?.animateCamera(
      CameraUpdate.newLatLng(currentPosition!),
    );
  }

  double _calculateDistance(double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) {
    const int earthRadius = 6371000;
    double latDiff = _degreesToRadians(endLatitude - startLatitude);
    double lonDiff = _degreesToRadians(endLongitude - startLongitude);
    double a = (sin(latDiff / 2) * sin(latDiff / 2)) +
        (cos(_degreesToRadians(startLatitude)) *
            cos(_degreesToRadians(endLatitude)) *
            sin(lonDiff / 2) *
            sin(lonDiff / 2));
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
    String formattedTime = _formatTime(_stopwatch.elapsedMilliseconds);
    String formattedDistance = '${_totalDistance.toStringAsFixed(0)} m';
    String pace =
        _calculatePace(_totalDistance, _stopwatch.elapsedMilliseconds);

    // 러닝 탭에서 AudioPlayerManager의 인스턴스를 얻는 방법
    AudioPlayer? audioPlayer;
    if (AudioPlayerManager.isInstanceCreated) {
      audioPlayer = AudioPlayerManager.instance?.audioPlayer;
    }


    return Scaffold(
      backgroundColor: Colors.yellow,
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Time: $formattedTime',
                    style: const TextStyle(
                        fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Distance: $formattedDistance',
                    style: const TextStyle(
                        fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Pace: $pace',
                    style: const TextStyle(
                        fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          // MusicPlayerNavigationBar를 여기에 배치
          if (audioPlayer != null)
            MusicPlayerNavigationBar(audioPlayer: audioPlayer),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton.large(
                  onPressed: _pauseRecording,
                    child: Icon(
                        Icons.pause,
                        color: Colors.white,
                        size: 70),
                    backgroundColor: Colors.black, // Use the appropriate color
                    heroTag: 'resume', // Required if multiple FABs are used
                  ),
              ],
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
