import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

cacheTimeout(
  AutoDisposeFutureProviderRef ref,
  String title, {
  int hour = 1,
  int minute = 0,
  int seconde = 0,
}) {
  if (kDebugMode) {
    print('init: $title');
  }
  ref.onCancel(() => print('cancel: $title'));
  ref.onResume(() => print('resume: $title'));
  ref.onDispose(() => print('dispose: $title'));
  final link = ref.keepAlive();

  // a timer to be used by the callbacks below
  Timer? timer;
  // An object from package:dio that allows cancelling http requests
  final cancelToken = CancelToken();
  // When the provider is destroyed, cancel the http request and the timer
  ref.onDispose(() {
    timer?.cancel();
    cancelToken.cancel();
  });
  // When the last listener is removed, start a timer to dispose the cached data
  ref.onCancel(() {
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
  // If the provider is listened again after it was paused, cancel the timer
  ref.onResume(() {
    timer?.cancel();
  });
}
