import 'package:pausable_stream_iterable/pausable_stream_iterable.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'mocks.dart';

void main() {
  group('GIVEN stream subscription ', () {
    late MockStreamSubscription<Iterable<int>> subscription;
    late Iterable<int> iterable;

    setUp(() {
      subscription = MockStreamSubscription();
    });

    group('WHEN empty Iterable decorated with tested', () {
      late PauseResumeStreamSubscriptionIterable<int> tested;

      setUp(() {
        iterable = [];
        tested = PauseResumeStreamSubscriptionIterable<int>(subscription, iterable);
      });

      test('THEN subscription untouched', () => verifyZeroInteractions(subscription));

      test('AND elementAt called THEN subscription untouched AND Iterable behavior preserved', () {
        expect(() => tested.elementAt(0), throwsRangeError);
        verifyZeroInteractions(subscription);
      });

      test('AND last called THEN subscription untouched AND Iterable behavior preserved', () {
        expect(() => tested.last, throwsA(anything));
        verifyZeroInteractions(subscription);
      });
    });

    group('WHEN filled Iterable [1, 2, 3] decorated with tested', () {
      late PauseResumeStreamSubscriptionIterable<int> tested;

      setUp(() {
        iterable = [1, 2, 3];
        tested = PauseResumeStreamSubscriptionIterable<int>(subscription, iterable);
      });

      test('THEN subscription is only paused once', () {
        verify(() => subscription.pause()).called(1);
        verifyNoMoreInteractions(subscription);
      });

      group('clear constructor interactions', () {
        setUp(() => clearInteractions(subscription));

        test('WHEN elementAt called for indexes except last THEN subscription untouched', () {
          tested.elementAt(0);
          tested.elementAt(1);
          verifyZeroInteractions(subscription);
        });

        test('WHEN elementAt called for last index THEN subscription is only resumed once', () {
          tested.elementAt(2);
          verify(() => subscription.resume()).called(1);
          verifyNoMoreInteractions(subscription);
        });

        test('WHEN last called THEN subscription is only resumed once', () {
          tested.last;
          verify(() => subscription.resume()).called(1);
          verifyNoMoreInteractions(subscription);
        });

        test(
          'WHEN elementAt called for index > last index THEN subscription is only resumed once AND Iterable behavior preserved',
          () {
            expect(() => tested.elementAt(3), throwsRangeError);
            verify(() => subscription.resume()).called(1);
            verifyNoMoreInteractions(subscription);
          },
        );
      });
    });
  });
}
