import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poise/poise.dart';
import 'package:poise_registry/shimmer/shimmer.dart';

void main() {
  const placeholder = SizedBox(key: ValueKey('placeholder'), height: 40);

  Future<void> pumpShimmer(
    WidgetTester tester, {
    PoiseMotion motion = PoiseMotion.calm,
    bool disableAnimations = false,
    bool shown = true,
  }) => tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: PoiseScope(
          motion: motion,
          child: shown ? const Shimmer(child: placeholder) : const SizedBox(),
        ),
      ),
    ),
  );

  testWidgets('shows the placeholders it wraps', (tester) async {
    await pumpShimmer(tester);
    expect(find.byKey(const ValueKey('placeholder')), findsOneWidget);
  });

  testWidgets('breathes when loop is a fade', (tester) async {
    await pumpShimmer(tester);
    double opacity() => tester
        .widget<FadeTransition>(find.byType(FadeTransition))
        .opacity
        .value;
    final readings = <double>{};
    for (var frame = 0; frame < 60; frame++) {
      await tester.pump(const Duration(milliseconds: 50));
      readings.add(double.parse(opacity().toStringAsFixed(2)));
    }
    expect(readings.reduce((a, b) => a < b ? a : b), lessThan(0.6));
    expect(readings.reduce((a, b) => a > b ? a : b), greaterThan(0.9));
  });

  testWidgets('sweeps a highlight when loop is a spring', (tester) async {
    await pumpShimmer(tester, motion: PoiseMotion.playful);
    expect(find.byType(ShaderMask), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.hasRunningAnimations, isTrue);
  });

  testWidgets('holds still when motion is reduced', (tester) async {
    await pumpShimmer(tester, disableAnimations: true);
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.hasRunningAnimations, isFalse);
    expect(find.byType(FadeTransition), findsNothing);
    expect(find.byType(ShaderMask), findsNothing);
  });

  testWidgets('stops once it is removed', (tester) async {
    await pumpShimmer(tester);
    await tester.pump(const Duration(milliseconds: 100));
    await pumpShimmer(tester, shown: false);
    expect(tester.hasRunningAnimations, isFalse);
  });
}
