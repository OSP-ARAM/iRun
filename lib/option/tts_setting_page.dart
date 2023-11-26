import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TTSSetting extends StatefulWidget {
  const TTSSetting({super.key});

  @override
  State<TTSSetting> createState() => _TTSSettingState();
}

class _TTSSettingState extends State<TTSSetting> {
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

    // TTS 초기 설정
    initTts();

    // 여성, 남성 결정
    isSelected = [isWoman, isMan];
  }

  // TTS 초기 설정
  initTts() async {
    //await initTtsIosOnly(); // iOS 설정

    tts.setLanguage(language);
    tts.setVoice(voice);
    tts.setEngine(engine);
    tts.setVolume(volume);
    tts.setPitch(pitch);
    tts.setSpeechRate(rate);
  }

  // // TTS iOS 옵션
  // Future<void> initTtsIosOnly() async {
  //   // iOS 전용 옵션 : 공유 오디오 인스턴스 설정
  //   await tts.setSharedInstance(true);

  //   // 배경 음악와 인앱 오디오 세션을 동시에 사용
  //   await tts.setIosAudioCategory(
  //       IosTextToSpeechAudioCategory.ambient,
  //       [
  //         IosTextToSpeechAudioCategoryOptions.allowBluetooth,
  //         IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
  //         IosTextToSpeechAudioCategoryOptions.mixWithOthers
  //       ],
  //       IosTextToSpeechAudioMode.voicePrompt);
  // }

  // TTS로 읽어주기
  Future _speak(voiceText) async {
    tts.speak(voiceText);
  }

  //여성, 남성 토글 선택
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
              child: const Text('내용 읽기')),
        ],
      ),
    );
  }
}
