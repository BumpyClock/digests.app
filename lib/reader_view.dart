import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:url_launcher/url_launcher.dart';

void showContentScreen(BuildContext context, String title, String thumbnail,
    String content, String link) {
  String imgTag = thumbnail != null ? '<img src="$thumbnail" ></img>' : '';
  String titleTag = '<h1>$title</h1>';
  String dividerTag = '<hr></hr>';
  content = titleTag + dividerTag + imgTag + content;
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          centerTitle: true,
          toolbarHeight: 48,
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          elevation: 1,
          scrolledUnderElevation: 4,
          actions: [
            TextButton(
              onPressed: () async {
                if (await canLaunchUrl(Uri.parse(link))) {
                  await launchUrl(Uri.parse(link));
                } else {
                  throw 'Could not launch $link';
                }
              },
              child: const Text(
                'View in browser',
                // style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        body: Center(
          child: Container(
            margin: const EdgeInsets.fromLTRB(36, 0, 36, 0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                children: [
                  // Text(
                  //   title,
                  //   style: const TextStyle(
                  //     fontSize: 24,
                  //     fontWeight: FontWeight.w700,
                  //   ),
                  //   textAlign: TextAlign.center,
                  //   maxLines: 4,
                  //   overflow: TextOverflow.ellipsis,
                  // ),
                  // const Divider(
                  //   color: Colors.grey,
                  //   thickness: 1,
                  // ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: SingleChildScrollView(
                      child: HtmlWidget(
                        content,
                        enableCaching: true,
                        buildAsync: true,
                        customStylesBuilder: (element) {
                          switch (element.localName) {
                            case 'hr':
                              return {
                                'height': '1px',
                                'border-top': '1px solid gray',
                                'margin': '20px 0',
                                'opacity': '0.5'
                              };
                            case 'p':
                              return {
                                'font-size': '20px',
                                'font-family': 'Lato',
                                'line-height': '2',
                                'font-weight': '400'
                              };
                            case 'h1':
                              return {
                                'font-size': '28px',
                                'font-family': 'Lato',
                                'font-weight': '700'
                              };
                            case 'h2':
                              return {
                                'font-size': '24px',
                                'font-family': 'Lato',
                                'font-weight': '700'
                              };
                            case 'img':
                              return {
                                'max-height': '400px',
                                'object-fit': 'cover',
                                'border-radius': '8px',
                                'margin': '0 auto'
                              };
                            // Add more cases as needed
                            default:
                              return null;
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
