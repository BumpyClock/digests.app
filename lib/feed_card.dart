import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'feed_data_model.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:intl/intl.dart';
import 'package:html/parser.dart' as htmlparser;
import 'package:flutter/foundation.dart';



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

  Color? _dominantColor;
  PaletteGenerator? _paletteGenerator;
  final double coreshadowOpacity = .1;
  final double castshadowOpacity = .08;
  final double coreshadowBlur = 3;
  final double castshadowBlur = 12;
  final double coreshadowSpread = 1;
  final double castshadowSpread = 8;

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

 Future<void> _updatePaletteGenerator() async {
  if (kIsWeb) {
    setState(() {
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
        _paletteGenerator = paletteGenerator;
        // Choose the dominant color or fallback to a default color
        _dominantColor =
            paletteGenerator.vibrantColor?.color ?? Colors.blueGrey;
        boxShadowCore = BoxShadow(
          color: _dominantColor?.withOpacity(coreshadowOpacity) ?? Colors.transparent,
          spreadRadius: coreshadowSpread,
          blurRadius: coreshadowBlur,
          offset: const Offset(0, 0),
        );
        boxShadowCast = BoxShadow(
          color: _dominantColor?.withOpacity(castshadowOpacity) ?? Colors.transparent,
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
          color: _dominantColor?.withOpacity(coreshadowOpacity) ?? Colors.transparent,
          spreadRadius: coreshadowSpread,
          blurRadius: coreshadowBlur,
          offset: const Offset(0, 0),
        );
        boxShadowCast = BoxShadow(
          color: _dominantColor?.withOpacity(castshadowOpacity) ?? Colors.transparent,
          spreadRadius: castshadowSpread,
          blurRadius: castshadowBlur,
          offset: const Offset(0, 0),
        );
      });
    }
  }
}
  @override
  Widget build(BuildContext context) {
    BoxShadow coreShadow_rest = BoxShadow(
      color: _dominantColor?.withOpacity(coreshadowOpacity) ?? Colors.transparent,
      spreadRadius: coreshadowSpread,
      blurRadius: coreshadowBlur,
      offset: const Offset(0, 0),
    );

    BoxShadow castShadow_rest = BoxShadow(
      color: _dominantColor?.withOpacity(castshadowOpacity) ?? Colors.transparent,
      spreadRadius: castshadowSpread,
      blurRadius: castshadowBlur,
      offset: const Offset(0, 0),
    );

    BoxShadow coreShadow_hover = BoxShadow(
      color: _dominantColor?.withOpacity(coreshadowOpacity+.1) ?? Colors.transparent,
      spreadRadius: coreshadowSpread,
      blurRadius: coreshadowBlur,
      offset: const Offset(0, 0),
    );

    BoxShadow castShadow_hover = BoxShadow(
      color: _dominantColor?.withOpacity(castshadowOpacity+.1) ?? Colors.transparent,
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
              boxShadowCore = coreShadow_hover,
              boxShadowCast = castShadow_hover,
            }),
        onExit: (PointerExitEvent event) => setState(() => {
              boxShadowCore = coreShadow_rest,
              boxShadowCast = castShadow_rest,
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
                              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
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
                            child: Text(
                              DateFormat('H:mm a d/M/y').format(
                                DateTime.parse(widget.item.created).toLocal(),
                              ),
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w700,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          Padding(
  padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
  child: Text(
    htmlparser.parse(widget.item.content).querySelector('p')?.text ?? '',
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
                                child: const Text('Read more'),
                                onPressed: () {
                                  // Implement your read more action
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
