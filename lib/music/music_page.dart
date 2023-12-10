import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

void _audioPlayerTaskEntrypoint() {
  AudioServiceBackground.run(() => AudioPlayerTask());
}

class MusicPage extends StatelessWidget {
  const MusicPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // 현재 화면에서 뒤로 이동
        Navigator.of(context).pop();
        // 오디오 재생은 계속 실행됩니다
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Music Player'),
        ),
        body: const AudioServiceWidget(child: MusicPlayer()),
      ),
    );
  }
}


class MusicPlayer extends StatefulWidget {
  const MusicPlayer({Key? key}) : super(key: key);

  @override
  _MusicPlayerState createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  late AudioPlayer _player;
  final List<String> _audioFiles = [
    "assets/music/song1.ogg",
    "assets/music/song2.ogg",
    "assets/music/song3.ogg",
  ];
  late String _currentPlaying;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _currentPlaying = _audioFiles.first;
    _startBackgroundTask();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _startBackgroundTask() async {
    await AudioService.start(
      backgroundTaskEntrypoint: _audioPlayerTaskEntrypoint,
      androidNotificationChannelName: 'Music Player',
      androidNotificationColor: 0xFF2196f3,
      androidNotificationIcon: 'mipmap/ic_launcher',
    );
  }

  void _playAudio(String path) async {
    var uri = Uri.parse('asset:///$path');
    await _player.setAudioSource(AudioSource.uri(uri));
    await _player.play();
    setState(() {
      _currentPlaying = path;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            itemCount: _audioFiles.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('Track ${index + 1}'),
                onTap: () => _playAudio(_audioFiles[index]),
                selected: _currentPlaying == _audioFiles[index],
              );
            },
          ),
        ),
        _buildControlBar(),
      ],
    );
  }

  Widget _buildControlBar() {
    return Container(
      color: Colors.blueGrey,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () => _playAudio(_currentPlaying),
          ),
          IconButton(
            icon: const Icon(Icons.pause),
            onPressed: () => _player.pause(),
          ),
          IconButton(
            icon: const Icon(Icons.stop),
            onPressed: () => _player.stop(),
          ),
        ],
      ),
    );
  }
}

class AudioPlayerTask extends BackgroundAudioTask {
  final _audioPlayer = AudioPlayer();

  @override
  Future<void> onStart(Map<String, dynamic>? params) async {
    var mediaItem = const MediaItem(
      id: 'asset:///assets/music/song1.ogg',
      album: 'Album name',
      title: 'Track title',
      artist: 'Artist name',
    );
    AudioServiceBackground.setMediaItem(mediaItem);

    await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(mediaItem.id)));
    onPlay();
  }

  @override
  Future<void> onPlay() async {
    AudioServiceBackground.setState(
      controls: [MediaControl.pause, MediaControl.stop],
      playing: true,
      processingState: AudioProcessingState.ready,
    );
    await _audioPlayer.play();
  }

  @override
  Future<void> onPause() async {
    await _audioPlayer.pause();
  }

  @override
  Future<void> onStop() async {
    await _audioPlayer.stop();
    await super.onStop();
  }
}
