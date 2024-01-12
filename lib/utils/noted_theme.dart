import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noted_mobile/utils/color.dart';

TextTheme notedTextTheme = GoogleFonts.nunitoSansTextTheme();

AppBarTheme notedAppBarTheme = const AppBarTheme(
  backgroundColor: Colors.white,
  foregroundColor: Colors.black,
  elevation: 0,
  iconTheme: IconThemeData(color: Colors.black),
);

ColorScheme notedColorScheme =
    ColorScheme.fromSeed(seedColor: NotedColors.primary);
