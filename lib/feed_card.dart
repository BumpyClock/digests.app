import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'feed_data_model.dart';

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

  @override
  Widget build(BuildContext context) {
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
    // get the image using cached_network_image package and assign it to image
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(23),
      ),
      elevation: 2, // Set some elevation for shadow
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CachedNetworkImage(
            imageUrl: imageUrl,
            width: double.maxFinite,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              height: 200,
              color: Colors.grey,
            ),
            errorWidget: (context, url, error) => Container(
              height: 200,
              color: Colors.red.shade50,
            ),
          ),
          // Placeholder for no image
          Stack(
            children: [
              // This container will be the background of the text and button elements
              Positioned.fill(
                child: Container(
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(imageUrl),
                      opacity: .5,
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: ClipRRect(
                    // make sure we apply clip it properly
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
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
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
                    padding: const EdgeInsets.fromLTRB(24, 4, 24, 4),
                    child: Text(
                      widget.item.author,
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w700,
                        color: Colors.black54,
                      ),
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

              // The button will be positioned on top of the background container
            ],
          ),
        ],
      ),
    );
  }
}
