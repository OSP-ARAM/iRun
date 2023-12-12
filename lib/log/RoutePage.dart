import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:irun/login/login_api.dart';

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
  final User? user = auth.currentUser;



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
      markerId: const MarkerId('start'),
      position: polylineCoordinates.first,
      infoWindow: const InfoWindow(title: 'Start'),
    );

    Marker endMarker = Marker(
      markerId: const MarkerId('end'),
      position: polylineCoordinates.last,
      infoWindow: const InfoWindow(title: 'End'),
    );

    setState(() {
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
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
    String success1;
    String success2;
    String success3;

    Timestamp timestamp = widget.routeData['timestamp'] as Timestamp;
    DateTime dateTime = timestamp.toDate();
    String formattedDateTime = DateFormat('yyy/MM/dd HH:mm').format(dateTime);

    Map<String, dynamic> data = widget.routeData['successfulMissions'];
    Map<String, List<dynamic>> successfulMissions = {};

    data.forEach((key, value) {
      successfulMissions[key] = value.cast<dynamic>();
    });

    if (successfulMissions['거리'] != null) {
      success1 = successfulMissions['거리']!.join(',');
    } else {
      success1 = 'X';
    }

    if (successfulMissions['시간'] != null) {
      success2 = successfulMissions['시간']!.join(',');
    } else {
      success2 = 'X';
    }

    if (successfulMissions['페이스'] != null) {
      success3 = successfulMissions['페이스']!.join(',');
    } else {
      success3 = 'X';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('상세 기록'),
        backgroundColor: Colors.yellow, // AppBar 색상 변경
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 기존의 경로 정보 표시 카드
            Card(
              color: Colors.white,
              elevation: 4,
              margin: const EdgeInsets.all(8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      '${formattedDateTime}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 300, // Google Map의 높이 지정
                      child: GoogleMap(
                        onMapCreated: (GoogleMapController controller) {
                          _mapController = controller;
                          rootBundle.loadString('assets/map/mapstyle.json').then((String mapStyle) {
                            controller.setMapStyle(mapStyle);

                            if (polylineCoordinates.isNotEmpty) {
                              LatLngBounds bounds = _boundsFromLatLngList(polylineCoordinates);
                              CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 50);
                              controller.animateCamera(cameraUpdate);
                            }
                          });
                        },
                        initialCameraPosition: CameraPosition(
                          target: polylineCoordinates.isNotEmpty
                              ? polylineCoordinates.first
                              : const LatLng(0, 0),
                          zoom: 14,
                        ),
                        polylines: _polylines,
                        markers: _markers,
                        myLocationEnabled: false,
                        zoomControlsEnabled: false,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // 시간, 페이스, 거리 정보 표시
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildInfoCard('시간', '${widget.routeData['duration'].substring(1)}', Icons.access_time),
                        _buildInfoCard('페이스', '${widget.routeData['pace']}', Icons.directions_run),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // 두 번째 줄: 거리, 칼로리 정보
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildInfoCard('거리', '${widget.routeData['distance']}km', Icons.map),
                        _buildInfoCard('칼로리', '${widget.routeData['caloriesBurned']}kcal', Icons.local_fire_department),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // 성공한 미션 표시 카드
            Card(
              color: Colors.white,
              elevation: 4,
              margin: const EdgeInsets.all(8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '성공한 미션',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // 첫 번째 줄: 거리, 시간 정보
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildMissionCard('거리', success1, Icons.map),
                        _buildMissionCard('시간', success2, Icons.access_time),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // 두 번째 줄: 페이스 정보
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildMissionCard('페이스', success3, Icons.directions_run),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // 추가적인 위젯들...
          ],
        ),
      ),
    );
  }

// 정보를 표시하는 컬럼을 위한 도우미 메서드
  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Expanded( // 카드가 Row의 전체 너비를 채우도록 확장
      child: Card(
        color: Colors.white,
        elevation: 2,
        margin: const EdgeInsets.all(4), // 마진 추가
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.black),
              const SizedBox(height: 8), // 아이콘과 텍스트 사이 간격
              Text(
                value,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

// 성공한 미션을 표시하는 컬럼을 위한 도우미 메서드
  Widget _buildMissionCard(String label, String value, IconData icon) {
    return Expanded( // 카드가 Row의 전체 너비를 채우도록 확장
      child: Card(
        color: Colors.white,
        elevation: 2,
        margin: const EdgeInsets.all(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.black),
              const SizedBox(height: 8), // 아이콘과 텍스트 사이 간격
              Text(
                value,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
  }

// 모든 LatLng 객체를 포함하는 LatLngBounds를 생성하는 함수
LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
  double x0, x1, y0, y1;
  x0 = x1 = list[0].latitude;
  y0 = y1 = list[0].longitude;
  for (LatLng latLng in list) {
    if (latLng.latitude > x1) x1 = latLng.latitude;
    if (latLng.latitude < x0) x0 = latLng.latitude;
    if (latLng.longitude > y1) y1 = latLng.longitude;
    if (latLng.longitude < y0) y0 = latLng.longitude;
  }
  return LatLngBounds(southwest: LatLng(x0, y0), northeast: LatLng(x1, y1));
}


