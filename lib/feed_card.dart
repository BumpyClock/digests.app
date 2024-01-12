import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'feed_data_model.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:intl/intl.dart';
import 'package:html/parser.dart' as htmlparser;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'reader_view.dart';

class FeedItemCard extends StatefulWidget {
  final Item item;

  const FeedItemCard({super.key, required this.item});

  @override
  _FeedItemCardState createState() => _FeedItemCardState();
}

class _FeedItemCardState extends State<FeedItemCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  double elevation = 2;
  String buttonText = 'Read more';

  Color? _dominantColor;
  final double coreshadowOpacity = .1;
  final double castshadowOpacity = .08;
  final double coreshadowBlur = 6;
  final double castshadowBlur = 12;
  final double coreshadowSpread = 2;
  final double castshadowSpread = 6;

  late BoxShadow boxShadowCore = BoxShadow(
    color: Colors.grey.withOpacity(coreshadowOpacity),
    spreadRadius: 2,
    blurRadius: 6,
    offset: const Offset(0, 0),
  );

  late BoxShadow boxShadowCast = BoxShadow(
    color: Colors.grey.withOpacity(castshadowOpacity),
    spreadRadius: 6,
    blurRadius: 12,
    offset: const Offset(0, 0),
  );

  @override
  void initState() {
    super.initState();
    _updatePaletteGenerator();
  }

  Future<String> fetchContent(String url) async {
    final response = await http.post(
      Uri.parse('https://rss.bumpyclock.com/getreaderview'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "urls": [url]
      }),
    );
    // debugPrint(response.body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data[0]["content"] ?? "No content available";
    } else {
      throw Exception('Failed to load content');
    }
  }

  Future<void> _updatePaletteGenerator() async {
    if (kIsWeb) {
      setState(() {
        buttonText = 'Open in new tab';
        _dominantColor = Colors.blueGrey;
        boxShadowCore = BoxShadow(
          color: _dominantColor!.withOpacity(coreshadowOpacity),
          spreadRadius: coreshadowSpread,
          blurRadius: coreshadowBlur,
          offset: const Offset(0, 0),
        );
        boxShadowCast = BoxShadow(
          color: _dominantColor!.withOpacity(castshadowOpacity),
          spreadRadius: castshadowSpread,
          blurRadius: castshadowBlur,
          offset: const Offset(0, 0),
        );
      });
      return;
    }
    // If running in a web environment, skip palette generation

    try {
      final PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(
        CachedNetworkImageProvider(widget.item.thumbnail),
        maximumColorCount: 5,
      );
      if (mounted) {
        setState(() {
          // Choose the dominant color or fallback to a default color
          _dominantColor =
              paletteGenerator.vibrantColor?.color ?? Colors.blueGrey;
          boxShadowCore = BoxShadow(
            color: _dominantColor?.withOpacity(coreshadowOpacity) ??
                Colors.transparent,
            spreadRadius: coreshadowSpread,
            blurRadius: coreshadowBlur,
            offset: const Offset(0, 0),
          );
          boxShadowCast = BoxShadow(
            color: _dominantColor?.withOpacity(castshadowOpacity) ??
                Colors.transparent,
            spreadRadius: castshadowSpread,
            blurRadius: castshadowBlur,
            offset: const Offset(0, 0),
          );
        });
      }
    } catch (e) {
      debugPrint('Error generating palette: $e');
      if (mounted) {
        setState(() {
          _dominantColor = Colors.blueGrey;
          boxShadowCore = BoxShadow(
            color: _dominantColor?.withOpacity(coreshadowOpacity) ??
                Colors.transparent,
            spreadRadius: coreshadowSpread,
            blurRadius: coreshadowBlur,
            offset: const Offset(0, 0),
          );
          boxShadowCast = BoxShadow(
            color: _dominantColor?.withOpacity(castshadowOpacity) ??
                Colors.transparent,
            spreadRadius: castshadowSpread,
            blurRadius: castshadowBlur,
            offset: const Offset(0, 0),
          );
        });
      }
    }
  }

  String formatPublishedDate(String dateStr) {
    final rfc822 = RegExp(r'^\w{3}, (\d{2}) (\w{3}) (\d{4}) (\d{2}):(\d{2}):(\d{2}) ([+-]\d{4})$');
    final months = {'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6, 'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12};

    final match = rfc822.firstMatch(dateStr);
    final day = int.parse(match?.group(1) ?? '');
    final month = months[match?.group(2) ?? ''];
    final year = int.parse(match?.group(3) ?? '');
    final hour = int.parse(match?.group(4) ?? '');
    final minute = int.parse(match?.group(5) ?? '');
    final second = int.parse(match?.group(6) ?? '');
    final offset = int.parse(match?.group(7) ?? '');

    final date = DateTime.utc(year, month!, day, hour, minute, second).add(Duration(minutes: offset));

    return DateFormat('H:mm a d MMM y').format(date.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    BoxShadow coreshadowRest = BoxShadow(
      color:
          _dominantColor?.withOpacity(coreshadowOpacity) ?? Colors.transparent,
      spreadRadius: coreshadowSpread,
      blurRadius: coreshadowBlur,
      offset: const Offset(0, 0),
    );

    BoxShadow castshadowRest = BoxShadow(
      color:
          _dominantColor?.withOpacity(castshadowOpacity) ?? Colors.transparent,
      spreadRadius: castshadowSpread,
      blurRadius: castshadowBlur,
      offset: const Offset(0, 0),
    );

    BoxShadow coreshadowHover = BoxShadow(
      color: _dominantColor?.withOpacity(coreshadowOpacity + .1) ??
          Colors.transparent,
      spreadRadius: coreshadowSpread,
      blurRadius: coreshadowBlur,
      offset: const Offset(0, 0),
    );

    BoxShadow castshadowHover = BoxShadow(
      color: _dominantColor?.withOpacity(castshadowOpacity + .1) ??
          Colors.transparent,
      spreadRadius: castshadowSpread,
      blurRadius: castshadowBlur,
      offset: const Offset(0, 0),
    );

    super.build(context);
    String imageUrl = widget.item.thumbnail;
    if (imageUrl.isEmpty) {
      // If thumbnail is empty, use the first image from the content
      RegExp regExp = RegExp(r'<img.+?src="(.+?)".*?>');
      Iterable<Match> matches = regExp.allMatches(widget.item.content);
      if (matches.isNotEmpty) {
        imageUrl = matches.first.group(1) ?? '';
      }
    }

    return MouseRegion(
        onEnter: (PointerEnterEvent event) => setState(() => {
              boxShadowCore = coreshadowHover,
              boxShadowCast = castshadowHover,
            }),
        onExit: (PointerExitEvent event) => setState(() => {
              boxShadowCore = coreshadowRest,
              boxShadowCast = castshadowRest,
            }),
        child: RepaintBoundary(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOutCubic,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(23),
              boxShadow: _dominantColor != null
                  ? [
                      boxShadowCore,
                      boxShadowCast,
                    ]
                  : [],
            ),
            child: Card(
              clipBehavior: Clip.antiAlias,
              elevation: elevation,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(23),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: double.maxFinite,
                    fit: BoxFit.cover,
                    // placeholder: (context, url) =>
                    //     const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Container(
                      height: 200,
                      color: Colors.red.shade50,
                    ),
                  ),
                  Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(imageUrl),
                              opacity: .5,
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: ClipRRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                              child: Container(
                                alignment: Alignment.center,
                                color: Colors.white.withOpacity(0.35),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                            child: Text(
                              widget.item.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w700,
                                height: 1.33,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                            child: Text(
                              widget.item.author,
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                            child: () {
                              String dateText;
                              try {
                                dateText = formatPublishedDate(widget.item.published);                           
                              } catch (e) {
                                dateText = 'Invalid date';
                              }
                              return Text(
                                dateText,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black54,
                                ),
                              );
                            }(),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                            child: Text(
                              htmlparser
                                      .parse(widget.item.content)
                                      .querySelector('p')
                                      ?.text ??
                                  '',
                              style: const TextStyle(
                                fontSize: 14.0,
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w400,
                                color: Colors.black54,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          ButtonBar(
                            children: [
                              TextButton(
                                child: Text(buttonText),
                                // onPressed: () async {
                                //   final url = widget.item.link;
                                //   if (await canLaunchUrl(Uri.parse(url))) {
                                //     await launchUrl(
                                //       Uri.parse(url),
                                //       webOnlyWindowName: kIsWeb ? '_blank' : null, // open in a new tab on web
                                //     );
                                //   } else {
                                //     throw 'Could not launch $url';
                                //   }
                                // },
                                onPressed: () async {
                                  try {
                                    final content =
                                        await fetchContent(widget.item.link);
                                    // debugPrint(widget.item.link);
                                    // debugPrint(content);
                                    showContentScreen(
                                        context,
                                        widget.item.title,
                                        widget.item.thumbnail,
                                        content,
                                        widget.item.link);
                                  } catch (e) {
                                    // Handle error or show a message
                                    debugPrint('Error fetching content: $e');
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
