import 'package:flutter/material.dart';
import 'package:irun/navi/navi.dart';
import 'package:irun/mission/button.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool showProperty1Home = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IRUN'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/option');
            },
            icon: Icon(Icons.settings),
            iconSize: 40,
          ),
        ],
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 큰 원
            Transform.translate(
              offset: Offset(0, -80),
              child: InkWell(
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(context, '/record', (route) => false);
                },
                highlightColor: Colors.grey,
                splashColor: Colors.grey,
                borderRadius: BorderRadius.circular(150.0),
                child: Container(
                  width: 300.0,
                  height: 300.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.black,
                      width: 3.0,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Start',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // 작은 원 1
            Positioned(
              bottom: 40,
              left: 45,
              child: SizedBox(
                width: 50.0,
                height: 50.0,
                child : CustomIconButton(),
              ),
            ),
            // 작은 원 2
            Positioned(
              bottom: 20,
              child: SizedBox(
                width: 50.0,
                height: 50.0,
                child: CustomIconButton(),
              ),
            ),
            // 작은 원 3
            Positioned(
              bottom: 40,
              right: 45,
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
