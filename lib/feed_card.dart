import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'feed_data_model.dart';
import 'package:intl/intl.dart';
import 'package:html/parser.dart' as htmlparser;
import 'package:http/http.dart' as http;
import 'reader_view.dart';

class FeedItemCard extends StatefulWidget {
  final Item item;

  const FeedItemCard({super.key, required this.item});

  @override
  _FeedItemCardState createState() => _FeedItemCardState();
}

final RegExp imageRegExp = RegExp(r'<img.+?src="(.+?)".*?>');

class _FeedItemCardState extends State<FeedItemCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  double elevation = 2;
  String buttonText = 'Read more';
  bool _isHovering = false;
  Color? _dominantColor;
  final double coreshadowOpacity = .18;
  final double castshadowOpacity = .14;
  final double coreshadowBlur = 0.25;
  final double castshadowBlur = 2;
  final double coreshadowSpread = 0.25;
  final double castshadowSpread = 2;
  late BoxShadow boxShadowCore = BoxShadow();
  late BoxShadow boxShadowCast = BoxShadow();
  Uint8List transparentImage =
      base64Decode('R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7');

  BoxShadow generateBoxShadow(double opacity, double spread, double blur) {
    return BoxShadow(
      color: (_dominantColor ?? Colors.grey).withOpacity(opacity),
      spreadRadius: spread,
      blurRadius: blur,
      offset: const Offset(0, 0),
    );
  }

  @override
  void initState() {
    super.initState();
    _updatePaletteGenerator();
    boxShadowCore =
        generateBoxShadow(coreshadowOpacity, coreshadowSpread, coreshadowBlur);
    boxShadowCast =
        generateBoxShadow(castshadowOpacity, castshadowSpread, castshadowBlur);
  }

  Future<String> fetchContent(String url) async {
    final response = await http.post(
      Uri.parse('https://api.bumpyclock.com/getreaderview'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "urls": [url]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data[0]["content"] ?? "No content available";
    } else {
      throw Exception('Failed to load content');
    }
  }

  bool isBase64(String str) {
    return RegExp(
            r'^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$')
        .hasMatch(str);
  }

  ImageProvider buildImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return MemoryImage(transparentImage);
    } else {
      try {
        if (imageUrl.startsWith('data:image')) {
          return MemoryImage(transparentImage);
        } else {
          return CachedNetworkImageProvider(imageUrl);
        }
      } catch (e) {
        return MemoryImage(transparentImage);
      }
    }
  }

  void _updatePaletteGenerator() {
    // Extract the RGB values from the thumbnailColor
    final r = widget.item.thumbnailColor.r;
    final g = widget.item.thumbnailColor.g;
    final b = widget.item.thumbnailColor.b;

    // Create a color from the RGB values
    final color = Color.fromRGBO(r, g, b, 1);

    setState(() {
      _dominantColor = color;
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
  }

  String formatPublishedDate(String dateStr) {
    try {
      final date = DateFormat('EEE, dd MMM yyyy HH:mm:ss Z').parse(dateStr);
      return DateFormat('H:mm a d MMM y').format(date.toLocal());
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    // BoxShadow coreshadowRest =
    //     generateBoxShadow(coreshadowOpacity, coreshadowSpread, coreshadowBlur);
    BoxShadow castshadowRest =
        generateBoxShadow(castshadowOpacity, castshadowSpread, castshadowBlur);
    // BoxShadow coreshadowHover = generateBoxShadow(
    //     coreshadowOpacity + .04, coreshadowSpread, coreshadowBlur);
    BoxShadow castshadowHover = generateBoxShadow(
        castshadowOpacity + .15, castshadowSpread + 4, castshadowBlur + 4);

    super.build(context);
    String imageUrl = widget.item.thumbnail;
    if (isBase64(imageUrl)) {
      imageUrl = 'data:image/png;base64,$imageUrl';
    }
    if (imageUrl.isEmpty) {
      // If thumbnail is empty, use the first image from the content
      Iterable<Match> matches = imageRegExp.allMatches(widget.item.content);
      if (matches.isNotEmpty) {
        imageUrl = matches.first.group(1) ?? '';
      }
    }

    return AnimatedContainer(
        duration: const Duration(milliseconds: 125),
        curve: Curves.easeInOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(23),
          boxShadow: _isHovering
              ? [
                  // coreshadowHover,
                  castshadowHover,
                ]
              : [
                  // coreshadowRest,
                  castshadowRest,
                ],
        ),
        child: MouseRegion(
          onEnter: (PointerEnterEvent event) =>
              setState(() => _isHovering = true),
          onExit: (PointerExitEvent event) =>
              setState(() => _isHovering = false),
          child: RepaintBoundary(
            child: Card(
              clipBehavior: Clip.antiAlias,
              elevation: elevation,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(23),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Image(
                    image: buildImage(imageUrl),
                    fit: BoxFit.cover,
                    width: double.maxFinite,
                    height: 300,
                  ),
                  Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              ImageFiltered(
                                imageFilter:
                                    ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                                child: Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.rotationZ(pi)
                                    ..scale(
                                        1.25), // Change the scale value as needed
                                  child: Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: buildImage(imageUrl),
                                        opacity: .9,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                color: Colors.white.withOpacity(0.55),
                              ),
                            ],
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
                                fontSize: 16,
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w700,
                                height: 1.33,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          (widget.item.author.isNotEmpty)
                              ? Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(12, 4, 12, 0),
                                  child: Text(
                                    widget.item.author,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Lato',
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black54,
                                    ),
                                  ),
                                )
                              : Container(), // Replace with your placeholder widget
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                            child: () {
                              String dateText;
                              try {
                                dateText = formatPublishedDate(
                                    widget.item.published ??
                                        widget.item.created);
                              } catch (e) {
                                dateText = 'Invalid date';
                              }
                              return Text(
                                dateText,
                                style: const TextStyle(
                                  fontSize: 10,
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
                                onPressed: () async {
                                  try {
                                    final content =
                                        await fetchContent(widget.item.link);

                                    showContentScreen(
                                        context,
                                        widget.item.title,
                                        widget.item.thumbnail,
                                        content,
                                        widget.item.link);
                                  } catch (e) {
                                    // Handle error or show a message
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
