/// Pausable streams of iterable.
///
/// The package lets a single-subscription `Stream<Iterable<T>>` (e.g. an
/// `async*` generator) pause after each non-empty Iterable and resume once the
/// Iterable has been iterated to its last element.
///
/// Public API:
/// - [PauseResumeStreamSubscriptionIterable] — an [Iterable] decorator that
///   pauses/resumes the source subscription while its data is consumed;
/// - [StreamIterableExtension.pauseOnNonEmptyResumeOnLast] — the extension
///   that turns such a stream into a pausable one.
library;

export 'src/pause_resume_stream_subscription_iterable.dart';
export 'src/stream_iterable_extension.dart';
