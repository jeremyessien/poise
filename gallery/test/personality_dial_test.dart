import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/src/gather/personality_dial.dart';
import 'package:gallery/src/theme.dart';

void main() {
  late Personality chosen;

  Future<void> pumpDial(WidgetTester tester, Personality selected) =>
      tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: PersonalityDial(
              selected: selected,
              onChanged: (personality) => chosen = personality,
            ),
          ),
        ),
      );

  testWidgets('offers every personality', (tester) async {
    await pumpDial(tester, Personality.calm);
    for (final personality in Personality.values) {
      expect(find.text(personality.label), findsOneWidget);
    }
  });

  testWidgets('reports the personality that was tapped', (tester) async {
    chosen = Personality.calm;
    await pumpDial(tester, Personality.calm);
    await tester.tap(find.text('playful'));
    expect(chosen, Personality.playful);
  });

  testWidgets('slides its highlight to the new choice', (tester) async {
    await pumpDial(tester, Personality.calm);
    final start = tester.getTopLeft(
      find.byKey(const ValueKey('dial-highlight')),
    );

    await pumpDial(tester, Personality.playful);
    await tester.pumpAndSettle();
    final end = tester.getTopLeft(find.byKey(const ValueKey('dial-highlight')));

    expect(end.dx, greaterThan(start.dx));
  });
}
