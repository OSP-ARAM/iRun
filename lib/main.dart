import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:irun/Achievements/Achievements_page.dart';
import 'package:irun/home/home_page.dart';
import 'package:irun/log/log_page.dart';
import 'package:irun/option/option_page.dart';
import 'firebase_options.dart';
import 'package:irun/record/record_page.dart';

import 'login/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
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
        '/home' : (context) => MyHomePage(),
        // '/mission' : (context) => MissionPage(),
        '/option' : (context) => OptionPage(),
        '/record' : (context) => MapScreen(),
        '/log' : (context) => LogPage(),
        '/Achievements' : (context) => AchievementsPage()
      },
      initialRoute: '/',
    );
  }
}
