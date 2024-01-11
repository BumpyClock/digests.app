//Data model

import 'package:flutter/material.dart';

class Feed {
  final String status;
  final String siteTitle;
  final String feedTitle;
  final String feedUrl;
  final String description;
  final String author;
  final String lastUpdated;
  // final String lastRefreshed;
  final String favicon;
  final List<Item> items;

  Feed({
    required this.status,
    required this.siteTitle,
    required this.feedTitle,
    required this.feedUrl,
    required this.description,
    required this.author,
    required this.lastUpdated,
    // required this.lastRefreshed,
    required this.favicon,
    required this.items,
  });

  factory Feed.fromJson(Map<String, dynamic> json) {
    // var itemsJson = json['items'] as List<dynamic>;
    // var items = itemsJson.map((itemJson) => Item.fromJson(itemJson)).toList();

    return Feed(
      // Assuming these are the fields in your Feed class.
      // Update the fields as per your actual Feed class structure.
      status: json['status'] as String? ?? '',
      siteTitle: json['siteTitle'] as String? ?? '',
      feedTitle: json['feedTitle'] as String? ?? '',
      feedUrl: json['feedUrl'] as String? ?? '',
      description: json['description'] as String? ?? '',
      author: json['author'] is List
          ? (json['author'] as List).join(', ')
          : json['author'] as String? ?? '',
      lastUpdated: json['lastUpdated'] as String? ?? '',
      // lastRefereshed: json['lastrefereshed'] as String? ?? '',
      favicon: json['favicon'] as String? ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => Item.fromJson(item))
              .toList() ??
          [],
      // ... other fields
    );
  }
}

class Item {
  final String id;
  final String title;
  final String thumbnail;
  final String link;
  final String author;
  final String published;
  final String created;
  final List<String> category;
  final String content;
  final List<dynamic> media;
  final List<dynamic> enclosures;
  final PodcastInfo podcastInfo;

  Item({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.link,
    required this.author,
    required this.published,
    required this.created,
    required this.category,
    required this.content,
    required this.media,
    required this.enclosures,
    required this.podcastInfo,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    try {
      // Debug statements to check if the json is parsed correctly
      // print('JSON: $json');
      // print('id: ${json['id']}');
      // print('Title: ${json['title']}');
      // print('Thumbnail: ${json['thumbnail']}');
      // print('link: ${json['link']}');
      // print('author: ${json['author']}');
      // print('published: ${json['published']}');
      // print('created: ${json['created']}');
      // print('category: ${json['category']}');
      // print('content: ${json['content']}');
      // print('media: ${json['media']}');
      // print('enclosures: ${json['enclosures']}');
      // print('podcastInfo: ${json['podcastInfo']}');

      return Item(
        id: json['id'] as String? ?? '', // Providing a default value if null
        title: json['title'] as String? ?? '',
        thumbnail: json['thumbnail'] as String? ?? '',
        link: json['link'] as String? ?? '',
        author: json['author'] is List
            ? (json['author'] as List).join(', ')
            : json['author'] as String? ?? '',
        published: json['published'] as String? ?? '',
        created: json['created'] as String? ?? '',
      category: json['category'] == null 
          ? <String>[] 
          : (json['category'] as List<dynamic>).map<String>((item) {
              try {
                if (item is String) {
                  return item;
                } else if (item is Map<String, dynamic> && item.containsKey('\$text')) {
                  return item['\$text'] as String;
                } else {
                  return '';
                }
              } catch (e) {
                return '';
              }
            }).toList(),
        content: json['content'] as String? ?? '',
        media: List<dynamic>.from(json['media'] ?? []),
        enclosures: List<dynamic>.from(json['enclosures'] ?? []),
        podcastInfo: PodcastInfo.fromJson(json['podcastInfo'] ?? {}),
      );
    } catch (e) {
      debugPrint('Error parsing item JSON: $json');
      debugPrint('Exception: $e');
      rethrow; // Re-throw the exception after logging.
    }
  }
}

class PodcastInfo {
  final String author;
  final String image;
  final List<dynamic> categories;

  PodcastInfo(
      {required this.author, required this.image, required this.categories});

  factory PodcastInfo.fromJson(Map<String, dynamic> json) {
    return PodcastInfo(
      author: json['author'],
      image: json['image'],
      categories: json['categories'],
    );
  }
}
