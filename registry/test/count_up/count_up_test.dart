import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poise/poise.dart';
import 'package:poise_registry/count_up/count_up.dart';
import 'package:poise_registry/text_swap/text_swap.dart';

void main() {
  Future<void> pumpCount(
    WidgetTester tester,
    num value, {
    bool disableAnimations = false,
  }) => tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: PoiseScope(
          motion: PoiseMotion.calm,
          child: Center(child: CountUp(value: value)),
        ),
      ),
    ),
  );

  int shown(WidgetTester tester) =>
      int.parse(tester.widget<Text>(find.byType(Text)).data ?? '');

  testWidgets('counts through the numbers in between', (tester) async {
    await pumpCount(tester, 0);
    await pumpCount(tester, 100);
    await tester.pump(const Duration(milliseconds: 60));
    expect(shown(tester), inExclusiveRange(0, 100));

    await tester.pumpAndSettle();
    expect(shown(tester), 100);
  });

  testWidgets('carries on from where it is if the value changes again', (
    tester,
  ) async {
    await pumpCount(tester, 0);
    await pumpCount(tester, 100);
    await tester.pump(const Duration(milliseconds: 60));
    final midway = shown(tester);

    await pumpCount(tester, 50);
    await tester.pump();
    expect((shown(tester) - midway).abs(), lessThanOrEqualTo(5));

    await tester.pumpAndSettle();
    expect(shown(tester), 50);
  });

  testWidgets('screen readers hear only where it lands', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpCount(tester, 0);
    await pumpCount(tester, 100);
    await tester.pump(const Duration(milliseconds: 60));
    expect(
      tester.getSemantics(find.byType(CountUp)),
      matchesSemantics(label: '100', isLiveRegion: true),
    );
    await tester.pumpAndSettle();
    semantics.dispose();
  });

  testWidgets('digits are drawn at equal widths', (tester) async {
    await pumpCount(tester, 8);
    final style = tester.widget<Text>(find.byType(Text)).style;
    expect(style?.fontFeatures, contains(const FontFeature.tabularFigures()));
  });

  testWidgets('fades the new number in when motion is reduced', (tester) async {
    await pumpCount(tester, 0, disableAnimations: true);
    await pumpCount(tester, 100, disableAnimations: true);
    expect(find.byType(TextSwap), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 60));
    expect(find.text('50'), findsNothing);
    await tester.pumpAndSettle();
    expect(find.text('100'), findsOneWidget);
  });
}
