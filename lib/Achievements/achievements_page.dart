import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:irun/Achievements/achievement_provider.dart';
import 'package:irun/login/login_api.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

final User? user = auth.currentUser;

class Mission {
  String lottieFileName; //사용할 로티 이미지 이름
  String state; //미션 레벨
  int num;
  double value;

  Mission(
      {this.num = 0,
      required this.lottieFileName,
      required this.state,
      required this.value});

  factory Mission.fromJson(Map<dynamic, dynamic> json) {
    return Mission(
      lottieFileName: json["lottieFileName"],
      state: json["state"],
      num: json["num"],
      value: 0.1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "lottieFileName": lottieFileName,
      "state": state,
      "num": num,
    };
  }
}

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({Key? key}) : super(key: key);

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage>
    with TickerProviderStateMixin {
  late final List<AnimationController> _distanceController = [
    AnimationController(vsync: this),
    AnimationController(vsync: this),
    AnimationController(vsync: this),
  ];
  late final List<AnimationController> _timeController = [
    AnimationController(vsync: this),
    AnimationController(vsync: this),
    AnimationController(vsync: this),
  ];
  late final List<AnimationController> _paceController = [
    AnimationController(vsync: this),
    AnimationController(vsync: this),
    AnimationController(vsync: this),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    //컨트롤러 해제
    for (var controller in _distanceController) {
      controller.dispose();
    }
    for (var controller in _timeController) {
      controller.dispose();
    }
    for (var controller in _paceController) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final achievementsProvider =
        Provider.of<AchievementsProvider>(context, listen: true);

    final distanceData = achievementsProvider.distanceData;
    final paceData = achievementsProvider.paceData;
    final timeData = achievementsProvider.timeData;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Center(
              child: SizedBox(
                width: 900,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _buildCategory(
                          "거리 km", distanceData, _distanceController),
                      const SizedBox(height: 16.0),
                      _buildCategory("시간 min", timeData, _timeController),
                      const SizedBox(height: 16.0),
                      _buildCategory("페이스", paceData, _paceController),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory(
      String title, List<Mission> data, List<AnimationController> controllers) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          // 데이터가 비어 있으면 로딩 스피너를 표시
          data.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: data.length,
                  // 데이터의 길이만큼 아이템을 생성
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 4.0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Lottie.asset(
                          'assets/lottie/${data[index].state}_${data[index].lottieFileName}.json',
                          controller: controllers[index],
                          onLoaded: (composition) {
                            controllers[index].duration = composition.duration;
                            controllers[index].value =
                                data[index].value * data[index].num;
                          },
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
