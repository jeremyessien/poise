import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poise/poise.dart';
import 'package:poise_registry/text_swap/text_swap.dart';

void main() {
  Future<void> pumpSwap(
    WidgetTester tester,
    String text, {
    PoiseMotion motion = PoiseMotion.playful,
    bool disableAnimations = false,
  }) => tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: PoiseScope(
          motion: motion,
          child: Center(child: TextSwap(text)),
        ),
      ),
    ),
  );

  testWidgets('swaps to the new text and lets the old one go', (tester) async {
    await pumpSwap(tester, 'Join');
    await pumpSwap(tester, "You're in");
    await tester.pump(const Duration(milliseconds: 30));
    expect(find.text('Join'), findsOneWidget);
    expect(find.text("You're in"), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('Join'), findsNothing);
    expect(find.text("You're in"), findsOneWidget);
  });

  testWidgets('rolls the new text in when change is a spring', (tester) async {
    await pumpSwap(tester, 'Join');
    await pumpSwap(tester, 'Joining…');
    await tester.pumpAndSettle();
    final resting = tester.getTopLeft(find.text('Joining…')).dy;

    await pumpSwap(tester, "You're in");
    await tester.pump(const Duration(milliseconds: 30));
    expect(tester.getTopLeft(find.text("You're in")).dy, greaterThan(resting));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text("You're in")).dy, closeTo(resting, 0.5));
  });

  for (final (name, motion, disableAnimations) in [
    ('calm', PoiseMotion.calm, false),
    ('reduce motion', PoiseMotion.playful, true),
  ]) {
    testWidgets('cross-fades in place with $name', (tester) async {
      await pumpSwap(
        tester,
        'Join',
        motion: motion,
        disableAnimations: disableAnimations,
      );
      final resting = tester.getTopLeft(find.text('Join')).dy;
      await pumpSwap(
        tester,
        "You're in",
        motion: motion,
        disableAnimations: disableAnimations,
      );
      await tester.pump(const Duration(milliseconds: 30));
      expect(tester.getTopLeft(find.text("You're in")).dy, resting);
      await tester.pumpAndSettle();
    });
  }

  testWidgets('screen readers hear the new text, not the old', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpSwap(tester, 'Joining…');
    await pumpSwap(tester, "You're in");
    await tester.pump(const Duration(milliseconds: 30));

    expect(find.bySemanticsLabel("You're in"), findsOneWidget);
    expect(find.bySemanticsLabel('Joining…'), findsNothing);
    expect(
      tester.getSemantics(find.bySemanticsLabel("You're in")),
      matchesSemantics(label: "You're in", isLiveRegion: true),
    );
    await tester.pumpAndSettle();
    semantics.dispose();
  });

  testWidgets('the same text does not animate', (tester) async {
    await pumpSwap(tester, 'Join');
    await pumpSwap(tester, 'Join');
    expect(tester.hasRunningAnimations, isFalse);
  });
}
