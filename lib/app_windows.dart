import 'package:fluent_ui/fluent_ui.dart';
import 'rss_feed_screen.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';


class AppWindows extends StatelessWidget {
  const AppWindows({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      themeMode: ThemeMode.system,
      title: 'RSS Reader',
      theme: FluentThemeData(
        accentColor: Colors.blue,
      ),
      home: const RSSFeedScreen(),
    );
  }
}
