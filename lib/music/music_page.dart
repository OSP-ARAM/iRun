import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:rxdart/rxdart.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  const PositionData(
      this.position,
      this.bufferedPosition,
      this.duration,
      );
}

class AudioPlayerManager {
  static AudioPlayerManager? _instance;
  late AudioPlayer _audioPlayer;

  AudioPlayerManager._internal() {
    _audioPlayer = AudioPlayer();
    _init();
  }

  static void createInstance() {
    _instance ??= AudioPlayerManager._internal();
  }


  Future<void> _init() async {

    final _playlist = ConcatenatingAudioSource(
      children: [
        AudioSource.uri(
          Uri.parse('asset:///assets/music/song1.ogg'),
          tag: MediaItem(
            id: '0',
            title: 'Super Shy',
            artist: 'NewJeans',
            artUri: Uri.parse('https://i.namu.wiki/i/Knu15tihmUyeZaTd9CMftgs5x2cbD9Q4lXz28j5YF4EkRGreeP5PLU339jxOZbC-Mk71mkr-8a9OVxraySbdUUVTEj-y2MHlQeif58GdvICPfbm4JuXMkgoYSysl-Wpw87eqmKBJ08FtPtYyXZqiEA.webp')
          ),
        ),
        AudioSource.uri(
          Uri.parse('asset:///assets/music/song2.ogg'),
          tag: MediaItem(
            id: '1',
            title: '질풍가도',
            artist: '유정석',
            artUri: Uri.parse('https://imgproxy.mapia.io/v3/9XKgUfakRRq2IlajQkTyWxqbs-3We0x2/g:ce/rs:fit:967:1395:true/aHR0cHM6Ly9tZnMu/cGQubWFwaWEuaW8v/cHVibGljL2ZpbGUv/NGUyNDExNDVhM2My/MmJiM2JkM2JiYTY5/MTVhZTg3MzgvZG93/bmxvYWQ_U2Vydmlj/ZS1Qcm92aWRlcj1t/bXM.jpg')
          ),
        ),
        AudioSource.uri(
          Uri.parse('asset:///assets/music/song3.ogg'),
          tag: MediaItem(
              id: '2',
              title: '너의 번호를 누르고',
              artist: '안녕',
              artUri: Uri.parse('https://image.bugsm.co.kr/album/images/500/9589/958964.jpg')
          ),
        ),
      ],
    );

    await _audioPlayer.setAudioSource(_playlist);
  }

  void dispose() {
    _audioPlayer.dispose();
    _instance = null;
  }

  static bool get isInstanceCreated => _instance != null;

  static AudioPlayerManager? get instance => _instance;

  AudioPlayer get audioPlayer => _audioPlayer;
}

class MusicPlayerPage extends StatefulWidget {
  const MusicPlayerPage({Key? key}) : super(key: key);

  @override
  _MusicPlayerPageState createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage> {
  late AudioPlayer _audioPlayer;



  @override
  void initState() {
    super.initState();
    AudioPlayerManager.createInstance();
    if (AudioPlayerManager.isInstanceCreated) {
      _audioPlayer = AudioPlayerManager._instance!.audioPlayer;
    }
  }

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        _audioPlayer.positionStream,
        _audioPlayer.bufferedPositionStream,
        _audioPlayer.durationStream,
            (position, bufferedPosition, duration) =>
            PositionData(
              position,
              bufferedPosition,
              duration ?? Duration.zero,
            ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            colors: [Colors.yellow, Colors.grey],//[Color(0xFF144771), Color(0xFF071A2C)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder<SequenceState?>(
              stream: _audioPlayer.sequenceStateStream,
              builder: (context, snapshot) {
                final state = snapshot.data;
                if (state?.sequence.isEmpty ?? true) {
                  return const SizedBox();
                }
                final metadata = state!.currentSource!.tag as MediaItem;
                return MediaMetadata(
                  imageUrl: metadata.artUri.toString(),
                  title: metadata.title,
                  artist: metadata.artist!,
                );
              },
            ),
            const SizedBox(height: 20),
            StreamBuilder<PositionData>(
              stream: _positionDataStream,
              builder: (context, snapshot) {
                final positionData = snapshot.data;
                return ProgressBar(
                  baseBarColor: Colors.grey[600],
                  bufferedBarColor: Colors.grey,
                  progressBarColor: Colors.red,
                  thumbColor: Colors.red,
                  timeLabelTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  progress: positionData?.position ?? Duration.zero,
                  buffered: positionData?.bufferedPosition ?? Duration.zero,
                  total: positionData?.duration ?? Duration.zero,
                  onSeek: _audioPlayer.seek,
                );
              },
            ),
            const SizedBox(height: 20),
            Controls(audioPlayer: _audioPlayer),
          ],
        ),
      ),
    );
  }
}

class MediaMetadata extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String artist;

  const MediaMetadata({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.artist,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                offset: Offset(2, 4),
                blurRadius: 4,
              ),
            ],
            borderRadius: BorderRadius.circular(10),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              height: 300,
              width: 300,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          artist,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class Controls extends StatelessWidget {
  final AudioPlayer audioPlayer;

  const Controls({
    Key? key,
    required this.audioPlayer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: audioPlayer.seekToPrevious,
          iconSize: 60,
          color: Colors.white,
          icon: const Icon(Icons.skip_previous_rounded),
        ),
        StreamBuilder<PlayerState>(
          stream: audioPlayer.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final playing = playerState?.playing ?? false;
            return IconButton(
              onPressed: playing ? audioPlayer.pause : audioPlayer.play,
              iconSize: 80,
              color: Colors.white,
              icon: Icon(playing ? Icons.pause : Icons.play_arrow),
            );
          },
        ),
        IconButton(
          onPressed: audioPlayer.seekToNext,
          iconSize: 60,
          color: Colors.white,
          icon: const Icon(Icons.skip_next_rounded),
        ),
      ],
    );
  }
}

//네비게이션 바

class MusicPlayerNavigationBar extends StatefulWidget {
  final AudioPlayer audioPlayer;

  const MusicPlayerNavigationBar({
    Key? key,
    required this.audioPlayer,
  }) : super(key: key);

  @override
  _MusicPlayerNavigationBarState createState() => _MusicPlayerNavigationBarState();
}

class _MusicPlayerNavigationBarState extends State<MusicPlayerNavigationBar> {
  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        widget.audioPlayer.positionStream,
        widget.audioPlayer.bufferedPositionStream,
        widget.audioPlayer.durationStream,
            (position, bufferedPosition, duration) =>
            PositionData(
              position,
              bufferedPosition,
              duration ?? Duration.zero,
            ),
      );

  @override
  Widget build(BuildContext context) {
    bool instanceExists = AudioPlayerManager.isInstanceCreated;

    return StreamBuilder<bool>(
      stream: widget.audioPlayer.playingStream,
      builder: (context, snapshot) {
        // 재생 중일 때만 네비게이션 바 표시
        return Offstage(
          offstage: !instanceExists,
          child: BottomAppBar(
            color: Colors.yellow, // 배경 색을 노란색으로 설정
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 0.0), // 패딩 조정
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StreamBuilder<PositionData>(
                    stream: _positionDataStream,
                    builder: (context, snapshot) {
                      final positionData = snapshot.data;
                      return ProgressBar(
                        baseBarColor: Colors.grey[600],
                        bufferedBarColor: Colors.grey,
                        progressBarColor: Colors.red,
                        thumbColor: Colors.red,
                        timeLabelTextStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 0,
                          fontWeight: FontWeight.w600,
                        ),
                        barHeight: 3.0, // 프로그레스 바 높이 조정
                        thumbRadius: 3.0, // 프로그레스 바 텀브 크기 조정
                        progress: positionData?.position ?? Duration.zero,
                        buffered: positionData?.bufferedPosition ?? Duration.zero,
                        total: positionData?.duration ?? Duration.zero,
                        onSeek: widget.audioPlayer.seek,
                      );
                    },
                  ),
                  SizedBox(height: 0.0), // 추가된 여분의 공간
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.skip_previous,
                        size: 30),
                        onPressed: () => widget.audioPlayer.seekToPrevious(),
                      ),
                      IconButton(
                        icon: const Icon(Icons.play_arrow,
                            size: 30),
                        onPressed: () => widget.audioPlayer.play(),
                      ),
                      IconButton(
                        icon: const Icon(Icons.pause,
                            size: 30),
                        onPressed: () => widget.audioPlayer.pause(),
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next,
                            size: 30),
                        onPressed: () => widget.audioPlayer.seekToNext(),
                      ),
                      IconButton(
                          icon: const Icon(Icons.close,
                              size: 30),
                          onPressed: () {
                            if (AudioPlayerManager.isInstanceCreated) {
                              AudioPlayerManager.instance!.dispose();
                            }
                            setState(() {}); // 상태 갱신
                          }
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
