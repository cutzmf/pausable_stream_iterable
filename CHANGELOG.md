## 1.0.0+1

- Pause a single-subscription `Stream<Iterable<T>>` on every non-empty emitted `Iterable`.
- Resume it automatically once the `Iterable` has been consumed down to its last element (via `elementAt`, `last`, or an out-of-range access).
- Return a broadcast-like stream that replays the latest emitted `Iterable` to new listeners.
- Throw a `StateError` when called on a broadcast stream.
- Include a full Flutter example (`example/`) paginating the free Rick & Morty characters API.
