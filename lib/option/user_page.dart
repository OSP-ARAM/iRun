import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:irun/login/login_api.dart';

final User? user = auth.currentUser;

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String photoURL = user!.photoURL!;

  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  bool _isEditingAge = false;
  bool _isEditingHeight = false;
  bool _isEditingWeight = false;
  bool _isEditingGender = false;

  double height = 0.0;
  double weight = 0.0;
  int age = 0;
  bool gender = false;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      getUserData(user!.uid);
    }
  }

  Future<void> getUserData(String uid) async {
    DocumentSnapshot userSnapshot =
    await firestore.collection('Users').doc(uid).get();
    Map<String, dynamic> userData =
        userSnapshot.data() as Map<String, dynamic>? ?? {};

    setState(() {
      height = (userData['height'] as num).toDouble();
      weight = (userData['weight'] as num).toDouble();
      age = (userData['age'] as num).toInt();
      gender = userData['gender'];

      _ageController.text = age.toString();
      _heightController.text = height.toString();
      _weightController.text = weight.toString();
    });
  }

  void _toggleEditingAge() {
    setState(() {
      if (_isEditingAge) _saveChanges();
      _isEditingAge = !_isEditingAge;
    });
  }

  void _toggleEditingHeight() {
    setState(() {
      if (_isEditingHeight) _saveChanges();
      _isEditingHeight = !_isEditingHeight;
    });
  }

  void _toggleEditingWeight() {
    setState(() {
      if (_isEditingWeight) _saveChanges();
      _isEditingWeight = !_isEditingWeight;
    });
  }

  void _saveChanges() {
    final updatedAge = int.tryParse(_ageController.text) ?? age;
    final updatedHeight = double.tryParse(_heightController.text) ?? height;
    final updatedWeight = double.tryParse(_weightController.text) ?? weight;

    firestore.collection('Users').doc(user!.uid).update({
      'age': updatedAge,
      'height': updatedHeight,
      'weight': updatedWeight,
      'gender' : gender,
    });

    setState(() {
      age = updatedAge;
      height = updatedHeight;
      weight = updatedWeight;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 프로필'),
      ),
      body: SingleChildScrollView( // SingleChildScrollView 추가
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 50.0, bottom: 30),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.network(photoURL),
                    ),
                  ),
                  Text(
                    user!.displayName ?? ' ',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            Divider(
              height: 30,
              indent: 30,
              endIndent: 30,
              color: Colors.grey[800],
            ),
            _buildEditableRow('나이 : ', _ageController, '세', _isEditingAge, _toggleEditingAge),
            Divider(height: 30, indent: 30, endIndent: 30, color: Colors.grey[800]),
            _buildGenderRow(),
            Divider(height: 30, indent: 30, endIndent: 30, color: Colors.grey[800]),
            _buildEditableRow('키 : ', _heightController, 'cm', _isEditingHeight, _toggleEditingHeight),
            Divider(height: 30, indent: 30, endIndent: 30, color: Colors.grey[800]),
            _buildEditableRow('몸무게 : ', _weightController, 'kg', _isEditingWeight, _toggleEditingWeight),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableRow(String label, TextEditingController controller, String unit, bool isEditing, VoidCallback toggleEditing) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          isEditing
              ? Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
            ),
          )
              : Text('${controller.text} $unit', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          IconButton(
            icon: Icon(isEditing ? Icons.check : Icons.edit),
            onPressed: toggleEditing,
          ),
        ],
      ),
    );
  }


  Widget _buildGenderRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: Row(
        children: [
          Text('성별 : ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          _isEditingGender
              ? Row(
            children: [
              GestureDetector(
                onTap: () => setState(() { gender = true; }),
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: Text('남자', style: TextStyle(fontSize: 18, color: gender ? Colors.blue : Colors.grey)),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() { gender = false; }),
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: Text('여자', style: TextStyle(fontSize: 18, color: !gender ? Colors.pink : Colors.grey)),
                ),
              ),
            ],
          )
              : Text(gender ? '남자' : '여자', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          IconButton(
            icon: Icon(_isEditingGender ? Icons.check : Icons.edit),
            onPressed: () => setState(() {
              if (_isEditingGender) _saveChanges();
              _isEditingGender = !_isEditingGender;
            }),
          ),
        ],
      ),
    );
  }
}