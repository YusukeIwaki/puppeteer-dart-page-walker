class ThrottledValue<T> {
  final int delay;
  late int _lastUpdated;
  T? _lastValue;
  ThrottledValue({this.delay = 1000});

  bool update(T value) {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (_lastValue != null &&
        _lastValue == value &&
        now < _lastUpdated + delay) {
      return false;
    }
    _lastUpdated = now;
    _lastValue = value;
    return true;
  }
}
