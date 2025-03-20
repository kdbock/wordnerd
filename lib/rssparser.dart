import 'dart:convert';
import 'package:xml/xml.dart';
import '../models/rss_item.dart';

class RSSParser {
  final String data;

  RSSParser({required this.data});

  List<RSSItem> parse() {
    final List<RSSItem> items = [];

    try {
      final document = XmlDocument.parse(data);
      final itemElements = document.findAllElements('item');

      for (var itemElement in itemElements) {
        // Extract basic elements
        final title = _getElementText(itemElement, 'title');
        final link = _getElementText(itemElement, 'link');
        final description = _getElementText(itemElement, 'description');
        final fullContent = _getElementText(itemElement, 'content:encoded');

        // Extract image URL from media:content or enclosure
        String? imageURL;
        final mediaContent =
            itemElement.findElements('media:content').firstOrNull;
        final enclosure = itemElement.findElements('enclosure').firstOrNull;

        if (mediaContent != null && mediaContent.getAttribute('url') != null) {
          imageURL = mediaContent.getAttribute('url');
        } else if (enclosure != null && enclosure.getAttribute('url') != null) {
          imageURL = enclosure.getAttribute('url');
        }

        // If no dedicated image element, try to extract from content or description
        imageURL ??= _extractImageFromHtml(fullContent) ??
            _extractImageFromHtml(description);

        final item = RSSItem(
          title: title.trim(),
          link: link.trim(),
          description: description.trim(),
          imageURL: imageURL,
          fullContent: fullContent.trim(),
        );

        items.add(item);
      }
    } catch (e) {
      print('Error parsing RSS feed: $e');
    }

    return items;
  }

  String _getElementText(XmlElement parent, String elementName) {
    final elements = parent.findElements(elementName);
    return elements.isNotEmpty ? elements.first.innerText : '';
  }

  String? _extractImageFromHtml(String html) {
    // Simple regex to extract first image URL from HTML content
    final imgRegExp = RegExp(r'<img[^>]+src="([^">]+)"');
    final match = imgRegExp.firstMatch(html);
    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }
    return null;
  }
}

// Add this to lib/models/rss_item.dart
class RSSItem {
  final String title;
  final String link;
  final String description;
  final String? imageURL;
  final String fullContent;

  RSSItem({
    required this.title,
    required this.link,
    required this.description,
    this.imageURL,
    required this.fullContent,
  });

  // Optional: Add methods to extract clean text, truncate description, etc.
  String get cleanDescription {
    // Remove HTML tags for display
    return description.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  // Get a truncated version of the description
  String getShortDescription(int maxLength) {
    final clean = cleanDescription;
    if (clean.length <= maxLength) return clean;
    return '${clean.substring(0, maxLength)}...';
  }
}
