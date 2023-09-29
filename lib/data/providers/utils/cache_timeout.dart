import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//TODO: add cache timeout

void cacheTimeout(
  AutoDisposeFutureProviderRef ref,
  String title, {
  int hour = 1,
  int minute = 0,
  int seconde = 0,
}) {
  // print('init: $title');

  final link = ref.keepAlive();

  // a timer to be used by the callbacks below
  Timer? timer;
  // An object from package:dio that allows cancelling http requests
  final cancelToken = CancelToken();
  // When the provider is destroyed, cancel the http request and the timer
  ref.onDispose(() {
    // print('dispose: $title');
    timer?.cancel();
    cancelToken.cancel();
  });
  // // When the last listener is removed, start a timer to dispose the cached data
  ref.onCancel(() {
    // print('cancel: $title');
    // start a 30 second timer
    timer = Timer(
        Duration(
          hours: hour,
          minutes: minute,
          seconds: seconde,
        ), () {
      // dispose on timeout
      link.close();
    });
  });
  // // If the provider is listened again after it was paused, cancel the timer
  ref.onResume(() {
    timer?.cancel();
    // print('resume: $title');
  });
}
