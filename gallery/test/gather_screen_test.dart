import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/src/gather/event_card.dart';
import 'package:gallery/src/gather/events.dart';
import 'package:gallery/src/gather/gather_screen.dart';
import 'package:poise/poise.dart';
import 'package:poise_registry/reveal/reveal.dart';

void main() {
  Future<void> pumpGather(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1206, 3600);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: GatherScreen()));
    await tester.pumpAndSettle();
  }

  PoiseMotion motionOf(WidgetTester tester) =>
      tester.widget<PoiseScope>(find.byType(PoiseScope).first).motion;

  testWidgets('shows every event', (tester) async {
    await pumpGather(tester);
    expect(find.byType(EventCard), findsNWidgets(sampleEvents.length));
  });

  testWidgets('the dial changes the whole screen\'s personality', (
    tester,
  ) async {
    await pumpGather(tester);
    expect(motionOf(tester), same(PoiseMotion.calm));

    await tester.tap(find.text('playful'));
    await tester.pumpAndSettle();
    expect(motionOf(tester), same(PoiseMotion.playful));
  });

  testWidgets('saving an event shows a toast that goes away', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpGather(tester);
    await tester.tap(find.bySemanticsLabel('Save to plans').first);
    await tester.pump();

    Reveal toast() => tester
        .widgetList<Reveal>(find.byType(Reveal))
        .singleWhere((reveal) => !reveal.revealOnFirstBuild);
    expect(toast().visible, isTrue);
    expect(find.text('Saved to your plans'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(toast().visible, isFalse);
    semantics.dispose();
  });
}
