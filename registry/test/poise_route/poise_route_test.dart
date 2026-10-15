import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poise/poise.dart';
import 'package:poise_registry/poise_route/poise_route.dart';

void main() {
  final navigatorKey = GlobalKey<NavigatorState>();
  const first = ValueKey('first');
  const second = ValueKey('second');

  Future<void> pumpApp(
    WidgetTester tester, {
    bool disableAnimations = false,
    TextDirection direction = TextDirection.ltr,
  }) => tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(
        size: const Size(400, 800),
        disableAnimations: disableAnimations,
      ),
      child: Directionality(
        textDirection: direction,
        child: PoiseScope(
          motion: PoiseMotion.calm,
          child: Navigator(
            key: navigatorKey,
            onGenerateRoute: (_) => PoiseRoute<void>(
              builder: (_) => const SizedBox.expand(key: first),
            ),
          ),
        ),
      ),
    ),
  );

  void pushSecond() => navigatorKey.currentState?.push(
    PoiseRoute<void>(
      builder: (_) => const ColoredBox(
        key: second,
        color: Color(0xFFFFFFFF),
        child: SizedBox.expand(),
      ),
    ),
  );

  double left(WidgetTester tester, Key key) =>
      tester.getTopLeft(find.byKey(key)).dx;

  testWidgets('slides the new screen in from the end edge', (tester) async {
    await pumpApp(tester);
    pushSecond();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    expect(left(tester, second), greaterThan(0));
    expect(left(tester, first), lessThan(0));

    await tester.pumpAndSettle();
    expect(left(tester, second), 0);
  });

  testWidgets('slides from the left in right-to-left languages', (
    tester,
  ) async {
    await pumpApp(tester, direction: TextDirection.rtl);
    pushSecond();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    expect(left(tester, second), lessThan(0));
    await tester.pumpAndSettle();
  });

  testWidgets('going back is quicker than arriving', (tester) async {
    await pumpApp(tester);
    final route = PoiseRoute<void>(builder: (_) => const SizedBox());
    navigatorKey.currentState?.push(route);
    await tester.pumpAndSettle();
    expect(route.reverseTransitionDuration, lessThan(route.transitionDuration));
  });

  testWidgets('cross-fades in place when motion is reduced', (tester) async {
    await pumpApp(tester, disableAnimations: true);
    pushSecond();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 30));
    expect(left(tester, second), 0);
    expect(left(tester, first), 0);
    await tester.pumpAndSettle();
  });

  final onIos = TargetPlatformVariant.only(TargetPlatform.iOS);

  group('on iOS', () {
    testWidgets('a swipe from the edge goes back', (tester) async {
      await pumpApp(tester);
      pushSecond();
      await tester.pumpAndSettle();

      await tester.timedDragFrom(
        const Offset(5, 400),
        const Offset(300, 0),
        const Duration(milliseconds: 300),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(second), findsNothing);
    }, variant: onIos);

    testWidgets(
      'the page follows the finger, then leaves without jumping back',
      (tester) async {
        await pumpApp(tester);
        pushSecond();
        await tester.pumpAndSettle();

        final finger = await tester.startGesture(const Offset(5, 400));
        for (var step = 1; step <= 20; step++) {
          await finger.moveBy(const Offset(25, 0));
          await tester.pump(const Duration(milliseconds: 16));
          expect(
            left(tester, second),
            closeTo(25.0 * step, 4),
            reason: 'the page should stay under the finger',
          );
        }

        var furthest = left(tester, second);
        await finger.up();
        for (var frame = 0; frame < 40; frame++) {
          await tester.pump(const Duration(milliseconds: 16));
          if (find.byKey(second).evaluate().isEmpty) break;
          final now = left(tester, second);
          expect(
            now,
            greaterThanOrEqualTo(furthest - 0.5),
            reason: 'after letting go it should keep leaving, not jump back',
          );
          furthest = now;
        }
        await tester.pumpAndSettle();
        expect(find.byKey(second), findsNothing);
      },
      variant: onIos,
    );

    testWidgets('a short swipe springs back and stays', (tester) async {
      await pumpApp(tester);
      pushSecond();
      await tester.pumpAndSettle();

      final finger = await tester.startGesture(const Offset(5, 400));
      for (var step = 0; step < 6; step++) {
        await finger.moveBy(const Offset(10, 0));
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(left(tester, second), greaterThan(0));

      await finger.up();
      await tester.pumpAndSettle();
      expect(left(tester, second), 0);
    }, variant: onIos);
  });
}
