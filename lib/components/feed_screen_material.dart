import 'package:flutter/material.dart';
import '../feed_data_model.dart';
import '../feed_card.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'calculate_column_count.dart';


class RSSFeedScreenMaterial extends StatelessWidget {
  final List<Item> items;
  const RSSFeedScreenMaterial({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final double viewportWidth = MediaQuery.of(context).size.width;
    final int columnCount = calculateColumnCount(viewportWidth);
    final ScrollController scrollController = ScrollController();

    return Scaffold(
      appBar: AppBar(title: const Text('Your Feeds')),
      body: Scrollbar(
        controller: scrollController,
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: MasonryGridView.count(
            controller: scrollController,
            crossAxisCount: columnCount,
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: FeedItemCard(item: items[index]),
              );
            },
          ),
        ),
      ),
    );
  }
}
