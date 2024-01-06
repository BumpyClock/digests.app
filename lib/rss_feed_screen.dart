import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'feed_data_model.dart';
import 'components/feed_screen_material.dart';
import 'components/feed_screen_fluent.dart';

class RSSFeedScreen extends StatefulWidget {
  const RSSFeedScreen({super.key});

  @override
  _RSSFeedScreenState createState() => _RSSFeedScreenState();
}

class _RSSFeedScreenState extends State<RSSFeedScreen> {
  List<Item> _allItems = [];

  @override
  void initState() {
    super.initState();
    _fetchRSSData();
  }

  _fetchRSSData() async {
    var url = Uri.parse('https://rss.bumpyclock.com/parse');
    var response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "urls": [
            "https://www.theverge.com/rss/index.xml",
            "https://www.polygon.com/rss/index.xml",
            "https://www.vox.com/rss/index.xml",
          ]
        }));

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      var feedsJson = jsonResponse['feeds'] as List<dynamic>;
      List<Item> items = [];

      for (var feedJson in feedsJson) {
        try {
          Feed feed = Feed.fromJson(feedJson);
          items.addAll(feed.items); // Add all items from each feed to the list
        } catch (e) {
          // print('Error parsing feed JSON: $feedJson');
          debugPrint('Exception: $e');
        }
      }

      setState(() {
        _allItems = items; // Update _allItems with the combined list of items
      });
    } else {
      // Handle error
      debugPrint(
          'Error: Server responded with status code ${response.statusCode}');
    }
  }
 @override
  Widget build(BuildContext context) {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
      return RSSFeedScreenFluent(items: _allItems);
    } else {
      return RSSFeedScreenMaterial(items: _allItems);
    }
  }
}






