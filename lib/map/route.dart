import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GoogleMapController? _controller;
  LocationData? _currentLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Running Route Tracker'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                ),
              ),
              alignment: Alignment.center,
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
                markers: _currentLocation != null
                    ? {
                  Marker(
                    markerId: MarkerId('currentLocation'),
                    position: LatLng(
                      _currentLocation!.latitude!,
                      _currentLocation!.longitude!,
                    ),
                    infoWindow: InfoWindow(title: 'Current Location'),
                  ),
                }
                    : {},
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    LocationData locationData = await _getCurrentLocation();
                    setState(() {
                      _currentLocation = locationData;
                    });
                    _moveToCurrentLocation();
                  },
                  icon: const Icon(Icons.location_on),
                  label: const Text('Get Current Location'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapScreen(currentLocation: _currentLocation),
                      ),
                    );
                  },
                  icon: const Icon(Icons.map),
                  label: const Text('Start Recording'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<LocationData> _getCurrentLocation() async {
    var location = Location();
    return await location.getLocation();
  }

  void _moveToCurrentLocation() {
    if (_controller != null && _currentLocation != null) {
      _controller!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(
            _currentLocation!.latitude!,
            _currentLocation!.longitude!,
          ),
        ),
      );
    }
  }
}

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
                  onPressed: _stopRecording,
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