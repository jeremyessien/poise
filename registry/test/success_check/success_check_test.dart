import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poise/poise.dart';
import 'package:poise_registry/success_check/success_check.dart';

void main() {
  Future<void> pumpCheck(
    WidgetTester tester, {
    required bool shown,
    bool disableAnimations = false,
  }) => tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: PoiseScope(
          motion: PoiseMotion.playful,
          child: Center(child: SuccessCheck(shown: shown)),
        ),
      ),
    ),
  );

  double opacity(WidgetTester tester) => tester
      .widget<FadeTransition>(
        find.descendant(
          of: find.byType(SuccessCheck),
          matching: find.byType(FadeTransition),
        ),
      )
      .opacity
      .value;

  double scale(WidgetTester tester) => tester
      .widget<Transform>(
        find.descendant(
          of: find.byType(SuccessCheck),
          matching: find.byType(Transform),
        ),
      )
      .transform
      .entry(0, 0);

  testWidgets('stays out of sight until shown', (tester) async {
    await pumpCheck(tester, shown: false);
    await tester.pumpAndSettle();
    expect(opacity(tester), 0);
  });

  testWidgets('pops in and settles at full size', (tester) async {
    await pumpCheck(tester, shown: false);
    await pumpCheck(tester, shown: true);
    await tester.pump(const Duration(milliseconds: 40));
    expect(scale(tester), lessThan(1));

    await tester.pumpAndSettle();
    expect(scale(tester), closeTo(1, 0.001));
    expect(opacity(tester), 1);
  });

  testWidgets('fades away when no longer shown', (tester) async {
    await pumpCheck(tester, shown: true);
    await tester.pumpAndSettle();
    await pumpCheck(tester, shown: false);
    await tester.pumpAndSettle();
    expect(opacity(tester), 0);
  });

  testWidgets('arrives drawn and full size when motion is reduced', (
    tester,
  ) async {
    await pumpCheck(tester, shown: false, disableAnimations: true);
    await pumpCheck(tester, shown: true, disableAnimations: true);
    await tester.pump(const Duration(milliseconds: 40));
    expect(scale(tester), 1);
    expect(opacity(tester), greaterThan(0));
    await tester.pumpAndSettle();
  });

  testWidgets('screen readers hear it only once shown', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpCheck(tester, shown: false);
    expect(find.bySemanticsLabel('Done'), findsNothing);

    await pumpCheck(tester, shown: true);
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(find.byType(SuccessCheck)),
      matchesSemantics(label: 'Done', isLiveRegion: true),
    );
    semantics.dispose();
  });
}
