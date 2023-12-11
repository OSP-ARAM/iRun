// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MissionData()),
        ChangeNotifierProvider(create: (_) => AchievementsProvider()),
        ChangeNotifierProvider(create: (_) => RankingProvider())
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
    final rankingProvider = Provider.of<RankingProvider>(context, listen: false);
    if (!rankingProvider.isInitialLoadDone) {
      rankingProvider.loadRankingData();
    }

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {
        '/': (context) => LoginPage(),
        '/home': (context) => const MyHomePage(),
        '/music': (context) => const MusicPage(),
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
