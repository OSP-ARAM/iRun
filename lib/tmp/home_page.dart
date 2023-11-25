import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:irun/record/record_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GoogleMapController? _controller;
  LocationData? _currentLocation;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation().then((locationData) {
      setState(() {
        _currentLocation = locationData;
      });
      _moveToCurrentLocation();
    });
  }

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
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.2),
                ),
              ),
              alignment: Alignment.center,
              child: _currentLocation == null
                  ? Text(
                'No location chosen',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyText2!
                    .copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onBackground),
              )
                  : GoogleMap(
                onMapCreated: (controller) {
                  setState(() {
                    _controller = controller;
                  });
                },
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    _currentLocation!.latitude!,
                    _currentLocation!.longitude!,
                  ),
                  zoom: 15,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId('currentLocation'),
                    position: LatLng(
                      _currentLocation!.latitude!,
                      _currentLocation!.longitude!,
                    ),
                    infoWindow: InfoWindow(title: 'Current Location'),
                  ),
                },
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(width: 16.0), // Add spacing between buttons
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to the map screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.map),
                    label: const Text('Start Recording'),
                  ),
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
