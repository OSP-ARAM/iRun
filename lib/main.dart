import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:irun/Achievements/achievements_page.dart';
import 'package:irun/home/home_page.dart';
import 'package:irun/log/log_page.dart';
import 'package:irun/mission/mission_page.dart';
import 'package:irun/music/music_page.dart';
import 'package:irun/option/option_page.dart';
import 'package:irun/ranking/ranking_page.dart';
import 'package:irun/record/stop_record_page.dart';
import 'firebase_options.dart';
import 'package:irun/record/record_page.dart';
import 'package:irun/login/body_measurement_page.dart';
import 'package:audio_service/audio_service.dart';
import 'package:provider/provider.dart';
import 'login/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ChangeNotifierProvider(
    create: (context) => MissionData(),
    child: const MyApp(),
  ));
  _startBackgroundTask();
}

Future<void> _startBackgroundTask() async {
  await AudioService.start(
    backgroundTaskEntrypoint: _audioPlayerTaskEntrypoint,
    androidNotificationChannelName: 'Music Player',
    androidNotificationColor: 0xFF2196f3,
    androidNotificationIcon: 'mipmap/ic_launcher',
  );
}

void _audioPlayerTaskEntrypoint() {
  AudioServiceBackground.run(() => AudioPlayerTask());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      //home: LoginPage(),

      routes: {
        '/' : (context) => LoginPage(),
        '/home' : (context) => const MyHomePage(),
        '/music' : (context) => const MusicPage(),
        '/ranking' : (context) => RankingPage(),
        '/option' : (context) => const OptionPage(),
        '/record' : (context) => MapScreen(),
        '/log' : (context) => const LogPage(),
        '/Achievements' : (context) => const AchievementsPage(),
        '/body' : (context) => BodyMeasurementPage()
      },
      initialRoute: '/',
    );
  }
}