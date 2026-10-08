import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/src/code_block.dart';
import 'package:gallery/src/gather/personality_dial.dart';
import 'package:gallery/src/recipe_curves.dart';
import 'package:gallery/src/recipe_page.dart';
import 'package:gallery/src/recipes.dart';
import 'package:gallery/src/settings.dart';
import 'package:gallery/src/theme.dart';
import 'package:poise/poise.dart';

void main() {
  late GallerySettings settings;

  setUp(() => settings = GallerySettings());
  tearDown(() => settings.dispose());

  Future<void> pumpPage(WidgetTester tester, GalleryRecipe recipe) async {
    tester.view.physicalSize = const Size(1206, 6000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: galleryTheme(),
        builder: (context, child) => GallerySettingsScope(
          settings: settings,
          child: child ?? const SizedBox.shrink(),
        ),
        home: RecipePage(recipe: recipe),
      ),
    );
    await tester.pumpAndSettle();
  }

  test('every recipe points at a real registry folder', () {
    for (final recipe in GalleryRecipe.values) {
      expect(
        Directory('../registry/lib/${recipe.folder}').existsSync(),
        isTrue,
        reason: recipe.folder,
      );
    }
  });

  for (final recipe in GalleryRecipe.values) {
    testWidgets('${recipe.title} shows its stage, curves and code', (
      tester,
    ) async {
      await pumpPage(tester, recipe);
      expect(find.byType(PersonalityDial), findsOneWidget);
      expect(find.byType(RecipeCurves), findsNWidgets(recipe.words.length));
      expect(find.text(recipe.code), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('the dial changes the stage\'s personality', (tester) async {
    await pumpPage(tester, GalleryRecipe.reveal);
    PoiseMotion stageMotion() =>
        tester.widget<PoiseScope>(find.byType(PoiseScope).first).motion;
    expect(stageMotion(), same(PoiseMotion.calm));

    await tester.tap(find.text('crisp'));
    await tester.pumpAndSettle();
    expect(stageMotion(), same(PoiseMotion.crisp));
  });

  testWidgets('Copy puts the code on the clipboard', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map<Object?, Object?>)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    await pumpPage(tester, GalleryRecipe.pressable);
    await tester.tap(
      find.descendant(of: find.byType(CodeBlock), matching: find.text('Copy')),
    );
    await tester.pump();

    expect(copied, GalleryRecipe.pressable.code);
    expect(find.text('Copied'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
  });
}
