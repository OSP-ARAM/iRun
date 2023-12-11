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
        title: const Text(
          '기록 상세',
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.centerLeft,
            child: Text(
              '${formattedDateTime}', // 원하는 텍스트로 변경
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 300,
            child: GoogleMap(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(5),
                    child: Text(
                      '${widget.routeData['duration'].substring(1)}', // 원하는 두 번째 텍스트로 변경
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: const Text(
                      '시간', // 원하는 첫 번째 텍스트로 변경
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(5),
                    child: Text(
                      '${widget.routeData['pace']}', // 원하는 두 번째 텍스트로 변경
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: const Text(
                      '페이스', // 원하는 첫 번째 텍스트로 변경
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(5),
                    child: Text(
                      '${widget.routeData['distance']}km', // 원하는 두 번째 텍스트로 변경
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: const Text(
                      '거리', // 원하는 첫 번째 텍스트로 변경
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(5),
                    child: Text(
                      '${widget.routeData['caloriesBurned']}', // 원하는 두 번째 텍스트로 변경
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: const Text(
                      '칼로리', // 원하는 첫 번째 텍스트로 변경
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Center( // "성공한 미션"을 Center 위젯으로 감싸서 중앙 정렬
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                '성공한 미션',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(5),
                    child: const Text(
                      '거리', // 원하는 두 번째 텍스트로 변경
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      '$success1',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(5),
                    child: const Text(
                      '시간', // 원하는 두 번째 텍스트로 변경
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      '$success2',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(5),
                    child: const Text(
                      '페이스', // 원하는 두 번째 텍스트로 변경
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      '$success3',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // 여기에 추가적인 위젯을 배치할 수 있습니다.
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

