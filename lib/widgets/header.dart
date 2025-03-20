import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/brand_colors.dart';

// Delegate interface for handling header actions
abstract class HeaderViewDelegate {
  void onSearchPressed();
  void onMenuPressed();
}

class HeaderView extends StatefulWidget {
  final HeaderViewDelegate delegate;

  const HeaderView({
    super.key,
    required this.delegate,
  });

  @override
  State<HeaderView> createState() => _HeaderViewState();
}

class _HeaderViewState extends State<HeaderView> {
  final List<(String, String)> _categories = [
    (
      "Local News",
      "https://www.neusenews.com/index/category/Local+News?format=rss"
    ),
    (
      "State News",
      "https://www.neusenews.com/index/category/NC+News?format=rss"
    ),
    ("Columns", "https://www.neusenews.com/index/category/Columns?format=rss"),
    (
      "Matters of Record",
      "https://www.neusenews.com/index/category/Matters+of+Record?format=rss"
    ),
    (
      "Obituaries",
      "https://www.neusenews.com/index/category/Obituaries?format=rss"
    ),
    (
      "Public Notice",
      "https://www.neusenews.com/index/category/Public+Notices?format=rss"
    ),
    (
      "Classifieds",
      "https://www.neusenews.com/index/category/Classifieds?format=rss"
    )
  ];

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Neuse News'),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: widget.delegate.onSearchPressed,
        ),
        IconButton(
          icon: const Icon(Icons.menu),
          onPressed: widget.delegate.onMenuPressed,
        ),
      ],
    );
  }
}
