import 'package:flutter/material.dart';
import 'rss_feed_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: const RSSFeedScreen(
        feedURL: "https://www.neusenews.com/index?format=rss",
        title: "Home",
      ),
    );
  }
}
