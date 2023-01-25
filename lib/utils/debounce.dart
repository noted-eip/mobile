import 'dart:async';
import 'package:flutter/material.dart';

class Debouncer {
  Debouncer({required this.seconds});
  final int seconds;
  Timer? _timer;
  void run(VoidCallback action) {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    }
    _timer = Timer(Duration(seconds: seconds), action);
  }
}
