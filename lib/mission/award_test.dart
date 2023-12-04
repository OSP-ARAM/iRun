import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

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

class AwardTest extends StatefulWidget {
  const AwardTest({super.key});

  @override
  State<AwardTest> createState() => _AwardTestState();
}

class _AwardTestState extends State<AwardTest> with TickerProviderStateMixin {
  //컨트롤러 생성
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
  Mission distance3 = Mission(
    lottieFileName: "medal5",
    state: "gold",
    num: 8,
    value: 0.1,
  );
  Mission distance5 = Mission(
    lottieFileName: "medal5",
    state: "gold",
    num: 2,
    value: 0.1,
  );
  Mission distance10 = Mission(
    lottieFileName: "medal5",
    state: "gold",
    num: 5,
    value: 0.1,
  );

  final _timeData = <Mission>[];
  Mission time15 = Mission(
    lottieFileName: "medal5",
    state: "gold",
    num: 8,
    value: 0.1,
  );
  Mission time30 = Mission(
    lottieFileName: "medal5",
    state: "gold",
    num: 2,
    value: 0.1,
  );
  Mission time60 = Mission(
    lottieFileName: "medal5",
    state: "gold",
    num: 5,
    value: 0.1,
  );

  final _paceData = <Mission>[];
  Mission pace550 = Mission(
    lottieFileName: "medal5",
    state: "gold",
    num: 8,
    value: 0.1,
  );
  Mission pace600 = Mission(
    lottieFileName: "medal5",
    state: "gold",
    num: 2,
    value: 0.1,
  );
  Mission pace630 = Mission(
    lottieFileName: "medal5",
    state: "gold",
    num: 5,
    value: 0.1,
  );

  _AwardTestState() {
    // 비동기 함수로 감싸기
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    await firestore
        .collection("Mission")
        .doc("distance3")
        .set(distance3.toJson());
    await firestore
        .collection("Mission")
        .doc("distance5")
        .set(distance5.toJson());
    await firestore
        .collection("Mission")
        .doc("distance10")
        .set(distance10.toJson());

    await firestore.collection("Mission").doc("time15").set(time15.toJson());
    await firestore.collection("Mission").doc("time30").set(time30.toJson());
    await firestore.collection("Mission").doc("time60").set(time60.toJson());

    await firestore.collection("Mission").doc("pace550").set(time15.toJson());
    await firestore.collection("Mission").doc("pace600").set(time30.toJson());
    await firestore.collection("Mission").doc("pace630").set(time60.toJson());

    // "거리" 위젯에 대한 데이터 가져오기
    DocumentSnapshot snapshot3 =
        await firestore.collection("Mission").doc("distance3").get();
    DocumentSnapshot snapshot5 =
        await firestore.collection("Mission").doc("distance5").get();
    DocumentSnapshot snapshot10 =
        await firestore.collection("Mission").doc("distance10").get();

    Map<String, dynamic> toMap3 = snapshot3.data() as Map<String, dynamic>;
    Map<String, dynamic> toMap5 = snapshot5.data() as Map<String, dynamic>;
    Map<String, dynamic> toMap10 = snapshot10.data() as Map<String, dynamic>;

    setState(() {
      _distanceData.add(Mission.fromJson(toMap3));
      _distanceData.add(Mission.fromJson(toMap5));
      _distanceData.add(Mission.fromJson(toMap10));
    });

    // "시간" 위젯에 대한 데이터 가져오기
    DocumentSnapshot snapshot15 =
        await firestore.collection("Mission").doc("time15").get();
    DocumentSnapshot snapshot30 =
        await firestore.collection("Mission").doc("time30").get();
    DocumentSnapshot snapshot60 =
        await firestore.collection("Mission").doc("time60").get();

    Map<String, dynamic> toMap15 = snapshot15.data() as Map<String, dynamic>;
    Map<String, dynamic> toMap30 = snapshot30.data() as Map<String, dynamic>;
    Map<String, dynamic> toMap60 = snapshot60.data() as Map<String, dynamic>;

    setState(() {
      _timeData.add(Mission.fromJson(toMap15));
      _timeData.add(Mission.fromJson(toMap30));
      _timeData.add(Mission.fromJson(toMap60));
    });

    // "페이스" 위젯에 대한 데이터 가져오기
    DocumentSnapshot snapshot550 =
        await firestore.collection("Mission").doc("pace550").get();
    DocumentSnapshot snapshot600 =
        await firestore.collection("Mission").doc("pace600").get();
    DocumentSnapshot snapshot630 =
        await firestore.collection("Mission").doc("pace630").get();

    Map<String, dynamic> toMap550 = snapshot550.data() as Map<String, dynamic>;
    Map<String, dynamic> toMap600 = snapshot600.data() as Map<String, dynamic>;
    Map<String, dynamic> toMap630 = snapshot630.data() as Map<String, dynamic>;

    setState(() {
      _paceData.add(Mission.fromJson(toMap550));
      _paceData.add(Mission.fromJson(toMap600));
      _paceData.add(Mission.fromJson(toMap630));
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
    return MaterialApp(
      title: '업적',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('업적'),
        ),
        body: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Column(
              children: [
                const Text(
                  "거리",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    backgroundColor: Colors.amberAccent,
                  ),
                ),
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  itemCount: _distanceData.length,
                  itemBuilder: (context, index) {
                    return Center(
                      child: Lottie.asset(
                        'asset/lottie/${_distanceData[index].lottieFileName}.json',
                        controller: _distanceController[index],
                        onLoaded: (composition) {
                          _distanceController[index].duration =
                              composition.duration;
                          _distanceController[index].value =
                              _distanceData[index].value *
                                  _distanceData[index].num;
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
            Column(
              children: [
                const Text(
                  "시간",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    backgroundColor: Colors.amberAccent,
                  ),
                ),
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  itemCount: _timeData.length,
                  itemBuilder: (context, index) {
                    return Center(
                      child: Lottie.asset(
                        'asset/lottie/${_timeData[index].lottieFileName}.json',
                        controller: _timeController[index],
                        onLoaded: (composition) {
                          _timeController[index].duration =
                              composition.duration;
                          _timeController[index].value =
                              _timeData[index].value * _timeData[index].num;
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
            Column(
              children: [
                const Text(
                  "페이스",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    backgroundColor: Colors.amberAccent,
                  ),
                ),
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  itemCount: _paceData.length,
                  itemBuilder: (context, index) {
                    return Center(
                      child: Lottie.asset(
                        'asset/lottie/${_paceData[index].lottieFileName}.json',
                        controller: _paceController[index],
                        onLoaded: (composition) {
                          _paceController[index].duration =
                              composition.duration;
                          _paceController[index].value =
                              _paceData[index].value * _paceData[index].num;
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
