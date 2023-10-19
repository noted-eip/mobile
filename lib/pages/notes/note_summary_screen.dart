import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

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
    String text = "${widget.summary}\n\n${widget.summary}\n\n${widget.summary}";
    return SingleChildScrollView(
      child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
    );
  }
}
