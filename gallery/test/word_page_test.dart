import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/src/recipe_curves.dart';
import 'package:gallery/src/recipes.dart';
import 'package:gallery/src/theme.dart';
import 'package:gallery/src/word_page.dart';
import 'package:gallery/src/words.dart';

void main() {
  Future<void> pumpWord(WidgetTester tester, MotionWord word) async {
    tester.view.physicalSize = const Size(1206, 4000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: galleryTheme,
        home: WordPage(word: word),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final word in MotionWord.values) {
    testWidgets('${word.name} shows its curves and its recipes', (
      tester,
    ) async {
      await pumpWord(tester, word);
      expect(find.byType(RecipeCurves), findsOneWidget);
      final recipes = GalleryRecipe.values.where((r) => r.words.contains(word));
      if (recipes.isEmpty) {
        expect(
          find.text('None yet. Its recipe is on the way.'),
          findsOneWidget,
        );
      }
      for (final recipe in recipes) {
        expect(find.text(recipe.title), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('choosing a personality highlights its curve', (tester) async {
    await pumpWord(tester, MotionWord.enter);
    await tester.tap(find.text('playful'));
    await tester.pump();
    expect(
      tester.widget<RecipeCurves>(find.byType(RecipeCurves)).selected,
      Personality.playful,
    );
  });
}
