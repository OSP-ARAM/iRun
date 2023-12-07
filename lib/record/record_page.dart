import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
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
  Timer? _timer;

  LatLng? currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocationAndStartRecording();
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
      return '0.00 min/km';
    }
    double minutes = milliseconds / 60000.0;
    double distanceKm = distance / 1000.0;
    double pace = minutes / distanceKm;
    return pace.toStringAsFixed(2) + ' min/km';
  }

  void _uploadDataToFirestore() async {
    if (_currentLocation != null && _markers.isNotEmpty) {
      String formattedTime = _formatTime(_stopwatch.elapsedMilliseconds);

      String formattedDistance = (_totalDistance / 1000).toStringAsFixed(2);

      List<Map<String, double>> routePoints = _markers.map((marker) {
        return {
          'latitude': marker.position.latitude,
          'longitude': marker.position.longitude
        };
      }).toList();

      await FirebaseFirestore.instance.collection('running_records').add({
        'duration': formattedTime,
        'distance': formattedDistance,
        'timestamp': DateTime.now(),
        'route': routePoints,
      });
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
