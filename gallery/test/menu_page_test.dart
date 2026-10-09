import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/src/app.dart';
import 'package:gallery/src/gather/gather_screen.dart';
import 'package:gallery/src/menu_page.dart';
import 'package:gallery/src/recipe_page.dart';
import 'package:gallery/src/recipes.dart';
import 'package:gallery/src/settings.dart';
import 'package:gallery/src/tour_overlay.dart';
import 'package:gallery/src/words_page.dart';

void main() {
  late GallerySettings settings;

  setUp(() => settings = GallerySettings());
  tearDown(() => settings.dispose());

  Future<void> openMenu(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1206, 4000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(GalleryApp(settings: settings));
    await tester.pumpAndSettle();
    await tester.tap(find.text('poise'));
    await tester.pumpAndSettle();
  }

  testWidgets('the poise mark opens the menu with every recipe', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await openMenu(tester);
    for (final recipe in GalleryRecipe.values) {
      expect(find.text(recipe.title), findsOneWidget);
    }
    semantics.dispose();
  });

  testWidgets('a recipe row opens its page', (tester) async {
    final semantics = tester.ensureSemantics();
    await openMenu(tester);
    await tester.tap(find.text(GalleryRecipe.reveal.title));
    await tester.pumpAndSettle();
    expect(
      tester.widget<RecipePage>(find.byType(RecipePage)).recipe,
      GalleryRecipe.reveal,
    );
    semantics.dispose();
  });

  testWidgets('the words row opens the list of words', (tester) async {
    final semantics = tester.ensureSemantics();
    await openMenu(tester);
    await tester.tap(find.text('Every word poise uses'));
    await tester.pumpAndSettle();
    expect(find.byType(WordsPage), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('tapping a switch row changes its setting', (tester) async {
    final semantics = tester.ensureSemantics();
    await openMenu(tester);
    await tester.tap(find.text('Reduce motion'));
    await tester.pumpAndSettle();
    expect(settings.reduceMotion, isTrue);

    await tester.tap(find.text('Show touches'));
    await tester.pumpAndSettle();
    expect(settings.showTouches, isTrue);

    await tester.tap(find.text('Slow motion'));
    await tester.pump();
    expect(settings.slowMotion, isTrue);
    settings.slowMotion = false;
    semantics.dispose();
  });

  testWidgets('the tour row goes home and starts the tour', (tester) async {
    final semantics = tester.ensureSemantics();
    await openMenu(tester);
    final tour = GalleryTourScope.of(tester.element(find.byType(MenuPage)));
    await tester.scrollUntilVisible(
      find.text('Play the tour'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Play the tour'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(tour.isRunning, isTrue);
    expect(find.byType(MenuPage), findsNothing);
    expect(find.byType(GatherScreen), findsOneWidget);
    expect(settings.showTouches, isTrue);

    tour.stop();
    await tester.pumpAndSettle();
    expect(tour.isRunning, isFalse);
    expect(settings.showTouches, isFalse);
    semantics.dispose();
  });
}
