import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noted_mobile/utils/color.dart';

TextTheme notedTextTheme = GoogleFonts.nunitoSansTextTheme(
    //  TextTheme(
    //   displayLarge: TextStyle(
    //     fontSize: 96,
    //     fontWeight: FontWeight.w300,
    //     letterSpacing: -1.5,
    //   ),
    //   displayMedium: TextStyle(
    //     fontSize: 60,
    //     fontWeight: FontWeight.w300,
    //     letterSpacing: -0.5,
    //   ),
    //   displaySmall: TextStyle(
    //     fontSize: 48,
    //     fontWeight: FontWeight.w400,
    //   ),
    //   headlineMedium: TextStyle(
    //     fontSize: 34,
    //     fontWeight: FontWeight.w400,
    //     letterSpacing: 0.25,
    //   ),
    //   headlineSmall: TextStyle(
    //     fontSize: 24,
    //     fontWeight: FontWeight.w400,
    //   ),
    //   titleLarge: TextStyle(
    //     fontSize: 20,
    //     fontWeight: FontWeight.w500,
    //     letterSpacing: 0.15,
    //   ),
    //   titleMedium: TextStyle(
    //     fontSize: 16,
    //     fontWeight: FontWeight.w400,
    //     letterSpacing: 0.15,
    //   ),
    //   titleSmall: TextStyle(
    //     fontSize: 14,
    //     fontWeight: FontWeight.w500,
    //     letterSpacing: 0.1,
    //   ),
    //   bodyLarge: TextStyle(
    //     fontSize: 16,
    //     fontWeight: FontWeight.w400,
    //     letterSpacing: 0.5,
    //   ),
    //   bodyMedium: TextStyle(
    //     fontSize: 14,
    //     fontWeight: FontWeight.w400,
    //     letterSpacing: 0.25,
    //   ),
    //   labelLarge: TextStyle(
    //     fontSize: 14,
    //     fontWeight: FontWeight.w500,
    //     letterSpacing: 1.25,
    //   ),
    //   bodySmall: TextStyle(
    //     fontSize: 12,
    //     fontWeight: FontWeight.w400,
    //     letterSpacing: 0.4,
    //   ),
    //   labelSmall: TextStyle(
    //     fontSize: 10,
    //     fontWeight: FontWeight.w400,
    //     letterSpacing: 1.5,
    //   ),
    // ),
    );

AppBarTheme notedAppBarTheme = const AppBarTheme(
  backgroundColor: Colors.white,
  foregroundColor: Colors.black,
  elevation: 0,
  iconTheme: IconThemeData(color: Colors.black),
);

ColorScheme notedColorScheme =
    ColorScheme.fromSeed(seedColor: NotedColors.primary);
