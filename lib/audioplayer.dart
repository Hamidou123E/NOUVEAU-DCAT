import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:radio_vision/podcast_page.dart';

class AudioPlayerPage extends StatefulWidget {
  final Map<String, dynamic> audio;

  const AudioPlayerPage({Key? key, required this.audio}) : super(key: key);

  @override
  _AudioPlayerPageState createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;
  // ignore: unused_field
  bool _isInitialized = false;
  String _currentTag = '';

  @override
  void initState() {
    super.initState();
    _initAudio();
    _currentTag = widget.audio['tags'].join(', ');

    // Écouteur pour les changements de position
    globalAudioPlayer.player.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });

    // Écouteur pour les changements de durée
    globalAudioPlayer.player.durationStream.listen((duration) {
      if (mounted) {
        setState(() {
          _duration = duration ?? Duration.zero;
        });
      }
    });

    // Écouteur pour l'état de lecture
    globalAudioPlayer.player.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
          _isInitialized = state.playing || state.processingState == ProcessingState.ready;
        });
      }
    });

    // Défilement du tag
    Future.delayed(const Duration(milliseconds: 1000), () {
      _scrollTag();
    });
  }

  Future<void> _initAudio() async {
    if (globalAudioPlayer.player.url != widget.audio['url']) {
      await globalAudioPlayer.play(widget.audio['url']);
    } else if (!_isPlaying) {
      await globalAudioPlayer.player.play();
    }
  }

  String _formatDuration(Duration d) {
    return "${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}";
  }

  void _scrollTag() async {
    while (_isPlaying) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        setState(() {
          if (_currentTag.length > 20) {
            _currentTag = _currentTag.substring(1) + _currentTag[0];
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.purple.shade900, Colors.black],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView( // Ajout de SingleChildScrollView
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Titre principal
              
              const SizedBox(height: 20),
              
              // Titre et artiste
              Text(
                widget.audio['TITRE'] ?? '',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                _currentTag,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 30),
              
              // Image de couverture (cercle)
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: widget.audio['image'] != null && widget.audio['image'].isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(widget.audio['image']),
                          fit: BoxFit.cover,
                        )
                      : DecorationImage(
                          image: AssetImage('assets/radio_placeholder.png'),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(height: 30),
              
              // Contrôle de la position
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Slider(
                      value: _duration.inSeconds > 0 ? _position.inSeconds.toDouble() / _duration.inSeconds.toDouble() : 0,
                      onChanged: (value) async {
                        final newPosition = Duration(seconds: (value * _duration.inSeconds).round());
                        await globalAudioPlayer.player.seek(newPosition);
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(_position),
                            style: const TextStyle(color: Colors.white),
                          ),
                          Text(
                            _formatDuration(_duration),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              
              // Contrôles de lecture
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Bouton retour rapide
                  IconButton(
                    icon: const Icon(Icons.fast_rewind, size: 36),
                    color: Colors.white,
                    onPressed: () async {
                      final newPosition = _position - const Duration(seconds: 10);
                      await globalAudioPlayer.player.seek(newPosition > Duration.zero ? newPosition : Duration.zero);
                    },
                  ),
                  const SizedBox(width: 30),
                  
                  // Bouton Play/Pause
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 36,
                      ),
                      color: const Color.fromARGB(255, 51, 109, 148),
                      onPressed: () async {
                        if (_isPlaying) {
                          await globalAudioPlayer.player.pause();
                        } else {
                          await globalAudioPlayer.player.play();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 30),
                  
                  // Bouton avance rapide
                  IconButton(
                    icon: const Icon(Icons.fast_forward, size: 36),
                    color: Colors.white,
                    onPressed: () async {
                      final newPosition = _position + const Duration(seconds: 10);
                      if (newPosition < _duration) {
                        await globalAudioPlayer.player.seek(newPosition);
                      } else {
                        await globalAudioPlayer.player.seek(_duration);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),
              
              // Boutons supplémentaires
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.share, size: 28),
                    color: Colors.white,
                    onPressed: () {},
                  ),
                  const SizedBox(width: 40),
                  IconButton(
                    icon: const Icon(Icons.favorite_border, size: 28),
                    color: Colors.white,
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 20), // Ajout d'un espace supplémentaire
            ],
          ),
        ),
      ),
    );
  }
}

extension on AudioPlayer {
  get url => null;
}
