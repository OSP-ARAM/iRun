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
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TTS 설정'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text(
                    'TTS 켜기 ',
                    style: TextStyle(fontSize: 18),
                  ),
                  Switch(
                    value: isSetted,
                    onChanged: (value) {
                      setState(() {
                        isSetted = value;
                      });
                    },
                    activeColor: Colors.purple,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ToggleButtons(
                    direction: Axis.horizontal,
                    isSelected: isSelected,
                    onPressed: toggleSelect,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: SizedBox(
                          width: screenWidth / 3 - 60, // 화면 너비의 절반 크기로 설정
                          child: const Text(
                            '여성',
                            style: TextStyle(fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: SizedBox(
                          width: screenWidth / 3 - 60, // 화면 너비의 절반 크기로 설정
                          child: const Text(
                            '남성',
                            style: TextStyle(fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Text(
              '웹으로 작동 시 남성 TTS의 목소리는 작동하지 않습니다.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
