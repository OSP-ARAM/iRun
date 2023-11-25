import 'package:flutter/material.dart';

class CustomIconPicker {
  static Future<IconData?> show(BuildContext context) async {
    return await showDialog<IconData?>(
      context: context,
      builder: (BuildContext context) {
        IconData? selectedIcon;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            height: 300,
            width: 300,
            padding: EdgeInsets.all(16),
            child: GridView.count(
              crossAxisCount: 3,
              children: [
                IconButton(
                  icon: Icon(Icons.access_alarm, size: 40),
                  onPressed: () {
                    Navigator.of(context).pop(Icons.access_alarm);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.access_time, size: 40),
                  onPressed: () {
                    Navigator.of(context).pop(Icons.access_time);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.account_balance, size: 40),
                  onPressed: () {
                    Navigator.of(context).pop(Icons.account_balance);
                  },
                ),
                // Add more icons here...
              ],
            ),
          ),
        );
      },
    );
  }
}

