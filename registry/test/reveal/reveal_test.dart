import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poise_registry/reveal/reveal.dart';

void main() {
  const child = SizedBox(key: ValueKey('child'), width: 100, height: 40);
  late int hiddenCalls;

  Future<void> pumpReveal(
    WidgetTester tester, {
    required bool visible,
    RevealFrom from = RevealFrom.bottom,
    bool revealOnFirstBuild = true,
    bool disableAnimations = false,
    TextDirection direction = TextDirection.ltr,
  }) => tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Directionality(
        textDirection: direction,
        child: Center(
          child: Reveal(
            visible: visible,
            from: from,
            revealOnFirstBuild: revealOnFirstBuild,
            onHidden: () => hiddenCalls++,
            child: child,
          ),
        ),
      ),
    ),
  );

  setUp(() => hiddenCalls = 0);

  Offset travel(WidgetTester tester) {
    final transform = tester.widget<Transform>(
      find.descendant(
        of: find.byType(Reveal),
        matching: find.byType(Transform),
      ),
    );
    final translation = transform.transform.getTranslation();
    return Offset(translation.x, translation.y);
  }

  double opacity(WidgetTester tester) => tester
      .widget<FadeTransition>(
        find.descendant(
          of: find.byType(Reveal),
          matching: find.byType(FadeTransition),
        ),
      )
      .opacity
      .value;

  testWidgets('arrives from below when it first appears', (tester) async {
    await pumpReveal(tester, visible: true);
    expect(travel(tester).dy, greaterThan(0));

    await tester.pumpAndSettle();
    expect(travel(tester).dy, closeTo(0, 0.01));
    expect(opacity(tester), 1);
  });

  testWidgets('can simply be there from the start', (tester) async {
    await pumpReveal(tester, visible: true, revealOnFirstBuild: false);
    expect(opacity(tester), 1);
    expect(travel(tester), Offset.zero);
  });

  testWidgets('leaves, then says it has gone', (tester) async {
    await pumpReveal(tester, visible: true, revealOnFirstBuild: false);
    await pumpReveal(tester, visible: false);
    await tester.pumpAndSettle();

    expect(opacity(tester), 0);
    expect(hiddenCalls, 1);
  });

  testWidgets('a hidden child cannot be tapped', (tester) async {
    await pumpReveal(tester, visible: false);
    final ignore = tester.widget<IgnorePointer>(
      find
          .ancestor(
            of: find.byKey(const ValueKey('child')),
            matching: find.byType(IgnorePointer),
          )
          .first,
    );
    expect(ignore.ignoring, isTrue);
  });

  testWidgets('turns around halfway without jumping', (tester) async {
    await pumpReveal(tester, visible: false);
    await pumpReveal(tester, visible: true);
    await tester.pump(const Duration(milliseconds: 60));
    final beforeTurning = travel(tester);

    await pumpReveal(tester, visible: false);
    await tester.pump(const Duration(milliseconds: 16));
    final justAfter = travel(tester);

    expect((justAfter - beforeTurning).distance, lessThan(2));
    expect(hiddenCalls, 0);

    await tester.pumpAndSettle();
    expect(hiddenCalls, 1);
  });

  testWidgets('fades in place when motion is reduced', (tester) async {
    await pumpReveal(tester, visible: true, disableAnimations: true);
    await tester.pump(const Duration(milliseconds: 50));
    expect(travel(tester), Offset.zero);
    expect(opacity(tester), greaterThan(0));
    await tester.pumpAndSettle();
  });

  testWidgets('start mirrors in right-to-left languages', (tester) async {
    await pumpReveal(tester, visible: true, from: RevealFrom.start);
    final leftToRight = travel(tester).dx;
    await tester.pumpAndSettle();

    await tester.pumpWidget(const SizedBox());
    await pumpReveal(
      tester,
      visible: true,
      from: RevealFrom.start,
      direction: TextDirection.rtl,
    );
    final rightToLeft = travel(tester).dx;

    expect(leftToRight, lessThan(0));
    expect(rightToLeft, greaterThan(0));
    await tester.pumpAndSettle();
  });
}
