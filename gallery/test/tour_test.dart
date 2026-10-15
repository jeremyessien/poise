import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/src/gather/event_details.dart';
import 'package:gallery/src/gather/event_card.dart';
import 'package:gallery/src/touches.dart';
import 'package:gallery/src/app.dart';
import 'package:gallery/src/gather/gather_screen.dart';
import 'package:gallery/src/menu_page.dart';
import 'package:gallery/src/recipe_page.dart';
import 'package:gallery/src/settings.dart';
import 'package:gallery/src/theme.dart';
import 'package:gallery/src/tour.dart';
import 'package:gallery/src/tour_overlay.dart';
import 'package:gallery/src/word_page.dart';
import 'package:gallery/src/words_page.dart';
import 'package:poise/poise.dart';

void main() {
  late GallerySettings settings;

  setUp(() => settings = GallerySettings());
  tearDown(() => settings.dispose());

  Future<GalleryTour> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1206, 2622);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(GalleryApp(settings: settings));
    await tester.pumpAndSettle();
    return GalleryTourScope.of(tester.element(find.byType(GatherScreen)));
  }

  PoiseMotion gatherMotion(WidgetTester tester) => tester
      .widget<PoiseScope>(
        find.descendant(
          of: find.byType(GatherScreen),
          matching: find.byType(PoiseScope),
        ),
      )
      .motion;

  testWidgets('the tour walks the whole gallery and comes home', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final tour = await pumpApp(tester);
    final pages = <Type>{};
    final motions = <PoiseMotion>{};
    final captions = <String>{};
    var sawReduceMotion = false;
    var sawSlowMotion = false;

    unawaited(tour.play());
    for (var frame = 0; frame < 9000 && tour.isRunning; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
      for (final page in [MenuPage, RecipePage, WordsPage, WordPage]) {
        if (find.byType(page).evaluate().isNotEmpty) pages.add(page);
      }
      if (find.byType(GatherScreen).evaluate().isNotEmpty) {
        motions.add(gatherMotion(tester));
      }
      if (tour.showsCaption) captions.add(tour.caption.title);
      sawReduceMotion |= settings.reduceMotion;
      sawSlowMotion |= settings.slowMotion;
    }
    await tester.pumpAndSettle();

    expect(tour.isRunning, isFalse, reason: 'the tour should finish itself');
    expect(pages, containsAll([MenuPage, RecipePage, WordsPage, WordPage]));
    expect(motions, containsAll([PoiseMotion.crisp, PoiseMotion.playful]));
    expect(
      captions,
      containsAll([
        for (final word in MotionWord.values) word.name,
        for (final personality in Personality.values) personality.label,
        'The menu',
        'How it moves',
        'Reduce motion',
        'Slow motion',
      ]),
    );
    expect(sawReduceMotion, isTrue);
    expect(sawSlowMotion, isTrue);

    expect(find.byType(GatherScreen), findsOneWidget);
    expect(find.byType(MenuPage), findsNothing);
    expect(gatherMotion(tester), same(PoiseMotion.calm));
    expect(find.bySemanticsLabel('Remove from plans'), findsOneWidget);
    expect(settings.reduceMotion, isFalse);
    expect(settings.slowMotion, isFalse);
    expect(settings.showTouches, isFalse);
    expect(timeDilation, 1);
    semantics.dispose();
  });

  testWidgets('a real touch stops the tour', (tester) async {
    final tour = await pumpApp(tester);
    unawaited(tour.play());
    await tester.pump(const Duration(milliseconds: 500));
    expect(tour.isRunning, isTrue);
    expect(tour.showsCaption, isTrue);

    await tester.tapAt(const Offset(200, 600));
    await tester.pump();
    expect(tour.isRunning, isFalse);
    expect(tour.showsCaption, isFalse);
    await tester.pumpAndSettle();
  });

  testWidgets('stopping mid-press lifts the tour\'s finger', (tester) async {
    final tour = await pumpApp(tester);
    final pressing = find.descendant(
      of: find.byType(ShowTouches),
      matching: find.byWidgetPredicate(
        (widget) => widget is AnimatedOpacity && widget.opacity == 1,
      ),
    );
    unawaited(tour.play());
    for (var frame = 0; frame < 600 && pressing.evaluate().isEmpty; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(pressing, findsOneWidget, reason: 'the tour should be pressing');

    await tester.tapAt(const Offset(390, 860));
    await tester.pumpAndSettle();
    expect(tour.isRunning, isFalse);
    expect(pressing, findsNothing, reason: 'no touch should be left down');

    await tester.tap(find.byType(EventCard).first);
    await tester.pumpAndSettle();
    expect(
      find.text(EventDetails.heading),
      findsOneWidget,
      reason: 'real taps should still work',
    );
  });
}
