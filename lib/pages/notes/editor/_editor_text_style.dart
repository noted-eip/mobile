import 'package:super_editor/super_editor.dart';

class NotedEditorTextStyle {
  final int start;
  final int end;
  final Attribution attribution;
  final DocumentNode node;

  NotedEditorTextStyle({
    required this.start,
    required this.end,
    required this.attribution,
    required this.node,
  });

  @override
  String toString() {
    return "start: $start, end: $end, attribution: ${attribution.id}, node: ${node.id}";
  }
}
