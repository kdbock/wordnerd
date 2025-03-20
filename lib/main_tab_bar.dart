import 'package:flutter/material.dart';
import '../theme/brand_colors.dart';

class MainTabBar extends StatefulWidget {
  const MainTabBar({super.key});

  @override
  State<MainTabBar> createState() => _MainTabBarState();
}

class _MainTabBarState extends State<MainTabBar> {
  int _selectedIndex = 0;

  // List of screens to display
  final List<Widget> _screens = [
    // 1) Home
    const RSSFeedScreen(
      feedURL: "https://www.neusenews.com/index?format=rss",
      title: "Home",
    ),

    // 2) Sports
    const RSSFeedScreen(
      feedURL: "https://www.neusenewssports.com/news-1?format=rss",
      title: "Sports",
    ),

    // 3) Politics
    const RSSFeedScreen(
      feedURL: "https://www.ncpoliticalnews.com/news?format=rss",
      title: "Politics",
    ),

    // 4) Business
    const RSSFeedScreen(
      feedURL: "https://www.magicmilemedia.com/blog?format=rss",
      title: "Business",
    ),

    // 5) Classifieds
    const RSSFeedScreen(
      feedURL:
          "https://www.neusenews.com/index/category/Classifieds?format=rss",
      title: "Classifieds",
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports),
            label: 'Sports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag),
            label: 'Politics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Business',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'Classifieds',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: BrandColors.gold,
        unselectedItemColor: BrandColors.darkGray,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed, // Important for more than 3 items
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Example RSSFeedScreen implementation
class RSSFeedScreen extends StatefulWidget {
  final String feedURL;
  final String title;

  const RSSFeedScreen({
    super.key,
    required this.feedURL,
    required this.title,
  });

  @override
  State<RSSFeedScreen> createState() => _RSSFeedScreenState();
}

class _RSSFeedScreenState extends State<RSSFeedScreen> {
  // Feed data would be loaded and stored here
  List<Map<String, dynamic>> _feedItems = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Here you would use a package like dart_rss or http to fetch and parse the RSS feed
      // Example implementation:
      // final response = await http.get(Uri.parse(widget.feedURL));
      // final feed = RssFeed.parse(response.body);
      // final items = feed.items.map((item) => {
      //   'title': item.title,
      //   'description': item.description,
      //   'link': item.link,
      //   'pubDate': item.pubDate,
      // }).toList();

      // For now, we'll use placeholder data
      await Future.delayed(
          const Duration(seconds: 1)); // Simulate network delay
      final items = List.generate(
          10,
          (index) => {
                'title': 'Article ${index + 1}',
                'description':
                    'This is a sample article description for ${widget.title}',
                'link': 'https://example.com/article${index + 1}',
                'pubDate':
                    DateTime.now().subtract(Duration(hours: index)).toString(),
              });

      setState(() {
        _feedItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFeed,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error loading feed: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFeed,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_feedItems.isEmpty) {
      return const Center(
        child: Text('No articles found'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFeed,
      child: ListView.separated(
        itemCount: _feedItems.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final item = _feedItems[index];
          return ListTile(
            title: Text(
              item['title'] ?? 'No title',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['description'] ?? 'No description',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Published: ${item['pubDate'] ?? 'Unknown'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            onTap: () {
              // Here you would navigate to a detail view of the article
              // For example:
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => ArticleDetailScreen(
              //       url: item['link'],
              //       title: item['title'],
              //     ),
              //   ),
              // );
            },
          );
        },
      ),
    );
  }
}
