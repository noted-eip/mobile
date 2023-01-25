import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noted_mobile/data/notifiers/user_notifier.dart';

final userProvider = ChangeNotifierProvider((ref) => UserNotifier());
