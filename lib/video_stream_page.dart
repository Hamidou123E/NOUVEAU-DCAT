import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';

class VideoStreamPage extends StatefulWidget {
  @override
  _VideoStreamPageState createState() => _VideoStreamPageState();
}

class _VideoStreamPageState extends State<VideoStreamPage> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  Timer? _positionUpdater; // Timer pour mettre à jour le slider

  @override
  void initState() {
    super.initState();
    _initializeVideo();

    _positionUpdater = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted && _controller.value.isInitialized && _controller.value.isPlaying) {
        setState(() {});
      }
    });
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.network(
      'https://live.dcat.ci/hls/stream.m3u8',
    );

    try {
      await _controller.initialize();
      _controller.setVolume(0.5);

      _controller.addListener(() {
        if (mounted) setState(() {});
      });

      setState(() {
        _isPlaying = true;
        _controller.play();
      });
    } catch (e) {
      print("Erreur de chargement de la vidéo : $e");
    }
  }

  @override
  void dispose() {
    _positionUpdater?.cancel(); // Nettoyage du timer
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
      _isPlaying = !_isPlaying;
    });
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  String _formatDate(DateTime date) {
    return "${date.day} ${[
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre'
    ][date.month - 1]} ${date.year}";
  }

  void _toggleFullScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenVideoPlayer(controller: _controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: AspectRatio(
            aspectRatio: 16 / 12,
            child: Stack(
              children: [
                _controller.value.isInitialized
                    ? VideoPlayer(_controller)
                    : const Center(child: CircularProgressIndicator()),

                // Logo
                Positioned(
                  top: 8,
                  left: 8,
                  child: Image.asset(
                    'assets/logo1.png',
                    width: 50,
                    height: 50,
                    fit: BoxFit.contain,
                  ),
                ),

                // Date et heure
                Positioned(
                  top: 8,
                  right: 8,
                  child: StreamBuilder<DateTime>(
                    stream: Stream.periodic(Duration(seconds: 1), (_) => DateTime.now()),
                    builder: (context, snapshot) {
                      final now = snapshot.data ?? DateTime.now();
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatDate(now),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Contrôles vidéo
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.skip_previous, color: Colors.white),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                              ),
                              onPressed: _togglePlayPause,
                            ),
                            IconButton(
                              icon: Icon(Icons.skip_next, color: Colors.white),
                              onPressed: () {},
                            ),
                            Expanded(
                              child: Slider(
                                value: _controller.value.position.inSeconds.toDouble().clamp(
                                    0.0, _controller.value.duration.inSeconds.toDouble()),
                                min: 0.0,
                                max: _controller.value.duration.inSeconds.toDouble(),
                                onChanged: (value) {
                                  _controller.seekTo(Duration(seconds: value.toInt()));
                                },
                                activeColor: Colors.white,
                                inactiveColor: Colors.white54,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.fullscreen, color: Colors.white),
                              onPressed: _toggleFullScreen,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatTime(_controller.value.position),
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                            Text(
                              _formatTime(_controller.value.duration),
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0F1C2E),
      body: isLandscape
          ? Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            )
          : content,
    );
  }
}

class FullScreenVideoPlayer extends StatelessWidget {
  final VideoPlayerController controller;

  const FullScreenVideoPlayer({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context); // Quitte le plein écran
          },
          child: AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: VideoPlayer(controller),
          ),
        ),
      ),
    );
  }
}
