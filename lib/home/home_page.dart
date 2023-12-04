import 'package:flutter/material.dart';
import 'package:irun/navi/navi.dart';
import 'package:irun/mission/button.dart';
import 'package:lottie/lottie.dart';

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
        title: Text('iRun'),
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
          preferredSize: Size.fromHeight(50),
          child: Padding(
            padding: EdgeInsets.only(left: 30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 30.0,
                  height: 30.0,
                  child: CustomIconButton(),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Start 버튼
            Transform.translate(
              offset: Offset(3, 0),
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
            Positioned(
              child: Lottie.asset(
                'images/fire.json',
                width: 300,
                height: 300,
                fit: BoxFit.fill,
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
              left:127,
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
