import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioStreamPage extends StatefulWidget {
  @override
  _AudioStreamPageState createState() => _AudioStreamPageState();
}

class _AudioStreamPageState extends State<AudioStreamPage> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  double _volume = 0.5;
  bool _initialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      // Initialisation du lecteur
      await _player.setUrl("https://media.dcat.ci/stream");
      setState(() => _initialized = true); // Affiche l'UI même si le chargement n'est pas fini

      // Configuration des écouteurs d'état
      _player.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;
            if (state.processingState == ProcessingState.completed) {
              _player.seek(Duration.zero);
              _player.play();
            }
          });
        }
      });

      // Démarrage automatique avec gestion de latence
      await Future.delayed(Duration(milliseconds: 500)); // Délai pour l'UI
      await _player.setVolume(_volume);
      await _player.play();
      
    } catch (e) {
      print("Erreur initialisation audio: $e");
      setState(() => _hasError = true);
    }
  }

  Future<void> _togglePlayPause() async {
    try {
      await (_isPlaying ? _player.pause() : _player.play());
    } catch (e) {
      print("Erreur toggle: $e");
      setState(() => _hasError = true);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/casque.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Placeholder(), // Fallback si image manquante
          ),
          Center(
            child: _hasError
                ? Text("problème de connexion", style: TextStyle(color: Colors.white))
                : (!_initialized
                    ? CircularProgressIndicator(color: Colors.white)
                    : SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 170,
                              height: 170,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.asset(
                                  'assets/logo1.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(Icons.error, color: Colors.red), // Fallback logo
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            AnimatedOpacity(
                              opacity: _initialized ? 1.0 : 0.0,
                              duration: Duration(milliseconds: 500),
                              child: Container(
                                width: 250,
                                padding: EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: Color(0xFF252842),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      spreadRadius: 2,
                                      blurRadius: 10,
                                    )
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        _isPlaying ? Icons.pause : Icons.play_arrow,
                                        color: Colors.white,
                                        size: 60,
                                      ),
                                      onPressed: _togglePlayPause,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      child: Row(
                                        children: [
                                          Icon(Icons.volume_down, color: Colors.grey),
                                          Expanded(
                                            child: Slider(
                                              value: _volume,
                                              onChanged: (value) {
                                                setState(() => _volume = value);
                                                _player.setVolume(value);
                                              },
                                              activeColor: Color(0xFFE93357),
                                              inactiveColor: Colors.grey.shade300,
                                            ),
                                          ),
                                          Icon(Icons.volume_up, color: Colors.grey),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
          ),
        ],
      ),
    );
  }
}