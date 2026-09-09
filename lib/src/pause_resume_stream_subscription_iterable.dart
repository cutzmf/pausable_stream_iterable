import 'dart:async';
import 'dart:collection';

/// An [Iterable] decorator that controls a data stream's [StreamSubscription] to pause and resume it.
///
/// It pauses when [Iterable] is not empty.
/// It resumes when [Iterable] last element requested via [Iterable.elementAt] or [Iterable.last].
class PauseResumeStreamSubscriptionIterable<T> with IterableMixin<T> {
  PauseResumeStreamSubscriptionIterable(this._streamSubscription, this._decoratedIterable) {
    if (_decoratedIterable.isNotEmpty) _streamSubscription.pause();
  }

  final Iterable<T> _decoratedIterable;

  final StreamSubscription<Iterable<T>> _streamSubscription;

  @override
  T elementAt(int index) {
    final lastIndex = length - 1;

    if (index >= lastIndex && !lastIndex.isNegative) _streamSubscription.resume();

    return super.elementAt(index);
  }

  @override
  T get last {
    try {
      final element = super.last;

      _streamSubscription.resume();

      return element;
    } on Object {
      rethrow;
    }
  }

  @override
  Iterator<T> get iterator => _decoratedIterable.iterator;
}
