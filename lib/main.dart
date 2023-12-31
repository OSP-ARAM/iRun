// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:irun/log/log_provider.dart';
import 'package:irun/ranking/ranking_provider.dart';
import 'package:provider/provider.dart';

import 'Achievements/achievement_provider.dart';
import 'Achievements/achievements_page.dart';

import 'firebase_options.dart';
import 'home/home_page.dart';
import 'log/log_page.dart';
import 'mission/mission_page.dart';
import 'music/music_page.dart';
import 'option/option_page.dart';
import 'ranking/ranking_page.dart';
import 'record/stop_record_page.dart';
import 'record/record_page.dart';
import 'login/body_measurement_page.dart';
import 'login/login_page.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MissionData()),
        ChangeNotifierProvider(create: (_) => AchievementsProvider()),
        ChangeNotifierProvider(create: (_) => RankingProvider()),
        ChangeNotifierProvider(create: (_) => LogProvider()),
      ],
      child: const MaterialApp(home: MyApp()),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final achievementsProvider =
        Provider.of<AchievementsProvider>(context, listen: false);
    if (!achievementsProvider.isInitialized) {
      achievementsProvider.initializeDatabase();
      achievementsProvider.isInitialized = true;
    }
    final rankingProvider =
        Provider.of<RankingProvider>(context, listen: false);
    if (!rankingProvider.isInitialLoadDone) {
      rankingProvider.loadRankingData();
    }
    final logProvider = Provider.of<LogProvider>(context, listen: false);
    if (!logProvider.isDataLoaded) {
      logProvider.fetchAndCacheRecords();
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {
        '/': (context) => LoginPage(),
        '/home': (context) => const MyHomePage(),
        '/music': (context) => const MusicPlayerPage(),
        '/ranking': (context) => RankingPage(),
        '/option': (context) => const OptionPage(),
        '/record': (context) => const MapScreen(),
        '/log': (context) => const LogPage(),
        '/Achievements': (context) => const AchievementsPage(),
        '/body': (context) => BodyMeasurementPage()
      },
      initialRoute: '/',
    );
  }
}
