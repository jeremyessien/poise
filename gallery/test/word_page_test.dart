import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/src/lane_curve.dart';
import 'package:gallery/src/settings.dart';
import 'package:gallery/src/theme.dart';
import 'package:gallery/src/word_page.dart';
import 'package:gallery/src/words.dart';

void main() {
  late GallerySettings settings;

  setUp(() => settings = GallerySettings());
  tearDown(() => settings.dispose());

  Future<void> pumpPage(WidgetTester tester, MotionWord word) async {
    tester.view.physicalSize = const Size(1206, 2622);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: galleryTheme(),
        builder: (context, child) => GallerySettingsScope(
          settings: settings,
          child: child ?? const SizedBox.shrink(),
        ),
        home: WordPage(word: word),
      ),
    );
    await tester.pumpAndSettle();
  }

  Map<Personality, Offset> objectPositions(WidgetTester tester) => {
    for (final personality in Personality.values)
      personality: tester.getTopLeft(
        find.byKey(ValueKey('lane-object-${personality.label}')),
      ),
  };

  testWidgets('shows one lane per personality', (tester) async {
    await pumpPage(tester, MotionWord.enter);
    for (final personality in Personality.values) {
      expect(find.text(personality.label), findsOneWidget);
    }
  });

  const movingWords = [
    MotionWord.feedback,
    MotionWord.enter,
    MotionWord.exit,
    MotionWord.transition,
    MotionWord.attention,
    MotionWord.celebrate,
    MotionWord.follow,
    MotionWord.stagger,
  ];

  for (final word in movingWords) {
    testWidgets('Play moves all three ${word.name} lanes at once', (
      tester,
    ) async {
      await pumpPage(tester, word);
      final before = objectPositions(tester);

      await tester.tap(find.text('Play'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 40));
      final during = objectPositions(tester);

      for (final personality in Personality.values) {
        expect(
          during[personality],
          isNot(before[personality]),
          reason: personality.label,
        );
      }
      await tester.pumpAndSettle();
    });
  }

  testWidgets('with reduce motion on, nothing travels', (tester) async {
    settings.reduceMotion = true;
    await pumpPage(tester, MotionWord.enter);
    final before = objectPositions(tester);

    await tester.tap(find.text('Play'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));

    expect(objectPositions(tester), before);
    await tester.pumpAndSettle();
  });

  testWidgets('every word plays without errors', (tester) async {
    for (final word in MotionWord.values) {
      await pumpPage(tester, word);
      await tester.tap(find.text('Play'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull, reason: word.name);
      await tester.tap(find.text('Play'));
      await tester.pumpAndSettle();
    }
  });

  testWidgets('loop holds still when motion is reduced', (tester) async {
    settings.reduceMotion = true;
    await pumpPage(tester, MotionWord.loop);
    final before = objectPositions(tester);
    double opacityOf(Personality personality) => tester
        .widget<FadeTransition>(
          find
              .ancestor(
                of: find.byKey(ValueKey('lane-object-${personality.label}')),
                matching: find.byType(FadeTransition),
              )
              .first,
        )
        .opacity
        .value;

    await tester.tap(find.text('Play'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(objectPositions(tester), before);
    for (final personality in Personality.values) {
      expect(opacityOf(personality), 1, reason: personality.label);
    }
  });

  testWidgets('a dragged object springs back to rest', (tester) async {
    await pumpPage(tester, MotionWord.follow);
    final object = find.byKey(const ValueKey('lane-object-calm'));
    final rest = tester.getTopLeft(object);

    await tester.drag(object, const Offset(0, 60));
    await tester.pump();
    expect(tester.getTopLeft(object), isNot(rest));

    await tester.pumpAndSettle();
    expect(tester.getTopLeft(object).dy, closeTo(rest.dy, 0.5));
  });

  testWidgets('Show curve draws a curve in each lane', (tester) async {
    settings.showCurve = true;
    await pumpPage(tester, MotionWord.enter);
    for (final personality in Personality.values) {
      expect(
        find.descendant(
          of: find.byType(LaneCurve),
          matching: find.byType(CustomPaint),
        ),
        findsNWidgets(Personality.values.length),
        reason: personality.label,
      );
    }
  });
}
