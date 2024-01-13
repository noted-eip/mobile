import 'dart:async';

class Debouncer {
  Debouncer();

  Timer? _timer;
  void run(Function() action, {int waitForMs = 500}) {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    }
    _timer = Timer(Duration(milliseconds: waitForMs), action);
  }
}
