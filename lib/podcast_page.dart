import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'audioplayer.dart'; // Ajoutez cette ligne

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Radio Vision',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PodcastPage(),
    );
  }
}

// Gestion centralisée du lecteur audio
final GlobalAudioPlayer globalAudioPlayer = GlobalAudioPlayer();

class GlobalAudioPlayer {
  final AudioPlayer _audioPlayer = AudioPlayer();

  AudioPlayer get player => _audioPlayer;

  Future<void> play(String url) async {
    await _audioPlayer.setUrl(url);
    await _audioPlayer.play();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}

class PodcastPage extends StatefulWidget {
  @override
  _PodcastPageState createState() => _PodcastPageState();
}

class _PodcastPageState extends State<PodcastPage> {
  Map<String, dynamic> media = {};
  // ignore: unused_field
  VideoPlayerController? _videoPlayerController;
  bool _showAudio = false;
  bool _showVideo = false;

  @override
  void initState() {
    super.initState();
    fetchContenu();
  }

  @override
  void dispose() {
    globalAudioPlayer.dispose();
    super.dispose();
  }

  Future<void> fetchContenu() async {
    final url = Uri.parse('https://radiovision-r7jj.onrender.com/media');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        media = jsonData;
      });
    } else {
      print('problème de connexion : ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 227, 228, 231),
      
      body: media.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView( // Ajout de SingleChildScrollView ici
              child: Column(
                children: [
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.blue.shade900,
                          const Color.fromARGB(255, 119, 12, 28),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('RADIOVISION', style: TextStyle(fontSize: 24, color: Colors.white)),
                          const Text('Don\'t let me go', style: TextStyle(fontSize: 18, color: Colors.white)),
                          const SizedBox(height: 20),
                          Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.play_arrow, size: 50, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 81, 146, 211),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _showAudio = !_showAudio;
                            _showVideo = false;
                          });
                        },
                        child: const Text('NOS AUDIOS',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 81, 146, 211),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _showVideo = !_showVideo;
                            _showAudio = false;
                          });
                        },
                        child: const Text('NOS VIDEOS',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height - 300, // Ajuster la hauteur ici
                    child: _showAudio
                        ? ListView(
                            children: (media['audio'] ?? []).map<Widget>((audio) {
                              return Container(
                                margin: const EdgeInsets.all(4),
                                padding: const EdgeInsets.all(10),
                                width: MediaQuery.of(context).size.width * 0.9,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 248, 247, 246),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.blue),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.audiotrack, color: Colors.blue),
                                    const SizedBox(width: 2),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          
                                          Text(audio['tags'].join(', '),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: const Color.fromARGB(255, 11, 1, 1),
                                                  fontWeight: FontWeight.w800)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AudioPlayerPage(audio: audio),
                                          ),
                                        );
                                      },
                                      child: const Text('Écouter',
                                          style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          )
                        : _showVideo
                            ? ListView(
                                children: (media['video'] ?? [])
                                    .where((video) => video['tags'] != null && video['tags'].length > 0)
                                    .map<Widget>((video) {
                                  return Container(
                                    margin: const EdgeInsets.all(4),
                                    padding: const EdgeInsets.all(10),
                                    width: MediaQuery.of(context).size.width * 0.9,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(255, 241, 237, 233),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.red),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.video_library, color: Colors.red),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text(video['tags'].join(', '),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      color: const Color.fromARGB(255, 28, 4, 4),
                                                      fontWeight: FontWeight.w500)),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => VideoPlayerPage(url: video['url'], tags: video['tags']),
                                              ),
                                            );
                                          },
                                          child: const Text('Lire',
                                              style: TextStyle(fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              )
                            : Container(
                                height: MediaQuery.of(context).size.height - 350,
                                child: const Center(child: Text('Cliquez sur un bouton pour explorer')),
                              ),
                  ),
                ],
              ),
            ),
    );
  }
}

class VideoPlayerPage extends StatefulWidget {
  final String url;
  final List<dynamic> tags;

  VideoPlayerPage({required this.url, required this.tags});

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _videoPlayerController;
  bool _isPlaying = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.network(widget.url);
    _videoPlayerController.initialize().then((_) {
      setState(() {});
      _videoPlayerController.play();
      _isPlaying = true;
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2C003E),
      body: GestureDetector(
        onTap: () {
          setState(() {
            _showControls = !_showControls;
          });
        },
        child: Stack(
          children: [
            Center(
              child: _videoPlayerController.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _videoPlayerController.value.aspectRatio,
                      child: VideoPlayer(_videoPlayerController),
                    )
                  : CircularProgressIndicator(),
            ),
            _showControls
                ? Positioned(
                    top: 50,
                    left: 20,
                    right: 20,
                    child: Text(
                      widget.tags.join(', '),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  )
                : Container(),
            _showControls
                ? Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: Icon(Icons.replay_10, color: Colors.white),
                            onPressed: () {
                              _videoPlayerController.seekTo(Duration(
                                seconds: _videoPlayerController.value.position.inSeconds - 10,
                              ));
                            },
                          ),
                          IconButton(
                            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                if (_isPlaying) {
                                  _videoPlayerController.pause();
                                } else {
                                  _videoPlayerController.play();
                                }
                                _isPlaying = !_isPlaying;
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.forward_10, color: Colors.white),
                            onPressed: () {
                              _videoPlayerController.seekTo(Duration(
                                seconds: _videoPlayerController.value.position.inSeconds + 10,
                              ));
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(),
            Positioned(
              top: 20,
              left: 20,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on AudioPlayer {
  // ignore: unused_element
  get url => null;
}
