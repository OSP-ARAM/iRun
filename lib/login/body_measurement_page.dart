import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BodyMeasurementPage extends StatefulWidget {
  @override
  _BodyMeasurementPageState createState() => _BodyMeasurementPageState();
}

class _BodyMeasurementPageState extends State<BodyMeasurementPage> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

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
            SizedBox(height: 16),
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

    if (heightStr.isEmpty || weightStr.isEmpty) {
      _showErrorDialog('모든 필드를 채워주세요.');
      return false;
    }

    try {
      final double height = double.parse(heightStr);
      final double weight = double.parse(weightStr);

      if (height <= 0 || weight <= 0) {
        _showErrorDialog('키와 몸무게는 양의 숫자여야 합니다.');
        return false;
      }

      // Firestore에 데이터 저장
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        await FirebaseFirestore.instance.collection('Users').doc(userId).update({
          'height': height,
          'weight': weight,
        });
        return true;
      }
    } catch (e) {
      _showErrorDialog('키와 몸무게를 올바른 숫자로 입력해주세요.');
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