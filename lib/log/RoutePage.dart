import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RoutePage extends StatefulWidget {
  final Map<String, dynamic> routeData;

  const RoutePage({Key? key, required this.routeData}) : super(key: key);

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
    List<dynamic> coordinatesListDynamic = widget.routeData['route'];

    // List<dynamic>을 List<Map<String, dynamic>>으로 변환
    List<Map<String, dynamic>> coordinatesList =
    coordinatesListDynamic.cast<Map<String, dynamic>>();

    print(coordinatesList);

    polylineCoordinates = coordinatesList.map((point) {
      double lat = (point['latitude'] as num).toDouble();
      double lng = (point['longitude'] as num).toDouble();
      return LatLng(lat, lng);
    }).toList();

    // 시작점과 종료점 마커 추가
    Marker startMarker = Marker(
      markerId: MarkerId('start'),
      position: polylineCoordinates.first,
      infoWindow: InfoWindow(title: 'Start'),
    );

    Marker endMarker = Marker(
      markerId: MarkerId('end'),
      position: polylineCoordinates.last,
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
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              rootBundle
                  .loadString('assets/map/mapstyle.json')
                  .then((String mapStyle) {
                controller.setMapStyle(mapStyle);
                _mapController = controller;
              });
            },
            initialCameraPosition: CameraPosition(
              target: polylineCoordinates.isNotEmpty
                  ? polylineCoordinates.first
                  : LatLng(0, 0),
              zoom: 15,
            ),
            polylines: _polylines,
            markers: _markers,
            myLocationEnabled: true,
            zoomControlsEnabled: false,
          ),
          Positioned(
            top: 20, // 상단 여백 조정
            left: 20, // 좌측 여백 조정
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                  '거리: ${widget.routeData['distance']} km'), // 여기에 텍스트 내용 추가
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Text('시간: ${widget.routeData['duration']}'),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Text('페이스: ${widget.routeData['pace']}'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}