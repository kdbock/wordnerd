import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dart_rss/dart_rss.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/rss_item_cell.dart';
import '../article_detail_screen.dart';
import '../models/rss_item.dart'; // Import the correct RSSItem class
import '../widgets/header.dart'; // Import the HeaderView

// Ad Model
class Ad {
  final String imageUrl;
  final String link;

  Ad({required this.imageUrl, required this.link});
}

// Header View Delegate
abstract class HeaderViewDelegate {
  void onSearchPressed();
  void onMenuPressed();
}

class RSSFeedScreen extends StatefulWidget {
  final String feedURL;
  final String title;

  const RSSFeedScreen({super.key, required this.feedURL, required this.title});

  @override
  State<RSSFeedScreen> createState() => _RSSFeedScreenState();
}

class _RSSFeedScreenState extends State<RSSFeedScreen>
    implements HeaderViewDelegate {
  final List<RSSItem> _items = []; // Use the correct RSSItem class
  final List<Ad> _inFeedAds = [];
  Ad? _topBannerAd;
  bool _isLoading = true;
  Timer? _autoRefreshTimer;
  final int _adInterval = 5;

  @override
  void initState() {
    super.initState();
    _startAutoRefreshTimer();
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefreshTimer() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    await Future.wait([_fetchRSSFeed(), _fetchBannerAd(), _fetchInFeedAds()]);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchRSSFeed() async {
    try {
      final response = await http.get(Uri.parse(widget.feedURL));

      if (response.statusCode == 200) {
        // Use the RssFeed from dart_rss package
        final feed = RssFeed.parse(response.body);

        final newItems = feed.items?.map((item) {
              // Extract image URL if available
              String? imageUrl;
              final content = item.content?.value ?? '';
              final imgRegExp = RegExp(r'<img[^>]+src="([^">]+)"');
              final match = imgRegExp.firstMatch(content);
              if (match != null && match.groupCount >= 1) {
                imageUrl = match.group(1);
              }

              return RSSItem(
                title: item.title ?? 'No title',
                description:
                    item.description?.replaceAll(RegExp(r'<[^>]*>'), '') ??
                        'No description',
                link: item.link ?? '',
                pubDate: item.pubDate ?? '',
                imageUrl: imageUrl,
              );
            }).toList() ??
            [];

        setState(() {
          _items.clear();
          _items.addAll(newItems);
        });
      }
    } catch (e) {
      debugPrint('Error fetching RSS feed: $e');
    }
  }

  Future<void> _fetchBannerAd() async {
    try {
      final ref =
          FirebaseDatabase.instance.ref().child('ads').child('top_banner');
      final snapshot = await ref.get();

      if (snapshot.exists) {
        final Map<dynamic, dynamic> adsData = snapshot.value as Map;
        final activeAds = adsData.values
            .where((ad) => ad is Map && ad['status'] == 'active')
            .toList();

        if (activeAds.isNotEmpty) {
          final randomAd = activeAds[Random().nextInt(activeAds.length)];
          setState(() {
            _topBannerAd = Ad(
              imageUrl: randomAd['imageURL'],
              link: randomAd['link'],
            );
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching banner ad: $e');
    }
  }

  Future<void> _fetchInFeedAds() async {
    try {
      final ref = FirebaseDatabase.instance.ref().child('ads').child('in_feed');
      final snapshot = await ref.get();

      if (snapshot.exists) {
        final Map<dynamic, dynamic> adsData = snapshot.value as Map;
        final activeAds = adsData.values
            .where((ad) => ad is Map && ad['status'] == 'active')
            .map((ad) => Ad(imageUrl: ad['imageURL'], link: ad['link']))
            .toList();

        setState(() {
          _inFeedAds.clear();
          _inFeedAds.addAll(activeAds);
        });
      }
    } catch (e) {
      debugPrint('Error fetching in-feed ads: $e');
    }
  }

  // Calculating total items including ads
  int get _totalItems {
    if (_items.isEmpty) return 0;

    // Calculate how many ads will be shown
    final int numberOfAds = (_items.length / _adInterval).floor();

    // Total is content items + ads (if we have ads to show)
    return _items.length + (_inFeedAds.isNotEmpty ? numberOfAds : 0);
  }

  // Determining if a position is an ad position
  bool _isAdPosition(int position) {
    if (_inFeedAds.isEmpty) return false;

    // +1 because we want to start with content, then show ad after interval
    return (position + 1) % (_adInterval + 1) == 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            HeaderView(delegate: this),

            // Top Banner Ad
            if (_topBannerAd != null)
              GestureDetector(
                onTap: () => _launchURL(_topBannerAd!.link),
                child: SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: _topBannerAd!.imageUrl,
                    fit: BoxFit.fitWidth,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
              ),

            // RSS Feed List
            Expanded(
              child: _isLoading && _items.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _fetchData,
                      child: ListView.separated(
                        itemCount: _items.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = _items[index];

                          return RSSItemCell(
                            item: item,
                            onReadMore: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ArticleDetailScreen(
                                    articleURL: item.link,
                                  ),
                                ),
                              );
                            },
                            onShare: () {
                              Share.share(
                                  'Check out this article: ${item.title} ${item.link}');
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppWebView);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not launch: $url')));
    }
  }

  // HeaderViewDelegate implementations
  @override
  void onSearchPressed() {
    // Implement search functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Search pressed')));
  }

  @override
  void onMenuPressed() {
    // Implement menu functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Menu pressed')));
  }
}
