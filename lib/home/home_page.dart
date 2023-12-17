import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:irun/mission/button.dart';
import 'package:irun/music/music_page.dart';
import 'package:lottie/lottie.dart';
import 'package:irun/log/log_page.dart';
import 'package:irun/ranking/ranking_page.dart';
import 'package:irun/Achievements/achievements_page.dart';
import '../Achievements/achievement_provider.dart';
import 'weather_model.dart';
import 'weather_service.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:irun/mission/mission_page.dart';

import 'package:permission_handler/permission_handler.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool showProperty1Home = false;
  final _weatherService = WeatherService('YOUR_API_KEY');
  Weather? _weather;

  StreamSubscription<Position>? _positionStreamSubscription;

  GoogleMapController? mapController;
  LatLng? currentLocation;

  _fetchWeather() async {
    Position position = await _weatherService.getCurrentCity();
    try {
      final weather = await _weatherService.getWeather(
          position.longitude, position.latitude);
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
    _checkPermission();
    _fetchWeather();
  }

  Future<void> _checkPermission() async {
    var status = await Permission.location.status;
    if (status.isGranted) {
      _initCurrentLocationAndTracking();
    } else if (status.isDenied) {
      _showPermissionDialog();
    } else if (status.isPermanentlyDenied) {
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("위치 권한 필요"),
          content: const Text(
              "이 앱은 위치 서비스를 사용하기 위해 위치 권한이 필요합니다. 앱을 사용하려면 권한을 허용해 주세요."),
          actions: <Widget>[
            TextButton(
              child: const Text("앱 종료"),
              onPressed: () {
                SystemNavigator.pop(); // 앱을 종료합니다
              },
            ),
            TextButton(
              child: const Text("설정으로 이동"),
              onPressed: () {
                Navigator.of(context).pop();
                SystemNavigator.pop(); // 앱을 종료합니다
                openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _initCurrentLocationAndTracking() async {
    Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _updateCameraPosition(currentPosition);
    _startLocationTracking();
  }

  void _startLocationTracking() {
    var locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 1,
    );

    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings)
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
    final achievementsProvider =
    Provider.of<AchievementsProvider>(context, listen: false);
    if (!achievementsProvider.isInitialized) {
      achievementsProvider.initializeDatabase();
      achievementsProvider.isInitialized = true;
    }
    return WillPopScope(
      onWillPop: _onBackPressed,
        child: DefaultTabController(
          length: 4,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.yellow, // AppBar 배경색 설정
              title: const TabBar(
                indicatorColor: Colors.red,
                labelStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 16, // 원하는 폰트 크기로 변경
                  fontWeight: FontWeight.bold, // 원하는 글꼴 또는 굵기로 변경
                  // fontFamily: 'YourFontFamily', // 원하는 글꼴 설정 (옵션)
                ),
                tabs: [
                  Tab(text: '메인'),
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
                        rootBundle
                            .loadString('assets/map/mapstyle.json')
                            .then((String mapStyle) {
                          controller.setMapStyle(mapStyle);
                          mapController = controller;
                        });
                      },
                      initialCameraPosition: CameraPosition(
                        target:
                        currentLocation ?? const LatLng(36.1433405, 128.393805),
                        // 금오공대 좌표를 기본값으로 설정
                        // 기본값 또는 원하는 다른 위치의 좌표로 설정
                        zoom: 16.0,
                      ),
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 15,
                        top: 15,
                      ),
                      child: ClipOval(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          height: 80,
                          width: 80,
                          // 흰색 배경 설정
                          padding: const EdgeInsets.all(0),
                          // 동그라미 내부 여백 설정
                          child: Column(
                            children: [
                              Lottie.asset(
                                getWeatherAnimation(_weather?.mainCondition),
                                width: 50,
                                height: 50,
                                fit: BoxFit.fill,
                              ),
                              const SizedBox(width: 10), // 아이콘과 온도 사이 여백 조절
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
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/option');
                          },
                          icon: const Icon(Icons.settings),
                          iconSize: 30,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // 작은 원 2
                    const Positioned(
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
                      child: Container(
                        width: 50.0,
                        height: 50.0,
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/music');
                          },
                          icon: const Icon(Icons.music_note),
                          iconSize: 30,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Positioned(
                      top: 100,
                      left: 0,
                      child: SelectedMissionsWidget(),
                    ),
                  ],
                ),
                const Center(
                  child: LogPage(),
                ),
                Center(
                  child: RankingPage(),
                ),
                const Center(
                  child: AchievementsPage(),
                )
              ],
            ),
          ),
        ),
    );
  }

  Future<bool> _onBackPressed() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white, // 배경색 설정
        title: Text(
          '앱 종료',
          style: TextStyle(
            color: Colors.black, // 제목 글꼴 색상
            fontWeight: FontWeight.bold, // 제목 글꼴 굵기
          ),
        ),
        content: Text(
          '앱을 종료하시겠습니까?',
          style: TextStyle(
            color: Colors.grey[600], // 내용 글꼴 색상
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              '아니오',
              style: TextStyle(
                color: Colors.black, // 버튼 글꼴 색상
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              if (AudioPlayerManager.isInstanceCreated) {
                AudioPlayerManager.instance!.dispose();
              }
              SystemNavigator.pop(); // Android에서 앱 종료
            },
            child: Text(
              '예',
              style: TextStyle(
                color: Colors.black, // 버튼 글꼴 색상
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // 대화상자 모서리 둥글게
        ),
      ),
    ) ?? false;
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }
}


class SelectedMissionsWidget extends StatelessWidget {
  const SelectedMissionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final missionData = Provider.of<MissionData>(context);
    bool hasData = missionData.time != null || missionData.distance != null || missionData.pace != null;

    if (!hasData) {
      return SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.yellow.withOpacity(0.7), // 노란색 배경에 약간의 투명도 적용
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '선택된 미션',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (missionData.time != null)
            _buildMissionItem(Icons.access_time, '시간: ${missionData.time}'),
          if (missionData.distance != null)
            _buildMissionItem(Icons.map, '거리: ${missionData.distance}'),
          if (missionData.pace != null)
            _buildMissionItem(Icons.directions_run, '페이스: ${missionData.pace}'),
        ],
      ),
    );
  }

  Widget _buildMissionItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}



