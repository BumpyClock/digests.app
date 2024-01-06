import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/widgets.dart';
import '../feed_data_model.dart';
import '../feed_card.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'calculate_column_count.dart';

class RSSFeedScreenFluent extends StatelessWidget {
  final List<Item> items;
  const RSSFeedScreenFluent({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final double viewportWidth = MediaQuery.of(context).size.width;
    final int columnCount = calculateColumnCount(viewportWidth);
    final ScrollController scrollController = ScrollController();

    return fluent.ScaffoldPage(
      header: fluent.Text('Your Feeds', style: fluent.FluentTheme.of(context).typography.title),
      content: fluent.Scrollbar(
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
