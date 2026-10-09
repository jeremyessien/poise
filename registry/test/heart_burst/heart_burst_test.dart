import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poise/poise.dart';
import 'package:poise_registry/heart_burst/heart_burst.dart';

void main() {
  Future<void> pumpHeart(
    WidgetTester tester, {
    required bool liked,
    bool disableAnimations = false,
  }) => tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: PoiseScope(
          motion: PoiseMotion.playful,
          child: Center(
            child: HeartBurst(
              liked: liked,
              child: const SizedBox.square(dimension: 24),
            ),
          ),
        ),
      ),
    ),
  );

  double scale(WidgetTester tester) => tester
      .widget<Transform>(
        find.descendant(
          of: find.byType(HeartBurst),
          matching: find.byType(Transform),
        ),
      )
      .transform
      .entry(0, 0);

  Future<double> smallestScaleWhile(WidgetTester tester) async {
    var smallest = scale(tester);
    for (var frame = 0; frame < 40; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
      if (scale(tester) < smallest) smallest = scale(tester);
    }
    return smallest;
  }

  testWidgets('pops from small when liked, then rests at full size', (
    tester,
  ) async {
    await pumpHeart(tester, liked: false);
    await pumpHeart(tester, liked: true);
    expect(await smallestScaleWhile(tester), lessThan(0.7));
    await tester.pumpAndSettle();
    expect(scale(tester), closeTo(1, 0.001));
  });

  testWidgets('only presses a little when the like is taken back', (
    tester,
  ) async {
    await pumpHeart(tester, liked: true);
    await pumpHeart(tester, liked: false);
    final smallest = await smallestScaleWhile(tester);
    expect(smallest, lessThan(1));
    expect(smallest, greaterThan(0.8));
    await tester.pumpAndSettle();
    expect(scale(tester), closeTo(1, 0.001));
  });

  testWidgets('stays still when motion is reduced', (tester) async {
    await pumpHeart(tester, liked: false, disableAnimations: true);
    await pumpHeart(tester, liked: true, disableAnimations: true);
    expect(tester.hasRunningAnimations, isFalse);
    expect(scale(tester), 1);
  });
}
