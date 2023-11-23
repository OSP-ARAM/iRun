import 'package:flutter/material.dart';
import 'package:irun/mission/mission_page.dart';

class CustomIconButton extends StatefulWidget {
  const CustomIconButton({Key? key}) : super(key: key);

  @override
  _CustomIconButtonState createState() => _CustomIconButtonState();
}

class _CustomIconButtonState extends State<CustomIconButton> {
  IconData selectedIcon = Icons.add; // 기본 아이콘은 +로 설정

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final icon = await CustomIconPicker.show(context);
        if (icon != null) {
          setState(() {
            selectedIcon = icon;
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