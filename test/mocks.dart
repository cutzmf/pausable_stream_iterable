import 'dart:async';

import 'package:mocktail/mocktail.dart';

class MockStreamSubscription<T> extends Mock implements StreamSubscription<T> {}
