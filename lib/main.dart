import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'feed_data_model.dart';
import 'feed_card.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
    double viewportWidth = MediaQuery.of(context).size.width;
    int columnCount = calculateColumnCount(viewportWidth);
    // double padding = viewportWidth * 0.02; // 2% of viewport width
    ScrollController controller =
        ScrollController(); // Create a ScrollController
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Feeds'),
        backgroundColor: Colors.grey.shade50.withOpacity(0.8),
        elevation: 0,
        shadowColor: Colors.amber.shade400.withOpacity(0.2),
        scrolledUnderElevation: 12,
        surfaceTintColor: Colors.amber.shade200,
        toolbarHeight: 48,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Scrollbar(
        controller: controller, // Use the ScrollController for the Scrollbar
        child: Padding(
          padding:
              const EdgeInsets.all(0.0), // Add padding to the MasonryGridView
          child: MasonryGridView.count(
            addAutomaticKeepAlives: true,
            controller: controller,
            crossAxisCount: columnCount,
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
            itemCount: _allItems.length,
            itemBuilder: (BuildContext context, int index) => Padding(
              padding:
                  const EdgeInsets.all(8.0), // Add padding to the child widgets
              child: FeedItemCard(item: _allItems[index]),
            ),
          ),
        ),
      ),
    );
  }
}

int calculateColumnCount(double viewportWidth) {
  int columnCount = 1; // Default column count for small screens
  if (viewportWidth > 650) {
    columnCount = 2;
  }
  if (viewportWidth > 1080) {
    columnCount = 3;
  }
  if (viewportWidth > 1240) {
    columnCount = 4;
  }
  if (viewportWidth > 1600) {
    columnCount = 5;
  }
  // Add more conditions as needed
  return columnCount;
}
