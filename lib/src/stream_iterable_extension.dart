import 'dart:async';

import 'package:async/async.dart';
import 'package:rxdart/rxdart.dart';

import 'pause_resume_stream_subscription_iterable.dart';

extension StreamIterableExtension<T> on Stream<Iterable<T>> {
  /// Subscribes only to a single-subscription (non-broadcast) [Stream] (e.g., an `async*` generator function).
  /// Pauses the [Stream] whenever a non-empty [Iterable] is emitted. See [PauseResumeStreamSubscriptionIterable]
  /// Resumes the [Stream] when the last item of the [Iterable] is accessed. See [PauseResumeStreamSubscriptionIterable]
  /// Broadcasts the last emitted [Iterable] to new subscribers.
  Stream<Iterable<T>> pauseOnNonEmptyResumeOnLast() {
    if (isBroadcast) {
      throw StateError(
        'Use non broadcast stream. Ex. async* generator function',
      );
    }

    final streamSubscription = listen(null);

    final pausedResumedStream = SubscriptionStream(streamSubscription).map(
      (iterable) => PauseResumeStreamSubscriptionIterable(streamSubscription, iterable),
    );

    return pausedResumedStream.shareReplay(maxSize: 1);
  }
}
