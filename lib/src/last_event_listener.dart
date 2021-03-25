import 'dart:async';

// final lastEventListener = LastEventListener<Some>();
// someStream.listen((elem) {
//    elem.update(elem);
// })
//
// lastEventListener.reset(); // begin
//   ...
// Some lastSome = await lastEventListener.lastEvent; // get the last Event from `.reset()` call or wait for first Event.
//
class LastEventListener<Event> {
  Event? _lastEvent;
  Completer<Event>? _lastEventCompleter;

  void reset() {
    _lastEvent = null;
  }

  Future<Event> get lastEvent {
    if (_lastEvent != null) {
      return Future.value(_lastEvent);
    }

    _lastEventCompleter ??= Completer<Event>();
    return _lastEventCompleter!.future;
  }

  void update(Event event) {
    _lastEvent = event;
    _lastEventCompleter?.complete(event);
    _lastEventCompleter = null;
  }
}
