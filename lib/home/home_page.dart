import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:irun/navi/navi.dart';
import 'package:irun/mission/button.dart';
import 'package:lottie/lottie.dart';
import 'package:irun/log/log_page.dart';
import 'package:irun/ranking/ranking_page.dart';
import 'package:irun/Achievements/Achievements_page.dart';

import 'weather_model.dart';
import 'weather_service.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool showProperty1Home = false;
  final _weatherService = WeatherService('93c0bc89694229c14ef4d76fe99b5c52');
  Weather? _weather;
  Position? _position;

  StreamSubscription<Position>? _positionStreamSubscription;

  GoogleMapController? mapController;
  LatLng? currentLocation;

  _fetchWeather() async {
    // String cityName = await _weatherService.getCurrentCity();
    String cityName = "Gumi";

    try {
      final weather = await _weatherService.getWeather(cityName);
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      print(e);
    }
  }

  String getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return 'images/sunny.json';

    switch (mainCondition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'images/cloud.json';
      case 'rain':
        return 'images/rain.json';
      case 'thunderstorm':
        return 'images/thunder.json';
      case 'clear':
        return 'images/sunny.json';
      default:
        return 'images/sunny.json';
    }
  }

  @override
  void initState() {
    super.initState();
    _initCurrentLocationAndTracking();
    _fetchWeather();
  }

  Future<void> _initCurrentLocationAndTracking() async {
      Position currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _updateCameraPosition(currentPosition);
      _startLocationTracking();
  }

  void _startLocationTracking() {
    var locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 1,
    );

    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      _updateCameraPosition(position);
    });
  }

  void _updateCameraPosition(Position position) {
    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
    });
    mapController?.animateCamera(
      CameraUpdate.newLatLng(currentLocation!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // 탭바의 수 설정
      child: Scaffold(
        appBar: AppBar(
          title: TabBar(
            tabs: [
              Tab(text: '메인'), // 탭바의 각 항목 설정
              Tab(text: '기록'),
              Tab(text: '랭킹'),
              Tab(text: '업적'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 각 탭에 대한 내용 설정
            Stack(
              children: [
                // GoogleMap 및 기타 위젯들
                GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    rootBundle.loadString('assets/map/mapstyle.json').then((String mapStyle) {
                      controller.setMapStyle(mapStyle);
                      mapController = controller;
                    });
                  },
                  initialCameraPosition: CameraPosition(
                    target: currentLocation ?? LatLng(36.1433405, 128.393805),
                    // 금오공대 좌표를 기본값으로 설정
                    // 기본값 또는 원하는 다른 위치의 좌표로 설정
                    zoom: 16.0,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 15,
                    top: 15,
                  ),
                  child: ClipOval(
                    child: Container(
                      height: 80,
                      width: 80,
                      color: Colors.white,
                      // 흰색 배경 설정
                      padding: EdgeInsets.all(0),
                      // 동그라미 내부 여백 설정
                      child: Column(
                        children: [
                          Lottie.asset(
                            getWeatherAnimation(_weather?.mainCondition),
                            width: 50,
                            height: 50,
                            fit: BoxFit.fill,
                          ),
                          SizedBox(width: 10), // 아이콘과 온도 사이 여백 조절
                          Text(
                            "${_weather?.temperature.round()}℃",
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // 기존의 UI 요소들
                Positioned(
                  bottom: 50,
                  left: 80,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/record', (route) => false);
                    },
                    child: Lottie.asset(
                      'images/start.json',
                      width: 250.0,
                      height: 250.0,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),

                // 작은 원 1
                Positioned(
                  left: 100,
                  bottom: 80,
                  child: Container(
                    width: 50.0,
                    height: 50.0,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/option');
                      },
                      icon: Icon(Icons.settings),
                      iconSize: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
                // 작은 원 2
                Positioned(
                  left: 180,
                  bottom: 50,
                  child: SizedBox(
                    width: 50.0,
                    height: 50.0,
                    child: CustomIconButton(),
                  ),
                ),
                // 작은 원 3
                Positioned(
                  left: 260,
                  bottom: 80,
                  child: SizedBox(
                    width: 50.0,
                    height: 50.0,
                    child: CustomIconButton(),
                  ),
                ),
              ],
            ),
            Container(
              // 두 번째 탭의 내용
              child: Center(
                child: LogPage(),
              ),
            ),
            Container(
              // 두 번째 탭의 내용
              child: Center(
                child: RankingPage(),
              ),
            ),
            Container(
              // 두 번째 탭의 내용
              child: Center(
                child: AchievementsPage(),
              ),
            ),
          ],
        ),
      ),

    );
  }
  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }
}
// Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'iRun',
//           style: TextStyle(
//             color: Colors.black,
//             fontWeight: FontWeight.bold,
//             fontSize: 25.0,
//           ),
//         ),
//       ),
//       body: Stack(
//         children: [
//           // GoogleMap 위젯 추가
//           GoogleMap(
//             onMapCreated: _onMapCreated,
//             initialCameraPosition: CameraPosition(
//               target: currentLocation ?? LatLng(36.1433405, 128.393805),
//               // 서울의 좌표를 기본값으로 설정
//               // 기본값 또는 원하는 다른 위치의 좌표로 설정
//               zoom: 16.0,
//             ),
//           ),
//           Padding(
//             padding: EdgeInsets.only(
//               left: 30,
//               top: 30,
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 // Text(_weather?.cityName ?? "loading city..."),
//                 Lottie.asset(
//                   getWeatherAnimation(_weather?.mainCondition),
//                   width: 50,
//                   height: 50,
//                   fit: BoxFit.fill,
//                 ),
//                 Text(
//                   "${_weather?.temperature.round()}℃",
//                 ),
//                 // Text(_weather?.mainCondition ?? "")
//               ],
//             ),
//           ),
//           // 기존의 UI 요소들
//           Positioned(
//             bottom: 50,
//             left: 80,
//             child: GestureDetector(
//               onTap: () {
//                 Navigator.pushNamedAndRemoveUntil(
//                     context, '/record', (route) => false);
//               },
//               child: Lottie.asset(
//                 'images/start.json',
//                 width: 250.0,
//                 height: 250.0,
//                 fit: BoxFit.fill,
//               ),
//             ),
//           ),
//
//           // 작은 원 1
//           Positioned(
//             left: 100,
//             bottom: 80,
//             child: Container(
//               width: 50.0,
//               height: 50.0,
//               decoration: BoxDecoration(
//                 color: Colors.grey,
//                 shape: BoxShape.circle,
//               ),
//               child: IconButton(
//                 onPressed: () {
//                   Navigator.pushNamed(context, '/option');
//                 },
//                 icon: Icon(Icons.settings),
//                 iconSize: 30,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//           // 작은 원 2
//           Positioned(
//             left: 180,
//             bottom: 50,
//             child: SizedBox(
//               width: 50.0,
//               height: 50.0,
//               child: CustomIconButton(),
//             ),
//           ),
//           // 작은 원 3
//           Positioned(
//             left: 260,
//             bottom: 80,
//             child: SizedBox(
//               width: 50.0,
//               height: 50.0,
//               child: CustomIconButton(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
