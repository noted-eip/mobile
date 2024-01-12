import 'dart:async';

class PeriodicFunctionExecutor {
  PeriodicFunctionExecutor();

  Timer? _timer;

  void start(Function functionToExecute, Duration duration) {
    stop();
    _timer = Timer.periodic(duration, (Timer timer) {
      functionToExecute();
    });
  }

  void stop() {
    _timer?.cancel();
  }
}
