import 'package:flutter/material.dart';
import 'package:irun/map/google_maps_screen.dart';

//dummy

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('메인 화면'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('앱의 메인 화면입니다.'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GoogleMapsScreen()),
                );
              },
              child: Text('Google Maps 화면으로 이동'),
            ),
          ],
        ),
      ),
    );
  }
}