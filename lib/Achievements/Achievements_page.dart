import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:irun/login/login_api.dart';
import 'package:lottie/lottie.dart';

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

  final _distanceData = <Mission>[];
  final _timeData = <Mission>[];
  final _paceData = <Mission>[];

  Mission distance3 = Mission(
    lottieFileName: "distance3",
    state: "bronze",
    num: 0,
    value: 0.1,
  );
  Mission distance5 = Mission(
    lottieFileName: "distance5",
    state: "bronze",
    num: 0,
    value: 0.1,
  );
  Mission distance10 = Mission(
    lottieFileName: "distance10",
    state: "bronze",
    num: 0,
    value: 0.1,
  );

  Mission time15 = Mission(
    lottieFileName: "time15",
    state: "bronze",
    num: 0,
    value: 0.1,
  );
  Mission time30 = Mission(
    lottieFileName: "time30",
    state: "bronze",
    num: 0,
    value: 0.1,
  );
  Mission time60 = Mission(
    lottieFileName: "time60",
    state: "bronze",
    num: 0,
    value: 0.1,
  );

  Mission pace550 = Mission(
    lottieFileName: "pace550",
    state: "bronze",
    num: 0,
    value: 0.1,
  );
  Mission pace600 = Mission(
    lottieFileName: "pace600",
    state: "bronze",
    num: 0,
    value: 0.1,
  );
  Mission pace630 = Mission(
    lottieFileName: "pace630",
    state: "bronze",
    num: 0,
    value: 0.1,
  );

  _AchievementsPageState() {
    // 비동기 함수로 감싸기
    _initializeDatabase();
  }

  Future<bool> checkIfCollectionExists(
      String uid, String collectionName) async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .collection(collectionName)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> _initializeDatabase() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    bool isCollectionExists =
    await checkIfCollectionExists(user!.uid, 'Mission');

    if (!isCollectionExists) {
      await firestore
          .collection("Users")
          .doc(user!.uid)
          .collection("Mission")
          .doc("distance3")
          .set(distance3.toJson());

      await firestore
          .collection("Users")
          .doc(user!.uid)
          .collection("Mission")
          .doc("distance5")
          .set(distance5.toJson());

      await firestore
          .collection("Users")
          .doc(user!.uid)
          .collection("Mission")
          .doc("distance10")
          .set(distance10.toJson());

      await firestore
          .collection("Users")
          .doc(user!.uid)
          .collection("Mission")
          .doc("time15")
          .set(time15.toJson());

      await firestore
          .collection("Users")
          .doc(user!.uid)
          .collection("Mission")
          .doc("time30")
          .set(time30.toJson());

      await firestore
          .collection("Users")
          .doc(user!.uid)
          .collection("Mission")
          .doc("time60")
          .set(time60.toJson());

      await firestore
          .collection("Users")
          .doc(user!.uid)
          .collection("Mission")
          .doc("pace550")
          .set(pace550.toJson());

      await firestore
          .collection("Users")
          .doc(user!.uid)
          .collection("Mission")
          .doc("pace600")
          .set(pace600.toJson());

      await firestore
          .collection("Users")
          .doc(user!.uid)
          .collection("Mission")
          .doc("pace630")
          .set(pace630.toJson());
    }

    // "거리" 위젯에 대한 데이터 가져오기
    DocumentSnapshot snapshot3 = await firestore
        .collection("Users")
        .doc(user!.uid)
        .collection("Mission")
        .doc("distance3")
        .get();
    DocumentSnapshot snapshot5 = await firestore
        .collection("Users")
        .doc(user!.uid)
        .collection("Mission")
        .doc("distance5")
        .get();
    DocumentSnapshot snapshot10 = await firestore
        .collection("Users")
        .doc(user!.uid)
        .collection("Mission")
        .doc("distance10")
        .get();

    Map<String, dynamic> toMap3 = snapshot3.data() as Map<String, dynamic>;
    Map<String, dynamic> toMap5 = snapshot5.data() as Map<String, dynamic>;
    Map<String, dynamic> toMap10 = snapshot10.data() as Map<String, dynamic>;

    setState(() {
      _distanceData.add(Mission.fromJson(toMap3));
      _distanceData.add(Mission.fromJson(toMap5));
      _distanceData.add(Mission.fromJson(toMap10));
    });

    // "시간" 위젯에 대한 데이터 가져오기
    DocumentSnapshot snapshot15 = await firestore
        .collection("Users")
        .doc(user!.uid)
        .collection("Mission")
        .doc("time15")
        .get();
    DocumentSnapshot snapshot30 = await firestore
        .collection("Users")
        .doc(user!.uid)
        .collection("Mission")
        .doc("time30")
        .get();
    DocumentSnapshot snapshot60 = await firestore
        .collection("Users")
        .doc(user!.uid)
        .collection("Mission")
        .doc("time60")
        .get();

    Map<String, dynamic> toMap15 = snapshot15.data() as Map<String, dynamic>;
    Map<String, dynamic> toMap30 = snapshot30.data() as Map<String, dynamic>;
    Map<String, dynamic> toMap60 = snapshot60.data() as Map<String, dynamic>;

    setState(() {
      _timeData.add(Mission.fromJson(toMap15));
      _timeData.add(Mission.fromJson(toMap30));
      _timeData.add(Mission.fromJson(toMap60));
    });

    // "페이스" 위젯에 대한 데이터 가져오기
    DocumentSnapshot snapshot550 = await firestore
        .collection("Users")
        .doc(user!.uid)
        .collection("Mission")
        .doc("pace550")
        .get();
    DocumentSnapshot snapshot600 = await firestore
        .collection("Users")
        .doc(user!.uid)
        .collection("Mission")
        .doc("pace600")
        .get();
    DocumentSnapshot snapshot630 = await firestore
        .collection("Users")
        .doc(user!.uid)
        .collection("Mission")
        .doc("pace630")
        .get();

    Map<String, dynamic> toMap550 = snapshot550.data() as Map<String, dynamic>;
    Map<String, dynamic> toMap600 = snapshot600.data() as Map<String, dynamic>;
    Map<String, dynamic> toMap630 = snapshot630.data() as Map<String, dynamic>;

    setState(() {
      _paceData.add(Mission.fromJson(toMap630));
      _paceData.add(Mission.fromJson(toMap600));
      _paceData.add(Mission.fromJson(toMap550));
    });
  }

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
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildCategory("거리 km", _distanceData, _distanceController),
              const SizedBox(height: 16.0),
              _buildCategory("시간 min", _timeData, _timeController),
              const SizedBox(height: 16.0),
              _buildCategory("페이스", _paceData, _paceController),
            ],
          ),
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
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: 3,
            itemBuilder: (context, index) {
              if (data.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              } else {
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
              }
            },
          ),
        ],
      ),
    );
  }
}