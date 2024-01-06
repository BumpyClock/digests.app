import 'package:flutter/material.dart';
import 'rss_feed_screen.dart';

class AppMaterial extends StatelessWidget {
  const AppMaterial({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RSS Reader',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const RSSFeedScreen(),
    );
  }
}
