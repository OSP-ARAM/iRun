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
    // MissionData에 접근하여 데이터 업데이트
    final missionData = Provider.of<MissionData>(context, listen: false);
    missionData.time = selectedTimeText;
    missionData.distance = selectedDistanceText;
    missionData.pace = selectedPaceText;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Dialog(
      backgroundColor: Colors.brown[200], // Dialog 배경색을 회색으로 변경
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        padding: const EdgeInsets.all(17),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              '거리',
              style: theme.textTheme.headline6!.copyWith(fontWeight: FontWeight.bold),
            ),
            _buildButtonBar(['3km', '5km', '10km'], selectedDistanceText),
            Text(
              '시간',
              style: theme.textTheme.headline6!.copyWith(fontWeight: FontWeight.bold),
            ),
            _buildButtonBar(['15분', '30분', '1시간'], selectedTimeText),
            Text(
              '페이스',
              style: theme.textTheme.headline6!.copyWith(fontWeight: FontWeight.bold),
            ),
            _buildButtonBar(['630', '600', '550'], selectedPaceText),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: _handleDone,
                child: Text(
                  '완료',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.brown[400],
                  onPrimary: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonBar(List<String> labels, String? selectedLabel) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8.0, // 각 버튼 사이의 공간
      children: labels.map((label) {
        return ChoiceChip(
          label: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          selected: label == selectedLabel,
          onSelected: (bool selected) {
            setState(() {
              if (label.endsWith('km')) {
                selectedDistanceText = selected ? label : null;
              } else if (label.endsWith('분') || label == '1시간') {
                selectedTimeText = selected ? label : null;
              } else {
                selectedPaceText = selected ? label : null;
              }
            });
          },
          selectedColor: Colors.yellow,
          backgroundColor: Colors.grey[200],
          labelStyle: TextStyle(
            color: label == selectedLabel ? Colors.black : Colors.grey,
            fontWeight: FontWeight.bold, // 선택되지 않은 버튼의 글씨도 굵게
          ),
        );
      }).toList(),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              category,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange, // 메인 컬러 적용
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Wrap(
              spacing: 8.0,
              children: texts.map((text) {
                bool isSelected = text == selectedText;
                return ChoiceChip(
                  label: Text(text),
                  selected: isSelected,
                  onSelected: (_) => onTextSelected(text),
                  selectedColor: Colors.yellow,
                  backgroundColor: Colors.grey.shade200,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.black : Colors.grey.shade600,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
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

  void reset() {
    _time = null;
    _distance = null;
    _pace = null;
    notifyListeners();
  }
}
