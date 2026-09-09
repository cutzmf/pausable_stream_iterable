# pausable_stream_iterable

Pause a single-subscription `Stream<Iterable<T>>` whenever it emits a non-empty `Iterable`, and resume it automatically once that `Iterable` has been consumed down to its last element.

## Pagination use case

The intended use case is lazy, "infinite" pagination: a pausable stream makes an `async*` generator fetch the next page only after the current one has been fully read by the client(ex. Flutter `ListView.builder`), instead of pulling every page as fast as the network allows.

## Features

- Pauses the source subscription on every non-empty emitted `Iterable`.
- Resumes it automatically when the last element is requested: `iterable.last`, `iterable.elementAt(length - 1)`, or an out-of-range access such as `elementAt(length)`.
- Returns a broadcast stream that replays the latest emitted `Iterable` to new listeners, so it works out of the box with `StreamBuilder`.
- Throws a `StateError` when called on a broadcast stream.

## Getting started

```console
dart pub add pausable_stream_iterable
```

## Usage

Wrap your single-subscription `Stream<Iterable<T>>` (for example an `async*` generator) with `pauseOnNonEmptyResumeOnLast()`.

```dart
import 'package:pausable_stream_iterable/pausable_stream_iterable.dart';

// `sourceStream` — your own non-broadcast stream.
// `T` — the element type of each emitted Iterable.
final Stream<Iterable<T>> stream = sourceStream.pauseOnNonEmptyResumeOnLast();

stream.listen((iterable) {
  // The source is already paused right after this non-empty iterable is
  // delivered.

  iterable.elementAt(0);
  // Reading a non-last element changes nothing: the source stays paused.

  iterable.elementAt(iterable.length - 1);
  // The last element was requested: the source resumes, and the next
  // iterable, if any, can be delivered.

  iterable.last;
  // `last` resumes the source as well.

  iterable.elementAt(iterable.length); // (index >= length)
  // Reading an index beyond the end resumes the source
  // and the access then throws a RangeError, preserving the behaviour of the underlying Iterable
});
```

### When is the stream resumed?

An emitted `Iterable` stays paused until one of the following happens:

- `elementAt(iterable.length - 1)` — the last element is requested;
- `iterable.last` is read;
- an index beyond the end is requested, for example `elementAt(iterable.length)`. The source is resumed first, and the access then throws a `RangeError`, preserving the behaviour of the underlying `Iterable`.

Reading only the first elements keeps the source paused. Empty `Iterable`s are delivered without being paused.

## Lazy pagination

A natural fit is paging through a remote collection. Consider an `async*` generator that keeps one list, appends every new page to it, and yields the growing list:

```dart
final characters = <Character>[];

Stream<Iterable<Character>> paginatedCharacters(String pageUrl) async* {
  final response = await dio.get(pageUrl);
  final page = PageOfCharacters.fromJson(response.data);

  yield characters..addAll(page.results);

  final nextPageUrl = page.info.next;
  if (nextPageUrl == null) return; // No more pages — the stream completes.

  yield* paginatedCharacters(nextPageUrl);
}
```

Subscribed as-is, this stream delivers every page back-to-back as soon as the network responds — the whole collection is downloaded even if the UI has shown only the first few rows. Wrapping it in `pauseOnNonEmptyResumeOnLast()` reverses that: each page is delivered paused, and the next page is fetched only once the current one has been read up to its last element.

```dart
final charactersStream =
    paginatedCharacters(firstPageUrl).pauseOnNonEmptyResumeOnLast();
```

Because `ListView.builder` builds only the visible rows, the last element is requested exactly when the user scrolls to the bottom, so the pages are fetched on demand:

```dart
StreamBuilder<Iterable<Character>>(
  stream: charactersStream,
  builder: (context, snapshot) {
    final characters = snapshot.data;
    if (characters == null) {
      return const CircularProgressIndicator();
    }

    // The stream completes when every page has been fetched.
    final isFullySynced = snapshot.connectionState == ConnectionState.done;
    final skeletonItemsCount = isFullySynced ? 0 : 3;

    return ListView.builder(
      itemCount: characters.length + skeletonItemsCount,
      itemBuilder: (context, index) {
        try {
          // Building the row for the last element resumes the source and
          // starts the request for the next page.
          return CharacterTile(characters.elementAt(index));
        } on RangeError {
          // Rows past the end of the loaded data are skeleton rows. Requesting
          // such a row is an out-of-range access, which also resumes the source.
          return const LinearProgressIndicator();
        }
      },
    );
  },
)
```

Errors from the source stream propagate to the `StreamBuilder` as usual. The runnable example in `example/` additionally shows how to handle them with a retry button.

## API

- `StreamIterableExtension<T>.pauseOnNonEmptyResumeOnLast()` — the extension method on a non-broadcast `Stream<Iterable<T>>`. It returns a broadcast-like stream that pauses on each non-empty emitted `Iterable` and resumes when its last element is requested. Calling it on a broadcast stream throws a `StateError`.
- `PauseResumeStreamSubscriptionIterable<T>` — the `Iterable` decorator that pauses and resumes the underlying `StreamSubscription`.

## Example app

A complete Flutter app paginating the free Rick & Morty characters API is available in `example/`. Note that reaching that API may require a VPN.

## Compatibility

- Dart SDK: `>=3.0.0 <4.0.0`.
- `async`: `>=2.5.0 <3.0.0` — from the first stable null-safe release. Only `SubscriptionStream` is used, and its API is unchanged across this range.
- `rxdart`: `>=0.26.0 <0.29.0` — from the first stable null-safe release. Only `shareReplay(maxSize: 1)` is used, and its API is unchanged across this range.
