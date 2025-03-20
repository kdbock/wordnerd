import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ArticleDetailScreen extends StatefulWidget {
  final String articleURL;

  const ArticleDetailScreen({
    super.key,
    required this.articleURL,
  });

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  late final WebViewController _webViewController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initWebViewController();
  }

  void _initWebViewController() {
    // Block Google Ads script
    final String blockAdsScript = '''
      (function() {
        var observer = new MutationObserver(function(mutations) {
          mutations.forEach(function(mutation) {
            var ads = document.querySelectorAll("[id^='google_ads'], [class*='ads'], iframe[src*='doubleclick'], iframe[src*='googlesyndication']");
            ads.forEach(ad => ad.remove());
          });
        });
        observer.observe(document.body, { childList: true, subtree: true });
      })();
    ''';

    // Configure WebView with ad blocking
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            // Execute ad blocking script after page load
            _webViewController.runJavaScript('''
              document.querySelectorAll("[id^='google_ads'], [class*='ads'], iframe[src*='doubleclick'], iframe[src*='googlesyndication']").forEach(ad => ad.remove());
            ''').then((_) {
              print("✅ Ad removal script executed");
            }).catchError((error) {
              print("❌ Error removing ads: $error");
            });

            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            print('Error loading page: ${error.description}');
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..addJavaScriptChannel(
        'Flutter',
        onMessageReceived: (JavaScriptMessage message) {
          print('Message from webpage: ${message.message}');
        },
      )
      ..loadRequest(Uri.parse(widget.articleURL))
      ..setUserAgent(
          'Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148')
      ..runJavaScript(blockAdsScript);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Article'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _webViewController.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(
            controller: _webViewController,
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
