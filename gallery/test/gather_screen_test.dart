import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/src/gather/event_card.dart';
import 'package:gallery/src/gather/event_details.dart';
import 'package:gallery/src/gather/events.dart';
import 'package:gallery/src/gather/gather_screen.dart';
import 'package:gallery/src/settings.dart';
import 'package:gallery/src/touches.dart';
import 'package:poise/poise.dart';
import 'package:poise_registry/reveal/reveal.dart';
import 'package:poise_registry/success_check/success_check.dart';
import 'package:poise_registry/staggered_column/staggered_column.dart';

void main() {
  late GallerySettings settings;

  setUp(() => settings = GallerySettings());
  tearDown(() => settings.dispose());

  Future<void> pumpGather(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1206, 3600);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => GallerySettingsScope(
          settings: settings,
          child: ShowTouches(child: child ?? const SizedBox.shrink()),
        ),
        home: const GatherScreen(),
      ),
    );
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

  testWidgets('turning the dial replays the cards arriving', (tester) async {
    await pumpGather(tester);
    int arrived() => tester
        .widgetList<Reveal>(
          find.descendant(
            of: find.byType(StaggeredColumn),
            matching: find.byType(Reveal),
          ),
        )
        .where((reveal) => reveal.visible)
        .length;
    expect(arrived(), sampleEvents.length);

    await tester.tap(find.text('playful'));
    await tester.pump();
    expect(arrived(), 1);

    await tester.pumpAndSettle();
    expect(arrived(), sampleEvents.length);
  });

  testWidgets('saving an event shows a toast that goes away', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpGather(tester);
    await tester.tap(find.bySemanticsLabel('Save to plans').first);
    await tester.pump();

    Reveal toast() => tester.widget<Reveal>(
      find
          .ancestor(
            of: find.text('Saved to your plans'),
            matching: find.byType(Reveal),
          )
          .first,
    );
    expect(toast().visible, isTrue);
    expect(find.text('Saved to your plans'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(toast().visible, isFalse);
    semantics.dispose();
  });

  testWidgets('in slow motion the toast stays as long as its springs do', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    settings.slowMotion = true;
    await pumpGather(tester);
    await tester.tap(find.bySemanticsLabel('Save to plans').first);
    await tester.pump();

    Reveal toast() => tester.widget<Reveal>(
      find
          .ancestor(
            of: find.text('Saved to your plans'),
            matching: find.byType(Reveal),
          )
          .first,
    );
    await tester.pump(const Duration(seconds: 2));
    expect(toast().visible, isTrue);

    await tester.pump(const Duration(seconds: 8));
    expect(toast().visible, isFalse);
    await tester.pumpAndSettle();
    settings.slowMotion = false;
    semantics.dispose();
  });

  testWidgets('show touches draws a circle under a finger', (tester) async {
    settings.showTouches = true;
    await pumpGather(tester);
    final circles = find.descendant(
      of: find.byType(ShowTouches),
      matching: find.byType(AnimatedOpacity),
    );
    expect(circles, findsNothing);

    final finger = await tester.startGesture(const Offset(200, 300));
    await tester.pump();
    expect(circles, findsOneWidget);

    await finger.up();
    await tester.pumpAndSettle();
    expect(circles, findsNothing);
  });

  testWidgets('tapping a card opens its details, pulling them down closes', (
    tester,
  ) async {
    await pumpGather(tester);
    final details = find.text(EventDetails.heading);
    expect(details, findsNothing);

    await tester.tap(find.byType(EventCard).first);
    await tester.pumpAndSettle();
    expect(details, findsOneWidget);
    expect(find.text(sampleEvents.first.title), findsNWidgets(2));

    await tester.timedDrag(
      details,
      const Offset(0, 400),
      const Duration(milliseconds: 600),
    );
    await tester.pumpAndSettle();
    expect(details, findsNothing);
  });

  testWidgets('joining an event swaps the button through each step', (
    tester,
  ) async {
    await pumpGather(tester);
    await tester.tap(find.byType(EventCard).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text(JoinState.open.label));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text(JoinState.joining.label), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text(JoinState.joined.label), findsOneWidget);
    expect(find.text(JoinState.joining.label), findsNothing);
    final spots = sampleEvents.first.spotsLeft;
    expect(find.text(spotsLeftLabel(spots - 1)), findsNWidgets(2));
    expect(find.text(spotsLeftLabel(spots)), findsNothing);
    expect(find.byType(SuccessCheck), findsOneWidget);
  });
}
