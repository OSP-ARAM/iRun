import 'package:flutter/material.dart';

class MenuBottom extends StatefulWidget {
  final int currentIndex; // 추가: 현재 선택된 인덱스를 받을 변수
  const MenuBottom({
    Key? key,
    required this.currentIndex, // 추가: 생성자에서 currentIndex 받기
  }) : super(key: key);

  @override
  _MenuBottomState createState() => _MenuBottomState();
}

class _MenuBottomState extends State<MenuBottom> {
  late int _selectedIndex; // 변경: 선택된 인덱스 변수를 위젯의 인덱스로 초기화

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex; // 변경: initState에서 현재 인덱스 설정
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (int index) {
        setState(() {
          _selectedIndex = index;
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/log');
              break;
            case 1:
              Navigator.pushNamed(context, '/ranking');
              break;
            case 2:
              Navigator.pushNamed(context, '/Achievements');
              break;
            default:
          }
        });
      },
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: '기록',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.leaderboard),
          label: '랭킹',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.star),
          label: '업적',
        ),
      ],
      selectedItemColor: Colors.blue,
    );
  }
}

