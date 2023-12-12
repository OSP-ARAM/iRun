import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:irun/mission/mission_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class FirestoreService {
  static Future<void> uploadDataToFirestore({
    required User user,
    required Position currentLocation,
    required List<Marker> markers,
    required Stopwatch stopwatch,
    required double totalDistance,
    required MissionData missionData,
    required double caloriesBurned,
  }) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    if (markers.isNotEmpty) {
      String formattedTime = _formatTime(stopwatch.elapsedMilliseconds);
      String formattedDistance = (totalDistance / 1000).toStringAsFixed(2);
      String pace =
          _calculatePace(totalDistance, stopwatch.elapsedMilliseconds);

      DateTime now = DateTime.now();
      String timestamp = now.toIso8601String();

      List<Map<String, double>> routePoints = markers.map((marker) {
        return {
          'latitude': marker.position.latitude,
          'longitude': marker.position.longitude,
        };
      }).toList();

      List<String> parts = formattedTime.split(':');

      // 시(hour), 분(minute)을 각각 정수로 변환
      int hours = int.parse(parts[0]);
      int minutes = int.parse(parts[1]);

      // 총 시간을 분으로 계산
      int totalMinutes = hours * 60 + minutes;

      String calculatedPace = FirestoreService._calculatePace(
          totalDistance, stopwatch.elapsedMilliseconds);

      // 페이스 문자열을 분과 초로 분리

      int paceMinutes;
      int paceSeconds;

      if (calculatedPace == "-'--''") {
        paceMinutes = -1; // 유효하지 않은 값으로 설정
        paceSeconds = -1; // 유효하지 않은 값으로 설정
      } else {
        List<String> paceParts = calculatedPace.split("'");
        paceMinutes = int.parse(paceParts[0]);
        paceSeconds = int.parse(paceParts[1].replaceAll("''", ""));
      }



      //칼로리 string으로 변환

      String formattedcal = caloriesBurned.toStringAsFixed(1);

      RunData runData = RunData(
        duration: formattedTime,
        distance: formattedDistance,
        timestamp: DateTime.now(),
        routePoints: routePoints,
        pace: pace,
        caloriesBurned: formattedcal,
      );

      // Run record 컬렉션에 저장
      await firestore
          .collection("Users")
          .doc(user.uid)
          .collection("Run record")
          .doc(timestamp)
          .set(runData.toJson());

      //성공미션 배열
      Map<String, List<String>> successfulMissions = {
        '거리': [],
        '시간': [],
        '페이스': [],
      };

      // Mission 컬렉션에 저장 (3km)
      if (missionData.distance == '3km') {
        String lottieFileName = "distance3";
        String state;
        int num;
        bool success = false;

        DocumentSnapshot snapshot = await firestore
            .collection("Users")
            .doc(user.uid)
            .collection("Mission")
            .doc(lottieFileName)
            .get();

        if (snapshot.exists) {
          var data = snapshot.data() as Map<String, dynamic>;
          num = data['num'] ?? 0;
          state = data['state'] ?? "bronze";

          if (double.parse(formattedDistance) >= 3.0) {
            num++;
            success = true;
          }

          if (num >= 10 && state != "gold") {
            num = 0;
            if (state == "bronze") {
              state = "silver";
            } else if (state == "silver") {
              state = "gold";
            }
          }
        } else {
          num = (double.parse(formattedDistance) >= 3.0) ? 1 : 0;
          state = "bronze";
        }

        await firestore
            .collection("Users")
            .doc(user.uid)
            .collection("Mission")
            .doc(lottieFileName)
            .update({'num': num, 'state': state});

        if (success) {
          successfulMissions['거리']?.add('3km');
        }
      }

      //5km
      if (missionData.distance == '5km') {
        String lottieFileName = "distance5";
        String state;
        int num;
        bool success = false;

        DocumentSnapshot snapshot = await firestore
            .collection("Users")
            .doc(user.uid)
            .collection("Mission")
            .doc(lottieFileName)
            .get();

        if (snapshot.exists) {
          var data = snapshot.data() as Map<String, dynamic>;
          num = data['num'] ?? 0;
          state = data['state'] ?? "bronze";

          if (double.parse(formattedDistance) >= 5.0) {
            num++;
            success = true;
          }

          if (num >= 10 && state != "gold") {
            num = 0;
            if (state == "bronze") {
              state = "silver";
            } else if (state == "silver") {
              state = "gold";
            }
          }
        } else {
          num = (double.parse(formattedDistance) >= 5.0) ? 1 : 0;
          state = "bronze";
        }

        await firestore
            .collection("Users")
            .doc(user.uid)
            .collection("Mission")
            .doc(lottieFileName)
            .update({'num': num, 'state': state});

        if (success) {
          successfulMissions['거리']?.add('5km');
        }
      }

      //10km
      if (missionData.distance == '10km') {
        String lottieFileName = "distance10";
        String state;
        int num;
        bool success = false;

        DocumentSnapshot snapshot = await firestore
            .collection("Users")
            .doc(user.uid)
            .collection("Mission")
            .doc(lottieFileName)
            .get();

        if (snapshot.exists) {
          var data = snapshot.data() as Map<String, dynamic>;
          num = data['num'] ?? 0;
          state = data['state'] ?? "bronze";

          if (double.parse(formattedDistance) >= 10.0) {
            num++;
            success = true;
          }

          if (num >= 10 && state != "gold") {
            num = 0;
            if (state == "bronze") {
              state = "silver";
            } else if (state == "silver") {
              state = "gold";
            }
          }
        } else {
          num = (double.parse(formattedDistance) >= 10.0) ? 1 : 0;
          state = "bronze";
        }

        await firestore
            .collection("Users")
            .doc(user.uid)
            .collection("Mission")
            .doc(lottieFileName)
            .update({'num': num, 'state': state});

        if (success) {
          successfulMissions['거리']?.add('10km');
        }
      }

      //time15
      if (missionData.time == '15분') {
        String lottieFileName = "time15";
        String state;
        int num;
        bool success = false;

        DocumentSnapshot snapshot = await firestore
            .collection("Users")
            .doc(user.uid)
            .collection("Mission")
            .doc(lottieFileName)
            .get();

        if (snapshot.exists) {
          var data = snapshot.data() as Map<String, dynamic>;
          num = data['num'] ?? 0;
          state = data['state'] ?? "bronze";

          if (totalMinutes >= 15.0) {
            num++;
            success = true;
          }

          if (num >= 10 && state != "gold") {
            num = 0;
            if (state == "bronze") {
              state = "silver";
            } else if (state == "silver") {
              state = "gold";
            }
          }
        } else {
          num = (totalMinutes >= 10.0) ? 1 : 0;
          state = "bronze";
        }

        await firestore
            .collection("Users")
            .doc(user.uid)
            .collection("Mission")
            .doc(lottieFileName)
            .update({'num': num, 'state': state});

        if (success) {
          successfulMissions['시간']?.add('15분');
        }
      }

      //time30
      if (missionData.time == '30분') {
        String lottieFileName = "time30";
        String state;
        int num;
        bool success = false;

        DocumentSnapshot snapshot = await firestore
            .collection("Users")
            .doc(user.uid)
            .collection("Mission")
            .doc(lottieFileName)
            .get();

        if (snapshot.exists) {
          var data = snapshot.data() as Map<String, dynamic>;
          num = data['num'] ?? 0;
          state = data['state'] ?? "bronze";

          if (totalMinutes >= 30.0) {
            num++;
            success = true;
          }

          if (num >= 10 && state != "gold") {
            num = 0;
            if (state == "bronze") {
              state = "silver";
            } else if (state == "silver") {
              state = "gold";
            }
          }
        } else {
          num = (totalMinutes >= 30.0) ? 1 : 0;
          state = "bronze";
        }

        await firestore
            .collection("Users")
            .doc(user.uid)
            .collection("Mission")
            .doc(lottieFileName)
            .update({'num': num, 'state': state});

        if (success) {
          successfulMissions['시간']?.add('30분');
        }
      }

      //time60
      if (missionData.time == '1시간') {
        String lottieFileName = "time60";
        String state;
        int num;
        bool success = false;

        DocumentSnapshot snapshot = await firestore
            .collection("Users")
            .doc(user.uid)
            .collection("Mission")
            .doc(lottieFileName)
            .get();

        if (snapshot.exists) {
          var data = snapshot.data() as Map<String, dynamic>;
          num = data['num'] ?? 0;
          state = data['state'] ?? "bronze";

          if (totalMinutes >= 60.0) {
            num++;
            success = true;
          }

          if (num >= 10 && state != "gold") {
            num = 0;
            if (state == "bronze") {
              state = "silver";
            } else if (state == "silver") {
              state = "gold";
            }
          }
        } else {
          num = (totalMinutes >= 60.0) ? 1 : 0;
          state = "bronze";
        }

        await firestore
            .collection("Users")
            .doc(user.uid)
            .collection("Mission")
            .doc(lottieFileName)
            .update({'num': num, 'state': state});

        if (success) {
          successfulMissions['시간']?.add('1시간');
        }
      }

      //pace 630
      if (missionData.pace == '630' && paceMinutes >= 0 && paceSeconds >= 0) {
        String lottieFileName = "pace630";
        String state;
        int num;
        bool success = false;

        DocumentSnapshot snapshot = await firestore
            .collection("Users")
            .doc(user.uid)
            .collection("Mission")
            .doc(lottieFileName)
            .get();

        if (snapshot.exists) {
          var data = snapshot.data() as Map<String, dynamic>;
          num = data['num'] ?? 0;
          state = data['state'] ?? "bronze";

          if (paceMinutes < 6 || (paceMinutes == 6 && paceSeconds <= 30)) {
            num++;
            success = true;
          }

          if (num >= 10 && state != "gold") {
            num = 0;
            if (state == "bronze") {
              state = "silver";
            } else if (state == "silver") {
              state = "gold";
            }
          }
        } else {
          num = (paceMinutes < 6 || (paceMinutes == 6 && paceSeconds <= 30))
              ? 1
              : 0;
          state = "bronze";
        }

        await firestore
            .collection("Users")
            .doc(user.uid)
            .collection("Mission")
            .doc(lottieFileName)
            .update({'num': num, 'state': state});

        if (success) {
          successfulMissions['페이스']?.add('630');
        }
      }

      //pace 600
      if (missionData.pace == '600' && paceMinutes >= 0 && paceSeconds >= 0) {
        String lottieFileName = "pace600";
        String state;
        int num;
        bool success = false;

        DocumentSnapshot snapshot = await firestore
            .collection("Users")
            .doc(user.uid)
            .collection("Mission")
            .doc(lottieFileName)
            .get();

        if (snapshot.exists) {
          var data = snapshot.data() as Map<String, dynamic>;
          num = data['num'] ?? 0;
          state = data['state'] ?? "bronze";

          if (paceMinutes < 6 || (paceMinutes == 6 && paceSeconds == 0)) {
            num++;
            success = true;
          }

          if (num >= 10 && state != "gold") {
            num = 0;
            if (state == "bronze") {
              state = "silver";
            } else if (state == "silver") {
              state = "gold";
            }
          }
        } else {
          num = (paceMinutes < 6 || (paceMinutes == 6 && paceSeconds == 0))
              ? 1
              : 0;
          state = "bronze";
        }

        await firestore
            .collection("Users")
            .doc(user.uid)
            .collection("Mission")
            .doc(lottieFileName)
            .update({'num': num, 'state': state});

        if (success) {
          successfulMissions['페이스']?.add('600');
        }
      }

      //pace 550
      if (missionData.pace == '550' && paceMinutes >= 0 && paceSeconds >= 0) {
        String lottieFileName = "pace550";
        String state;
        int num;
        bool success = false;

        DocumentSnapshot snapshot = await firestore
            .collection("Users")
            .doc(user.uid)
            .collection("Mission")
            .doc(lottieFileName)
            .get();

        if (snapshot.exists) {
          var data = snapshot.data() as Map<String, dynamic>;
          num = data['num'] ?? 0;
          state = data['state'] ?? "bronze";

          if (paceMinutes < 5 || (paceMinutes == 5 && paceSeconds == 50)) {
            num++;
            success = true;
          }

          if (num >= 10 && state != "gold") {
            num = 0;
            if (state == "bronze") {
              state = "silver";
            } else if (state == "silver") {
              state = "gold";
            }
          }
        } else {
          num = (paceMinutes < 5 || (paceMinutes == 5 && paceSeconds == 50))
              ? 1
              : 0;
          state = "bronze";
        }

        await firestore
            .collection("Users")
            .doc(user.uid)
            .collection("Mission")
            .doc(lottieFileName)
            .update({'num': num, 'state': state});

        if (success) {
          successfulMissions['페이스']?.add('550');
        }
      }

      await firestore
          .collection("Users")
          .doc(user.uid)
          .collection("Run record")
          .doc(timestamp)
          .set({'successfulMissions': successfulMissions},
              SetOptions(merge: true));
    }
  }

  static String _formatTime(int milliseconds) {
    int seconds = (milliseconds / 1000).floor();
    int minutes = (seconds / 60).floor();
    int hours = (minutes / 60).floor();
    String hoursStr = (hours % 60).toString().padLeft(2, '0');
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    return '$hoursStr:$minutesStr:$secondsStr';
  }

  static String _calculatePace(double distance, int milliseconds) {
    // 거리를 킬로미터로 변환
    double distanceKm = distance / 1000.0;

    // 거리가 1km 미만이거나 시간이 0이면 '--' 반환
    if (distanceKm < 1 || milliseconds == 0) {
      return "-'--''";
    }

    // 거리가 1km 이상이면 페이스 계산
    double minutes = milliseconds / 60000.0;
    double pace = minutes / distanceKm;

    // 분과 초로 분리
    int paceMinutes = pace.floor();
    int paceSeconds = ((pace - paceMinutes) * 60).round();

    // 두 자릿수 형식으로 맞춤
    String formattedSeconds = paceSeconds.toString().padLeft(2, '0');

    return "$paceMinutes'$formattedSeconds''";
  }
}

class RunData {
  final String duration;
  final String distance;
  final DateTime timestamp;
  final String pace;
  final List<Map<String, double>> routePoints;
  final String caloriesBurned;

  RunData({
    required this.duration,
    required this.distance,
    required this.pace,
    required this.timestamp,
    required this.routePoints,
    required this.caloriesBurned,
  });

  Map<String, dynamic> toJson() {
    return {
      'duration': duration,
      'distance': distance,
      'timestamp': timestamp,
      'route': routePoints,
      'pace': pace,
      'caloriesBurned': caloriesBurned,
    };
  }
}
