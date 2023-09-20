import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/pages/recommendation/definition_widget.dart';
import 'package:noted_mobile/pages/recommendation/image_widget.dart';
import 'package:noted_mobile/pages/recommendation/website_widget.dart';
import 'package:openapi/openapi.dart';
import 'package:tuple/tuple.dart';

class RecommendationPage extends ConsumerStatefulWidget {
  const RecommendationPage({
    super.key,
    required this.infos,
    required this.widgetList,
  });

  final Tuple2<String, String> infos;
  final List<V1Widget> widgetList;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _RecommendationPageState();
}

class _RecommendationPageState extends ConsumerState<RecommendationPage> {
  @override
  Widget build(BuildContext context) {
    List<Widget> generateWidgetList(List<V1Widget> widgetList) {
      List<Widget> result = [];
      for (var widget in widgetList) {
        if (widget.websiteWidget != null) {
          result.add(WebsiteWidget(
            widget: widget.websiteWidget!,
          ));
        } else if (widget.imageWidget != null) {
          result.add(ImageWidget(
            widget: widget.imageWidget!,
          ));
        } else if (widget.definitionWidget != null) {
          result.add(DefinitionWidget(
            widget: widget.definitionWidget!,
          ));
        }
      }
      return result;
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          ...generateWidgetList(widget.widgetList),
        ],
      ),
    );
  }
}
