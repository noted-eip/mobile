import 'dart:convert';
import 'package:noted_mobile/pages/recommendation/webview_widget.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:openapi/openapi.dart';
import 'package:http/http.dart' as http;

class WebsiteWidget extends StatefulWidget {
  const WebsiteWidget({super.key, required this.widget});

  final V1WebsiteWidget widget;

  @override
  State<WebsiteWidget> createState() => _WebsiteWidgetState();
}

class _WebsiteWidgetState extends State<WebsiteWidget> {
  String getImageUrl(String baseUrl) {
    final uri = Uri.parse(baseUrl);
    final List<String> segments = uri.pathSegments;
    final String dernierSegment = segments.isNotEmpty ? segments.last : '';
    final List<String> parties = dernierSegment.split(':');
    String texteApresDernierDeuxPoints = '';

    if (parties.length > 1) {
      texteApresDernierDeuxPoints = parties.last;
    }

    texteApresDernierDeuxPoints = Uri.encodeFull(texteApresDernierDeuxPoints);

    return texteApresDernierDeuxPoints;
  }

  Future<String> getWikipediaImage(String imgName) async {
    String imgUrl = '';

    try {
      final response = await http.get(
        Uri.parse(
          'https://en.wikipedia.org/w/api.php?action=query&prop=imageinfo&iiprop=url&titles=File:$imgName&continue=&format=json&origin=*',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null &&
            data['query']['pages']['-1'] != null &&
            data['query']['pages']['-1']['imageinfo'] != null) {
          imgUrl = data['query']['pages']['-1']['imageinfo'][0]['url'];
        }
      }
    } catch (error) {
      return 'An unexpected error occurred';
    }

    return imgUrl;
  }

  Future<Widget?> getImageWidget() async {
    final String imageUrl = widget.widget.imageUrl!;
    final String decodedUrl = getImageUrl(imageUrl);
    final String imgUrl = await getWikipediaImage(decodedUrl);

    if (imgUrl == '') {
      return const SizedBox();
    }

    if (imageUrl.endsWith(".png") ||
        imageUrl.endsWith(".jpg") ||
        imageUrl.endsWith(".jpeg")) {
      return Image.network(imgUrl, fit: BoxFit.cover, height: 200);
    } else if (imageUrl.endsWith(".svg")) {
      return SvgPicture.network(
        imgUrl,
        placeholderBuilder: (BuildContext context) =>
            const CircularProgressIndicator(),
        height: 200,
        width: 200,
      );
    }

    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebViewExample(
              url: widget.widget.url,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          shape: BoxShape.rectangle,
          color: Colors.grey.withOpacity(0.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.widget.keyword, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 5),
            Text(widget.widget.type, style: const TextStyle(fontSize: 16)),
            if (widget.widget.summary != null &&
                widget.widget.summary!.isNotEmpty) ...{
              const SizedBox(height: 20),
              Text(widget.widget.summary!,
                  style: const TextStyle(fontSize: 14)),
            },
            const SizedBox(height: 10),
            Center(
              child: FutureBuilder(
                builder:
                    (BuildContext context, AsyncSnapshot<Widget?> snapshot) {
                  if (snapshot.hasData) {
                    return snapshot.data!;
                  } else if (snapshot.hasError) {
                    return const Text('Error');
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
                future: getImageWidget(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
