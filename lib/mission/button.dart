import 'package:flutter/material.dart';
import 'package:irun/mission/mission_page.dart';

class CustomIconButton extends StatefulWidget {
  const CustomIconButton({Key? key}) : super(key: key);

  @override
  _CustomIconButtonState createState() => _CustomIconButtonState();
}

class _CustomIconButtonState extends State<CustomIconButton> {
  IconData selectedIcon = Icons.star; // 기본 아이콘은 +로 설정

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final result = await CustomIconPicker.show(context);
        if (result != null && result.containsKey('시간')) { // 예를 들어 '시간' 카테고리 선택
          setState(() {
            selectedIcon = Icons.star; // 선택된 아이콘으로 업데이트
          });
        }
      },
      splashColor: Colors.grey,
      borderRadius: BorderRadius.circular(40.0),
      child: Container(
        width: 50.0,
        height: 50.0,
        decoration: BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            selectedIcon,
            color: Colors.white,
            size: 30.0,
          ),
        ),
      ),
    );
  }
}