import 'package:flutter/material.dart';
import 'audio_stream_page.dart';
import 'video_stream_page.dart';
import 'podcast_page.dart'; // 
// ignore: unused_import
import 'audioplayer.dart';
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late final DecorationImage _backgroundImage;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _backgroundImage = const DecorationImage(
      image: AssetImage('assets/background.jpg'),
      fit: BoxFit.cover,
    );

    _pages = [
      SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TickerMode(
                enabled: _selectedIndex == 0,
                child: ZoomingLogo(),
              ),
              const SizedBox(height: 20),
              TickerMode(
                enabled: _selectedIndex == 0,
                child: ZoomingText(),
              ),
            ],
          ),
        ),
      ),
      SafeArea(child: AudioStreamPage()),
      SafeArea(child: VideoStreamPage()),
      SafeArea(child: PodcastPage()), // <-- Page podcast ajoutée ici
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: _backgroundImage,
        ),
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: isPortrait
          ? Theme(
              data: Theme.of(context).copyWith(
                canvasColor: const Color.fromARGB(255, 43, 59, 228), // ✅ fond bleu appliqué ici
              ),
              child: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                selectedItemColor: const Color.fromARGB(255, 229, 227, 233),
                unselectedItemColor:
                    const Color.fromARGB(255, 229, 227, 233),
                items: const [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.home), label: 'Accueil'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.music_note), label: 'Audio'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.ondemand_video), label: 'Vidéo'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.podcasts), label: 'Podcasts'),
                ],
              ),
            )
          : null,
    );
  }
}

class ZoomingLogo extends StatefulWidget {
  @override
  _ZoomingLogoState createState() => _ZoomingLogoState();
}

class _ZoomingLogoState extends State<ZoomingLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Image.asset(
        'assets/logo1.png',
        width: 100,
        height: 100,
      ),
    );
  }
}

class ZoomingText extends StatefulWidget {
  @override
  _ZoomingTextState createState() => _ZoomingTextState();
}

class _ZoomingTextState extends State<ZoomingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: const Text(
        'RADIOVISION',
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 221, 225, 225),
          shadows: [
            Shadow(
              blurRadius: 10,
              color: Colors.black,
              offset: Offset(2, 2),
            )
          ],
        ),
      ),
    );
  }
}
