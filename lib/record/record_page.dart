import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:irun/option/tts_setting_page.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  List<Marker> _markers = [];
  Polyline _polyline = Polyline(polylineId: PolylineId("runningRoute"), color: Colors.blue, points: []);
  LocationData? _currentLocation;
  double _totalDistance = 0.0;
  Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  int isStart = 0;
  int nextGoal = 0;

  bool IsSetted = false;

  final TTSSetting ttsSetting = TTSSetting(); // 여기서 인스턴스 생성

  final FlutterTts tts = FlutterTts();
  String distanceNotification = '';

  @override
  void initState() {
    super.initState();
    _getCurrentLocationAndStartRecording();
    _setupTTS();
    fetchSettings();
    IsSetted = TTSSetting.getIsSetted();
  }

  Future<void> _getCurrentLocationAndStartRecording() async {
    LocationData locationData = await _getCurrentLocation();
    setState(() {
      _currentLocation = locationData;
      _markers.add(
        Marker(
          markerId: MarkerId('startLocation'),
          position: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
          infoWindow: InfoWindow(title: 'Start Location'),
          visible: false,
        ),
      );
      _controller?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
          18,
        ),
      );
    });
    _startRecording();
  }

  Future<LocationData> _getCurrentLocation() async {
    var location = Location();
    return await location.getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Running'),
      ),
      body: Column(
        children: [
          Container(
            height: 100, // Adjust height as needed
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Time: ${_formatTime(_stopwatch.elapsedMilliseconds)}'),
                SizedBox(height: 8.0),
                Text('Distance: ${_totalDistance.toStringAsFixed(2)} meters'),
              ],
            ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: (controller) {
                setState(() {
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
              myLocationButtonEnabled: true,
            ),
          ),
          Container(
            height: 110, // Adjust height as needed
            padding: EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                _stopRecording();
                // Navigate to another screen or perform an action
              },
              child: Text('Stop Recording'),
            ),
          ),
        ],
      ),
    );
  }

  void _startRecording() async {
    _stopwatch.start();
    _currentLocation = await _getCurrentLocation();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _updatePolyline();
      setState(() {}); // Refreshes the UI to update time and distance
    });
  }

  void _stopRecording() {
    _stopwatch.stop();
    _timer?.cancel();
    // Upload recorded data or perform other actions
    _uploadDataToFirestore();
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  void _updatePolyline() async {
    LocationData locationData = await _getCurrentLocation();
    if (locationData != null) {
      setState(() {
        _currentLocation = locationData;
        _markers.add(
          Marker(
            markerId: MarkerId('point${_markers.length}'),
            position: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
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

          _totalDistance += distance;

          _polyline = _polyline.copyWith(
            pointsParam: _markers.map((marker) => marker.position).toList(),
          );

          print(IsSetted);

          if(IsSetted)
          {
            if (_totalDistance == 0 && isStart == 0) {
              tts.speak('러닝을 시작합니다. 힘내세요!');
              isStart = 1;
              nextGoal = 100;

            } else if (isStart == 1 && _totalDistance >= nextGoal) {
              _speakDistanceNotification(); // TTS 호출
              nextGoal += 100;
            }
          }
        }
      }
      );
    }
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

  void _uploadDataToFirestore() async {
    if (_currentLocation != null) {
      String formattedTime = _formatTime(_stopwatch.elapsedMilliseconds);
      await FirebaseFirestore.instance.collection('running_records').add({
        'duration': formattedTime,
        'distance': _totalDistance.toStringAsFixed(2),
        'timestamp': DateTime.now(),
      });
      print('Data uploaded to Firestore!');
    }
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

  void fetchSettings() async {
    await TTSSetting.loadSettings();
  }
  double getPitch() {
    return TTSSetting.getPitch();
  }

  double getVolume() {
    return TTSSetting.getVolume();
  }

  Map<String, String> getVoice() {
    return TTSSetting.getVoice();
  }

  double getRate() {
    return TTSSetting.getRate();
  }

  bool getIsSetted() {
    return TTSSetting.getIsSetted();
  }

  void _setupTTS() async{

    await tts.setPitch(getPitch());
    await tts.setVolume(getVolume());
    await tts.setVoice(getVoice());
    await tts.setSpeechRate(getRate());
  }
  // TTS로 거리 알림을 위한 함수
  void _speakDistanceNotification() async {
    String ttsdistance = _totalDistance.toStringAsFixed(0);
    await tts.speak('현재 $ttsdistance 미터 달렸습니다. 힘내세요!'); // 뛴 거리를 TTS로 알림
  }
}


