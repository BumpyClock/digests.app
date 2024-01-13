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
  bool _isHovering = false;
  Color? _dominantColor;
  final double coreshadowOpacity = .08;
  final double castshadowOpacity = .04;
  final double coreshadowBlur = 1;
  final double castshadowBlur = 4;
  final double coreshadowSpread = 1;
  final double castshadowSpread = 4;
  final RegExp imageRegExp = RegExp(r'<img.+?src="(.+?)".*?>');
   BoxShadow boxShadowCore = BoxShadow();
   BoxShadow boxShadowCast = BoxShadow();
Uint8List transparentImage = base64Decode('R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7');

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
  }

  Future<String> fetchContent(String url) async {
    final response = await http.post(
      Uri.parse('https://rss.bumpyclock.com/getreaderview'),
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
  try {
    base64.decode(str);
    return true;
  } catch (e) {
    return false;
  }
}
ImageProvider buildImage(String imageUrl) {
  try {
  if (imageUrl.startsWith('data:image')) {
    final base64Image = imageUrl.split(',').last;
    debugPrint('base64Image: $base64Image');
    final decodedImage = base64Decode(base64Image);
    debugPrint('decodedImage: $decodedImage');
    return MemoryImage(decodedImage);
  } else {
    return CachedNetworkImageProvider(imageUrl);
  }
  }
  catch(e){
    debugPrint('Error building image: $e');
    return MemoryImage(transparentImage);
  }
}
  Future<void> _updatePaletteGenerator() async {
  if (kIsWeb || widget.item.thumbnail.startsWith('data:image')) {
      setState(() {
        buttonText = 'Read more';
        _dominantColor = Colors.grey.withOpacity(.12);
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
              paletteGenerator.dominantColor?.color ?? Colors.blueGrey;
        });
      }
    } catch (e) {
      debugPrint('Error generating palette: $e');
      if (mounted) {
        setState(() {
          _dominantColor = Colors.black.withOpacity(.12);
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
    try {
      final date = DateFormat('EEE, dd MMM yyyy HH:mm:ss Z').parse(dateStr);
      return DateFormat('H:mm a d MMM y').format(date.toLocal());
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    BoxShadow coreshadowRest =
        generateBoxShadow(coreshadowOpacity, coreshadowSpread, coreshadowBlur);
    BoxShadow castshadowRest =
        generateBoxShadow(castshadowOpacity, castshadowSpread, castshadowBlur);
    BoxShadow coreshadowHover = generateBoxShadow(
        coreshadowOpacity + .1, coreshadowSpread + 1, coreshadowBlur + 2);
    BoxShadow castshadowHover = generateBoxShadow(
        castshadowOpacity + .15, castshadowSpread + 6, castshadowBlur + 6);

    super.build(context);
    String imageUrl = widget.item.thumbnail;
    if(isBase64(imageUrl)){
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
        duration: const Duration(milliseconds: 75),
        curve: Curves.easeInOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(23),
          boxShadow: _isHovering
              ? [
                  coreshadowHover,
                  castshadowHover,
                ]
              : [
                  coreshadowRest,
                  castshadowRest,
                ],
        ),
        child: MouseRegion(
          onEnter: (PointerEnterEvent event) =>
              setState(() => _isHovering = true),
          onExit: (PointerExitEvent event) =>
              setState(() => _isHovering = false),
          child: RepaintBoundary(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 125),
              curve: Curves.easeInOutCubic,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(23),
                
              ),
              child: Card(
                clipBehavior: Clip.antiAlias,
                // elevation: elevation,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(23),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
FadeInImage.memoryNetwork(
  placeholder: transparentImage, // kTransparentImage is a 1x1 transparent pixel
  image: imageUrl,
  fit: BoxFit.cover,
  width: double.maxFinite,
  height: 200,
),                   Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                ImageFiltered(
                                  imageFilter:
                                      ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: buildImage(imageUrl),
                                        opacity: .7,
                                        fit: BoxFit.cover,
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
                            (widget.item.author?.isNotEmpty ?? false)
                                ? Padding(
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
                                  )
                                : Container(),  // Replace with your placeholder widget
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                              child: () {
                                String dateText;
                                try {
                                  dateText = formatPublishedDate(widget.item.published ?? widget.item.created);
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
          ),
        ));
  }
}
