import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomIconPickerDialog extends StatefulWidget {
  const CustomIconPickerDialog({super.key});

  @override
  _CustomIconPickerDialogState createState() => _CustomIconPickerDialogState();
}

class CustomIconPicker extends StatefulWidget {
  const CustomIconPicker({super.key});

  static Future<Map<String, String?>?> show(BuildContext context) async {
    return await showDialog<Map<String, String?>>(
      context: context,
      builder: (BuildContext context) {
        return const CustomIconPickerDialog();
      },
    );
  }

  @override
  _CustomIconPickerState createState() => _CustomIconPickerState();
}

class _CustomIconPickerState extends State<CustomIconPicker> {
  IconData? selectedTimeIcon;
  IconData? selectedDistanceIcon;
  IconData? selectedPaceIcon;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        height: 300,
        width: 300,
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 3,
          children: [
            // 시간 카테고리 아이콘
            IconSelector(
              category: '시간',
              icon: Icons.access_alarm,
              selectedIcon: selectedTimeIcon,
              onIconSelected: (icon) {
                setState(() {
                  selectedTimeIcon = icon;
                });
              },
            ),
            // ... 다른 시간 카테고리 아이콘들

            // 거리 카테고리 아이콘
            IconSelector(
              category: '거리',
              icon: Icons.map,
              selectedIcon: selectedDistanceIcon,
              onIconSelected: (icon) {
                setState(() {
                  selectedDistanceIcon = icon;
                });
              },
            ),
            // ... 다른 거리 카테고리 아이콘들

            // 페이스 카테고리 아이콘
            IconSelector(
              category: '페이스',
              icon: Icons.directions_run,
              selectedIcon: selectedPaceIcon,
              onIconSelected: (icon) {
                setState(() {
                  selectedPaceIcon = icon;
                });
              },
            ),
            // ... 다른 페이스 카테고리 아이콘들
          ],
        ),
      ),
    );
  }
}

class IconSelector extends StatelessWidget {
  final String category;
  final IconData icon;
  final IconData? selectedIcon;
  final Function(IconData) onIconSelected;

  const IconSelector({
    super.key,
    required this.category,
    required this.icon,
    required this.selectedIcon,
    required this.onIconSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(category),
        IconButton(
          icon: Icon(icon,
              size: 40,
              color: icon == selectedIcon ? Colors.blue : Colors.black),
          onPressed: () {
            onIconSelected(icon);
          },
        ),
      ],
    );
  }
}

class _CustomIconPickerDialogState extends State<CustomIconPickerDialog> {
  String? selectedTimeText;
  String? selectedDistanceText;
  String? selectedPaceText;

  void _handleDone() {
    // Provider를 통해 현재 컨텍스트의 MissionData에 접근
    final missionData = Provider.of<MissionData>(context, listen: false);

    // 선택된 미션 데이터로 MissionData 객체 업데이트
    missionData.time = selectedTimeText;
    missionData.distance = selectedDistanceText;
    missionData.pace = selectedPaceText;

    Navigator.of(context).pop();
  }

  void _resetSelections() {
    // Provider를 통해 현재 컨텍스트의 MissionData에 접근
    final missionData = Provider.of<MissionData>(context, listen: false);

    // 선택된 미션 데이터로 MissionData 객체 업데이트
    missionData.time = null;
    missionData.distance = null;
    missionData.pace = null;

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        height: 350,
        width: 300,
        padding: const EdgeInsets.all(17),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CategoryRow(
              category: '거리',
              texts: const ['3km', '5km', '10km'],
              selectedText: selectedDistanceText,
              onTextSelected: (text) {
                setState(() {
                  selectedDistanceText = text;
                });
              },
            ),
            CategoryRow(
              category: '시간',
              texts: const ['15분', '30분', '1시간'],
              selectedText: selectedTimeText,
              onTextSelected: (text) {
                setState(() {
                  selectedTimeText = text;
                });
              },
            ),
            CategoryRow(
              category: '페이스',
              texts: const ['630', '600', '550'],
              selectedText: selectedPaceText,
              onTextSelected: (text) {
                setState(() {
                  selectedPaceText = text;
                });
              },
            ),
            ElevatedButton(
              onPressed: _handleDone,
              child: const Text('완료'),
            ),
            ElevatedButton(
              onPressed: _resetSelections,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.red, // Optional: Change the color if needed
              ),
              child: const Text('초기화'),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryRow extends StatelessWidget {
  final String category;
  final List<String> texts;
  final String? selectedText;
  final Function(String) onTextSelected;

  const CategoryRow({
    super.key,
    required this.category,
    required this.texts,
    required this.selectedText,
    required this.onTextSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Text(
            category,
            style: const TextStyle(
              fontWeight: FontWeight.bold, // 글씨를 굵게 설정
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: texts.map((text) {
              return TextButton(
                onPressed: () {
                  onTextSelected(text);
                },
                child: Text(
                  text,
                  style: TextStyle(
                    color: text == selectedText ? Colors.blue : Colors.black,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class MissionData extends ChangeNotifier {
  String? _time;
  String? _distance;
  String? _pace;

  String? get time => _time;
  set time(String? newTime) {
    _time = newTime;
    notifyListeners();
  }

  String? get distance => _distance;
  set distance(String? newDistance) {
    _distance = newDistance;
    notifyListeners();
  }

  String? get pace => _pace;
  set pace(String? newPace) {
    _pace = newPace;
    notifyListeners();
  }
}
