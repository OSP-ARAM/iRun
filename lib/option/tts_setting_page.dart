import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TTSSetting extends StatefulWidget {
  const TTSSetting({Key? key}) : super(key: key);

  static Future<void> loadSettings() async {
    _TTSSettingState instance = _TTSSettingState();
    await instance._loadSettings();
  }

  static String getLanguage() {
    _TTSSettingState instance = _TTSSettingState();
    return instance.language;
  }

  static Map<String, String> getVoice() {
    _TTSSettingState instance = _TTSSettingState();
    return instance.voice;
  }

  static String getEngine() {
    _TTSSettingState instance = _TTSSettingState();
    return instance.engine;
  }

  static double getVolume() {
    _TTSSettingState instance = _TTSSettingState();
    return instance.volume;
  }

  static double getPitch() {
    _TTSSettingState instance = _TTSSettingState();
    return instance.pitch;
  }

  static double getRate() {
    _TTSSettingState instance = _TTSSettingState();
    return instance.rate;
  }

  static bool getIsSetted() {
    _TTSSettingState instance = _TTSSettingState();
    return instance.isSetted;
  }

  static bool getIsWoman() {
    _TTSSettingState instance = _TTSSettingState();
    return instance.isWoman;
  }

  static bool getIsMan() {
    _TTSSettingState instance = _TTSSettingState();
    return instance.isMan;
  }

  @override
  State<TTSSetting> createState() => _TTSSettingState();
}

class _TTSSettingState extends State<TTSSetting> {
  final FlutterTts tts = FlutterTts();

  String language = "ko-KR";
  Map<String, String> voice = {"name": "ko-kr-x-ism-local", "locale": "ko-KR"};
  String engine = "com.google.android.tts";
  double volume = 1.2;
  double pitch = 1.0;
  double rate = 0.5;

  bool isSetted = false;
  bool isWoman = true;
  bool isMan = false;
  late List<bool> isSelected;

  final TextEditingController controller = TextEditingController();

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isSetted', isSetted);
    // 다른 설정도 유사한 방식으로 저장합니다...
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isSetted = prefs.getBool('isSetted') ?? false;
      // 다른 설정도 유사한 방식으로 불러옵니다...
    });
  }

  @override
  void initState() {
    super.initState();

    initTts();

    isSelected = [isWoman, isMan];

    _loadSettings();
  }

  @override
  void dispose() {
    _saveSettings();
    super.dispose();
  }

  initTts() async {
    tts.setLanguage(language);
    tts.setVoice(voice);
    tts.setEngine(engine);
    tts.setVolume(volume);
    tts.setPitch(pitch);
    tts.setSpeechRate(rate);
  }

  Future _speak(voiceText) async {
    tts.speak(voiceText);
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
      tts.setVoice(voice);
    });

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _saveSettings();
    });
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
              isSetted ? _speak('10km 1시간 페이스 30') : print(' ');
            },
            child: const Text('내용 읽기'),
          ),
        ],
      ),
    );
  }
}
