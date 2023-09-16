import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/data/clients/tracker_client.dart';
import 'package:noted_mobile/data/notifiers/main_screen_notifier.dart';
import 'package:noted_mobile/data/notifiers/user_notifier.dart';

final userProvider = ChangeNotifierProvider((ref) => UserNotifier());
final mainScreenProvider =
    ChangeNotifierProvider((ref) => MainScreenNotifier());
final analyticsProvider =
    Provider<FirebaseAnalytics>((ref) => FirebaseAnalytics.instance);

final trackerProvider = Provider<TrackerService>((ref) {
  return TrackerService(ref: ref);
});
