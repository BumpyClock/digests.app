import 'dart:math';

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
      title: 'Digests',
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
  int step_size = 12;
  ScrollController controller = ScrollController();
  late Future<List<Item>>
      _futureItems; // Declare a variable to store the future
  int _currentMax = 0;

  @override
  void initState() {
    super.initState();
    controller.addListener(_onScroll);
    _currentMax = step_size;
    _futureItems =
        _fetchRSSData(); // Assign the future to the variable in initState
  }

  void _onScroll() {
    if (controller.position.pixels >
        controller.position.maxScrollExtent * 0.65) {
      _loadMoreItems();
    }
  }

  void _loadMoreItems() {
    setState(() {
      if (_currentMax < _allItems.length) {
        _currentMax = min(_currentMax + step_size, _allItems.length);
      }
    });
  }

  Future<List<Item>> _fetchRSSData() async {
    const urls = [
            "https://rss.nytimes.com/services/xml/rss/nyt/US.xml",

            "https://www.theverge.com/rss/index.xml",
      "https://www.engadget.com/rss.xml",
      "https://www.polygon.com/rss/index.xml",
      "https://www.vox.com/rss/index.xml",
    ];

    var url = Uri.parse('https://rss.bumpyclock.com/parse');
    var response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"urls": urls}));

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

      return items;
    } else {
      // Handle error
      debugPrint(
          'Error: Server responded with status code ${response.statusCode}');
      throw Exception('Failed to load feeds');
    }
  }

  @override
  Widget build(BuildContext context) {
    double viewportWidth = MediaQuery.of(context).size.width;
    Map<String, int> layout = calculateLayout(viewportWidth);
    int? columnCount = layout['columnCount'];
    step_size = layout['stepSize']!;
    return Scaffold(
      body: FutureBuilder<List<Item>>(
        future: _futureItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            _allItems = snapshot.data!;
            return RefreshIndicator(
              onRefresh: () async {
                setState(() {});
              },
              child: Scrollbar(
                controller: controller,
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: MasonryGridView.count(
                    addAutomaticKeepAlives: true,
                    controller: controller,
                    crossAxisCount: columnCount ?? 2,
                    mainAxisSpacing: 0,
                    crossAxisSpacing: 0,
                    itemCount: _currentMax,
                    itemBuilder: (BuildContext context, int index) {
                      if (index < _allItems.length) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FeedItemCard(item: _allItems[index]),
                        );
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

Map<String, int> calculateLayout(double viewportWidth) {
  int columnCount = 1; // Default column count for small screens
  int stepSize = 10; // Default step size for small screens

  if (viewportWidth > 650) {
    columnCount = 2;
    stepSize = 4;
  }
  if (viewportWidth > 1080) {
    columnCount = 3;
    stepSize = 10;
  }
  if (viewportWidth > 1240) {
    columnCount = 4;
    stepSize = 16;
  }
  if (viewportWidth > 1600) {
    columnCount = 5;
    stepSize = 20;
  }
  // Add more conditions as needed

  return {'columnCount': columnCount, 'stepSize': stepSize};
}
