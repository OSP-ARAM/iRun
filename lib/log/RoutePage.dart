import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RoutePage extends StatefulWidget {
  final List<dynamic> routeData;

  RoutePage({Key? key, required this.routeData}) : super(key: key);

  @override
  _RoutePageState createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  late GoogleMapController _mapController;
  Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _createPolylines();
  }

  void _createPolylines() {
    polylineCoordinates = widget.routeData.map((point) {
      Map<String, dynamic> latLng = point as Map<String, dynamic>;
      double lat = (latLng['latitude'] as num).toDouble(); // dynamic에서 double로 안전하게 변환
      double lng = (latLng['longitude'] as num).toDouble(); // dynamic에서 double로 안전하게 변환
      return LatLng(lat, lng);
    }).toList();

    // 시작점과 종료점 마커 추가
    Marker startMarker = Marker(
      markerId: MarkerId('start'),
      position: polylineCoordinates.first, // 첫 번째 좌표를 시작점으로
      infoWindow: InfoWindow(title: 'Start'),
    );

    Marker endMarker = Marker(
      markerId: MarkerId('end'),
      position: polylineCoordinates.last, // 마지막 좌표를 종료점으로
      infoWindow: InfoWindow(title: 'End'),
    );

    setState(() {
      _polylines.add(
        Polyline(
          polylineId: PolylineId('route'),
          visible: true,
          points: polylineCoordinates,
          color: Colors.red,
          width: 8,
        ),
      );

      _markers.add(startMarker);
      _markers.add(endMarker);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Running Route'),
      ),
      body: GoogleMap(
        onMapCreated: (controller) {
          _mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: polylineCoordinates.isNotEmpty
              ? polylineCoordinates.first
              : LatLng(0, 0),
          zoom: 15,
        ),
        polylines: _polylines,
        markers: _markers, // 여기에 마커 세트 추가
        myLocationEnabled: true,
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
