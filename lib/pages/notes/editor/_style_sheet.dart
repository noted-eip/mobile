import 'package:flutter/material.dart';
import 'package:noted_mobile/utils/color.dart';
import 'package:super_editor/super_editor.dart';

Stylesheet styleSheet = Stylesheet(
  rules: [
    StyleRule(
      BlockSelector.all,
      (doc, docNode) {
        return {
          "maxWidth": 640.0,
          "padding": const CascadingPadding.symmetric(horizontal: 24),
          "textStyle": const TextStyle(
            color: NotedColors.primary,
            fontSize: 16,
            height: 1.4,
          ),
        };
      },
    ),
    StyleRule(
      const BlockSelector("header1"),
      (doc, docNode) {
        return {
          "padding": const CascadingPadding.only(bottom: 14),
          "textStyle": const TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        };
      },
    ),
    StyleRule(
      const BlockSelector("header2"),
      (doc, docNode) {
        return {
          "padding": const CascadingPadding.only(bottom: 12),
          "textStyle": TextStyle(
            color: Colors.grey.shade900,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        };
      },
    ),
    StyleRule(
      const BlockSelector("header3"),
      (doc, docNode) {
        return {
          "padding": const CascadingPadding.only(bottom: 10),
          "textStyle": TextStyle(
            color: Colors.grey.shade900,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        };
      },
    ),
    StyleRule(
      const BlockSelector("listItem"),
      (doc, docNode) {
        return {
          "padding": const CascadingPadding.only(bottom: 10),
        };
      },
    ),
    StyleRule(
      const BlockSelector("paragraph").before("listItem"),
      (doc, docNode) {
        return {
          "padding": const CascadingPadding.only(bottom: 24),
        };
      },
    ),
    StyleRule(
      const BlockSelector("paragraph").before("header1"),
      (doc, docNode) {
        return {
          "padding": const CascadingPadding.only(bottom: 24),
        };
      },
    ),
    StyleRule(
      const BlockSelector("paragraph").before("header2"),
      (doc, docNode) {
        return {
          "padding": const CascadingPadding.only(bottom: 24),
        };
      },
    ),
    StyleRule(
      const BlockSelector("paragraph").before("header3"),
      (doc, docNode) {
        return {
          "padding": const CascadingPadding.only(bottom: 24),
        };
      },
    ),
    StyleRule(
      BlockSelector.all.last(),
      (doc, docNode) {
        return {
          "padding": const CascadingPadding.only(bottom: 96),
        };
      },
    ),
  ],
  inlineTextStyler: defaultInlineTextStyler,
);
