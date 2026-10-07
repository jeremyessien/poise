import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

  for (final word in [MotionWord.enter, MotionWord.exit]) {
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

  testWidgets('words without a demo yet say so', (tester) async {
    await pumpPage(tester, MotionWord.celebrate);
    expect(find.text('Demo coming soon'), findsNWidgets(3));
  });
}
