import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class BodyMeasurementPage extends StatefulWidget {
  @override
  _BodyMeasurementPageState createState() => _BodyMeasurementPageState();
}

class _BodyMeasurementPageState extends State<BodyMeasurementPage> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  bool _isMale = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원 정보 입력'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: '키 (cm)',
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: '몸무게 (kg)',
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '나이',
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(
                    IconData(0xe3c5, fontFamily: 'MaterialIcons'),
                    color: _isMale == true ? Colors.blue : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isMale = true;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(
                    IconData(0xe261, fontFamily: 'MaterialIcons'),
                    color: _isMale == false ? Colors.pink : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isMale = false;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                bool success = await saveBodyMeasurements();
                if (success) {
                  Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                }
              },
              child: Text('저장'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> saveBodyMeasurements() async {
    final String heightStr = _heightController.text;
    final String weightStr = _weightController.text;
    final String ageStr = _ageController.text;
    final bool gender = _isMale;

    if (heightStr.isEmpty || weightStr.isEmpty || ageStr.isEmpty) {
      _showErrorDialog('모든 필드를 채워주세요.');
      return false;
    }

    try {
      final double height = double.parse(heightStr);
      final double weight = double.parse(weightStr);
      final int age = int.parse(ageStr);

      if (height <= 0 || weight <= 0 || age <= 0) {
        _showErrorDialog('음의 정수, 0은 입력할 수 없습니다');
        return false;
      }

      // Firestore에 데이터 저장
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        await FirebaseFirestore.instance.collection('Users').doc(userId).update({
          'height': height,
          'weight': weight,
          'age': age,
          'gender': gender,
        });
        return true;
      }
    } catch (e) {
      _showErrorDialog('올바른 숫자로 입력해주세요.');
      return false;
    }
    return false;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('올바르지 않은 값'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}