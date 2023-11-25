import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapScreen extends StatefulWidget {
  final LocationData? currentLocation;

  MapScreen({Key? key, this.currentLocation}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState(currentLocation: currentLocation);
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  List<Marker> _markers = [];
  Polyline _polyline = Polyline(polylineId: PolylineId("runningRoute"));
  LocationData? _currentLocation;
  double _totalDistance = 0.0;
  Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  bool _isRecording = true;

  _MapScreenState({LocationData? currentLocation}) {
    _currentLocation = currentLocation;
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocationAndStartRecording();
  }

  Future<LocationData> _getCurrentLocation() async {
    var location = Location();
    return await location.getLocation();
  }

  Future<void> _getCurrentLocationAndStartRecording() async {
    LocationData locationData = await _getCurrentLocation();
    setState(() {
      _currentLocation = locationData;
    });
    _startRecording();
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
                zoom: 20,
              ),
              markers: Set.from(_markers),
              polylines: Set.from([_polyline]),
            ),
          ),
          Container(
            height: 110, // Adjust height as needed
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('Current Running Route Here'),
                SizedBox(height: 8.0),
                _isRecording
                    ? ElevatedButton(
                  onPressed: () {
                    _stopRecording();
                    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                  },
                  child: Text('Stop Recording'),
                )
                    : Text('Recording Stopped'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _startRecording() {
    if (_currentLocation != null) {
      // Add start marker to the markers list
      _markers.add(
        Marker(
          markerId: MarkerId('startLocation'),
          position: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
          infoWindow: InfoWindow(title: 'Start Location'),
        ),
      );

      // Move the camera to the current location
      _controller?.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
        ),
      );
    }

    _stopwatch.start();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  void _stopRecording() {
    _stopwatch.stop();
    _timer?.cancel();
    setState(() {
      _isRecording = false;
    });
    _showResultDialog();
    _uploadDataToFirestore();
  }

  void _uploadDataToFirestore() async {

    // 여기에 Firebase 초기화가 되어있다고 가정하고 Firestore에 데이터를 추가하는 부분을 작성합니다.
    if (_currentLocation != null) {
      String formattedTime = _formatTime(_stopwatch.elapsedMilliseconds);

      // Firestore collection에 데이터 추가
      await FirebaseFirestore.instance.collection('running_records').add({
        'duration': formattedTime,
        'distance': _totalDistance.toStringAsFixed(2),
        'timestamp': DateTime.now(),
      });
      print('Data uploaded to Firestore!');
    }
  }
  void _showResultDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Run Summary'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Duration: ${_formatTime(_stopwatch.elapsedMilliseconds)}'),
              SizedBox(height: 8.0),
              Text('Distance: ${_totalDistance.toStringAsFixed(2)} meters'),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                },
                child: Text('Save & Close'),
              ),
            ],
          ),
        );
      },
    );
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
}