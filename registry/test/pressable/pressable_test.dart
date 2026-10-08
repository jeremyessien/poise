import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poise_registry/pressable/pressable.dart';

void main() {
  late int taps;

  Future<void> pumpPressable(
    WidgetTester tester, {
    bool disableAnimations = false,
  }) {
    taps = 0;
    return tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: Pressable(
              semanticLabel: 'Open',
              onTap: () => taps++,
              child: const SizedBox(width: 200, height: 80),
            ),
          ),
        ),
      ),
    );
  }

  double scaleNow(WidgetTester tester) {
    final transform = tester.widget<Transform>(
      find.descendant(
        of: find.byType(Pressable),
        matching: find.byType(Transform),
      ),
    );
    return transform.transform.entry(0, 0);
  }

  testWidgets('shrinks a little while held and taps on release', (
    tester,
  ) async {
    await pumpPressable(tester);
    final press = await tester.startGesture(
      tester.getCenter(find.byType(Pressable)),
    );
    await tester.pump(kPressTimeout);
    await tester.pumpAndSettle();
    expect(scaleNow(tester), lessThan(1));
    expect(taps, 0);

    await press.up();
    await tester.pumpAndSettle();
    expect(scaleNow(tester), closeTo(1, 0.001));
    expect(taps, 1);
  });

  testWidgets('dims instead of shrinking when motion is reduced', (
    tester,
  ) async {
    await pumpPressable(tester, disableAnimations: true);
    final press = await tester.startGesture(
      tester.getCenter(find.byType(Pressable)),
    );
    await tester.pump(kPressTimeout);
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(Pressable),
        matching: find.byType(Transform),
      ),
      findsNothing,
    );
    final fade = tester.widget<FadeTransition>(
      find.descendant(
        of: find.byType(Pressable),
        matching: find.byType(FadeTransition),
      ),
    );
    expect(fade.opacity.value, lessThan(1));
    await press.up();
  });

  testWidgets('buttons inside it stay reachable for screen readers', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: Pressable(
            semanticLabel: 'Open event',
            onTap: () {},
            child: Semantics(
              button: true,
              label: 'Save to plans',
              onTap: () {},
              child: const SizedBox(width: 40, height: 40),
            ),
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel('Open event'), findsOneWidget);
    expect(find.bySemanticsLabel('Save to plans'), findsOneWidget);
    semantics.dispose();
  });
}
