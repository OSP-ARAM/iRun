import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TTSSetting extends StatefulWidget {
  static final TTSSettingState _instance = TTSSettingState();

  static Future<FlutterTts> getTtsWithSettings() async {
    await _instance.loadSettings();
    return _instance.tts;
  }

  const TTSSetting({Key? key}) : super(key: key);

  @override
  State<TTSSetting> createState() => TTSSettingState();
}

class TTSSettingState extends State<TTSSetting> {
  final FlutterTts tts = FlutterTts();

  String language = "ko-KR";
  Map<String, String> voice = {"name": "ko-kr-x-ism-local", "locale": "ko-KR"};
  String engine = "com.google.android.tts";
  double volume = 0.8;
  double pitch = 1.0;
  double rate = 0.5;

  bool isSetted = false;
  bool isWoman = true;
  bool isMan = false;
  late List<bool> isSelected;

  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (mounted) {
      setState(() {
        isSetted = prefs.getBool('isSetted') ?? false;
        isWoman = prefs.getBool('isWoman') ?? true;
        isMan = prefs.getBool('isMan') ?? false;
        isSelected = [isWoman, isMan];
        initTts();
      });
    }
  }

  Future<void> initTts() async {
    tts.setLanguage(language);
    tts.setVoice(voice);
    tts.setEngine(engine);
    tts.setVolume(volume);
    tts.setPitch(pitch);
    tts.setSpeechRate(rate);
  }

  Future<void> speak(voiceText) async {
    try {
      await tts.speak(voiceText);
    } catch (e) {
      print('Failed to speak: $e');
    }
  }

  void toggleSelect(value) {
    if (value == 0) {
      isWoman = true;
      isMan = false;
      voice = {"name": "ko-kr-x-ism-local", "locale": "ko-KR"};
    } else {
      isWoman = false;
      isMan = true;
      voice = {"name": "ko-kr-x-koc-local", "locale": "ko-KR"};
    }
    setState(() {
      isSelected = [isWoman, isMan];
      print(voice);
      tts.setVoice(voice);
    });
  }

  @override
  void dispose() {
    saveSettings();
    super.dispose();
  }

  void saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isSetted', isSetted);
    prefs.setBool('isWoman', isWoman);
    prefs.setBool('isMan', isMan);
  }

  // 공유 설정 저장 및 불러오기
  static Future<void> saveIsSetted(bool isSetted) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isSetted', isSetted);
  }

  static Future<bool> getIsSetted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isSetted') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TTS 설정'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'TTS 설정 ',
                textAlign: TextAlign.start,
              ),
              Switch(
                value: isSetted,
                onChanged: (value) {
                  setState(() {
                    isSetted = value;
                    saveIsSetted(value);
                  });
                },
                activeColor: Colors.purple,
              ),
            ],
          ),
          ToggleButtons(
            direction: Axis.horizontal,
            isSelected: isSelected,
            onPressed: toggleSelect,
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '여성',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '남성',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              print(voice);
              isSetted ? speak('10km 1시간 페이스 30') : print(' ');
            },
            child: const Text('내용 읽기'),
          ),
        ],
      ),
    );
  }
}