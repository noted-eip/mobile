import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key, required this.summary, required this.infos});

  final String summary;
  final Tuple2<String, String> infos;

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const Text(
            "Résumé de la note",
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 40),
          MarkdownBody(
            data: widget.summary,
            selectable: true,
            styleSheet: MarkdownStyleSheet(
              listBullet: const TextStyle(fontSize: 30),
              h1: const TextStyle(fontSize: 45),
              h2: const TextStyle(fontSize: 40),
              h3: const TextStyle(fontSize: 35),
              h4: const TextStyle(fontSize: 30),
              h5: const TextStyle(fontSize: 25),
              h6: const TextStyle(fontSize: 20),
              p: const TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}
