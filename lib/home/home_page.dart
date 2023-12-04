import 'package:flutter/material.dart';
import 'package:irun/navi/navi.dart';
import 'package:irun/mission/button.dart';
import 'package:lottie/lottie.dart';

import 'weather_model.dart';
import 'weather_service.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool showProperty1Home = false;
  final _weatherService = WeatherService('93c0bc89694229c14ef4d76fe99b5c52');
  Weather? _weather;

  _fetchWeather() async {
    String cityName = await _weatherService.getCurrentCity();

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

    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'iRun',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 25.0,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/option');
            },
            icon: Icon(Icons.settings),
            iconSize: 40,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(130),
          child: Padding(
            padding: EdgeInsets.only(right: 300.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(_weather?.cityName ?? "loading city..."),
                Lottie.asset(
                  getWeatherAnimation(_weather?.mainCondition),
                  width: 50,
                  height: 50,
                  fit: BoxFit.fill,
                ),
                Text(
                  "${_weather?.temperature.round()}℃",
                ),
                Text(_weather?.mainCondition ?? "")
              ],
            ),
          ),
        ),
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              child: Lottie.asset(
                'images/fire.json',
                width: 310,
                height: 310,
                fit: BoxFit.fill,
              ),
            ),
            // Start 버튼
            Transform.translate(
              offset: Offset(5, -1),
              child: InkWell(
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/record', (route) => false);
                },
                highlightColor: Colors.grey,
                splashColor: Colors.grey,
                borderRadius: BorderRadius.circular(150.0),
                child: Container(
                  width: 300.0,
                  height: 150.0,
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '시작',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 35.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 작은 원 1
            Positioned(
              bottom: 30,
              left: 203,
              child: SizedBox(
                width: 50.0,
                height: 50.0,
                child: CustomIconButton(),
              ),
            ),
            // 작은 원 2
            Positioned(
              left: 133,
              bottom: 0,
              child: SizedBox(
                width: 50.0,
                height: 50.0,
                child: CustomIconButton(),
              ),
            ),
            // 작은 원 3
            Positioned(
              bottom: 30,
              right: 197,
              child: SizedBox(
                width: 50.0,
                height: 50.0,
                child: CustomIconButton(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: MenuBottom(currentIndex: 1),
    );
  }
}
