import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/src/app.dart';
import 'package:gallery/src/gather/gather_screen.dart';
import 'package:gallery/src/settings.dart';
import 'package:gallery/src/word_page.dart';
import 'package:gallery/src/words.dart';

void main() {
  late GallerySettings settings;

  setUp(() => settings = GallerySettings());
  tearDown(() => settings.dispose());

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(GalleryApp(settings: settings));
    await tester.pumpAndSettle();
  }

  NavigatorState navigator(WidgetTester tester) =>
      tester.state<NavigatorState>(find.byType(Navigator));

  testWidgets('the poise page lists every word', (tester) async {
    tester.view.physicalSize = const Size(1200, 9000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await pumpApp(tester);
    navigator(tester).pushNamed('/words');
    await tester.pumpAndSettle();
    for (final word in MotionWord.values) {
      expect(find.text(word.name), findsOneWidget, reason: word.name);
      expect(find.text(word.description), findsOneWidget, reason: word.name);
    }
  });

  testWidgets('tapping a word opens its page', (tester) async {
    await pumpApp(tester);
    navigator(tester).pushNamed('/words');
    await tester.pumpAndSettle();
    await tester.tap(find.text(MotionWord.enter.description));
    await tester.pumpAndSettle();
    expect(find.byType(WordPage), findsOneWidget);
    expect(find.text('Recipes that use it'), findsOneWidget);
  });

  testWidgets('every word opens from its address', (tester) async {
    await pumpApp(tester);
    for (final word in MotionWord.values) {
      navigator(tester).pushNamed(word.path);
      await tester.pumpAndSettle();
      expect(
        tester.widget<WordPage>(find.byType(WordPage)).word,
        word,
        reason: word.path,
      );
      navigator(tester).pop();
      await tester.pumpAndSettle();
    }
  });

  testWidgets('the app opens on Gather', (tester) async {
    await pumpApp(tester);
    expect(find.byType(GatherScreen), findsOneWidget);
  });

  testWidgets('an unknown address lands on Gather', (tester) async {
    await pumpApp(tester);
    navigator(tester).pushNamed('/nowhere');
    await tester.pumpAndSettle();
    expect(find.byType(WordPage), findsNothing);
    expect(find.byType(GatherScreen), findsWidgets);
  });
}
