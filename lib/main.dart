import 'package:flutter/material.dart';
import 'audio_stream_page.dart';
import 'video_stream_page.dart';
import 'home_page.dart';
import 'podcast_page.dart';
// ignore: unused_import
import 'videoplayer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mon Application',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/audio': (context) => AudioStreamPage(),
        '/video': (context) => VideoStreamPage(),
        '/podcast': (context) => PodcastPage(),
      },
      debugShowCheckedModeBanner: false,  // Désactiver la bannière de débogage
    );
  }
}
