import 'dart:async';

// final firstEventListener = FirstEventListener<Some>();
// someStream.listen((elem) {
//    elem.update(elem);
// })
//
// firstEventListener.reset(); // begin
//   ...
// Some firstSome = await firstEventListener.firstEvent; // get the first Event from `.reset()` call or wait for it.
//
class FirstEventListener<Event> {
  Event _firstEvent;
  Completer<Event> _firstEventCompleter;

  reset() {
    _firstEvent = null;
  }

  Future<Event> get firstEvent {
    if (_firstEvent != null) {
      return Future.value(_firstEvent);
    }

    if (_firstEventCompleter == null) {
      _firstEventCompleter = Completer<Event>();
    }
    return _firstEventCompleter.future;
  }

  update(Event event) {
    if (_firstEvent != null) {
      return;
    }

    _firstEvent = event;
    if (_firstEventCompleter != null) {
      _firstEventCompleter.complete(event);
      _firstEventCompleter = null;
    }
  }
}
