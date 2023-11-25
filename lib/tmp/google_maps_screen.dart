import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  List<Marker> _markers = [];
  Polyline _polyline = Polyline(polylineId: PolylineId("runningRoute"));
  LocationData? _currentLocation;
  double _totalDistance = 0.0;
  Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startRecording();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Running Route Map'),
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
                target: LatLng(0, 0),
                zoom: 15,
              ),
              markers: Set.from(_markers),
              polylines: Set.from([_polyline]),
            ),
          ),
          Container(
            height: 100, // Adjust height as needed
            padding: EdgeInsets.all(16.0),
            child: Text('Current Running Route Here'),
          ),
        ],
      ),
    );
  }

  void _startRecording() {
    _stopwatch.start();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {});
    });
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

  void _updateRunningRoute(LocationData locationData) {
    LatLng newPosition = LatLng(locationData.latitude!, locationData.longitude!);
    _totalDistance += _calculateDistance(_currentLocation, locationData);
    _currentLocation = locationData;

    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('location'),
          position: newPosition,
          infoWindow: InfoWindow(title: 'Current Location'),
        ),
      );

      _polyline.points.add(newPosition);
      _controller?.animateCamera(CameraUpdate.newLatLng(newPosition));
    });
  }

  double _calculateDistance(LocationData? from, LocationData to) {
    if (from == null) return 0.0;

    double earthRadius = 6371000.0; // in meters
    double dLat = _degreesToRadians(to.latitude! - from.latitude!);
    double dLon = _degreesToRadians(to.longitude! - from.longitude!);

    double a = pow(sin(dLat / 2), 2) +
        cos(_degreesToRadians(from.latitude!)) *
            cos(_degreesToRadians(to.latitude!)) *
            pow(sin(dLon / 2), 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
