import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/src/settings.dart';
import 'package:gallery/src/touches.dart';

void main() {
  late GallerySettings settings;

  setUp(() => settings = GallerySettings()..showTouches = true);
  tearDown(() => settings.dispose());

  Future<void> pumpTouches(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => GallerySettingsScope(
        settings: settings,
        child: ShowTouches(child: child ?? const SizedBox.shrink()),
      ),
      home: const SizedBox.expand(),
    ),
  );

  final dots = find.descendant(
    of: find.byType(ShowTouches),
    matching: find.byType(AnimatedOpacity),
  );

  testWidgets('a finger lifted while touches are hidden leaves no dot behind', (
    tester,
  ) async {
    await pumpTouches(tester);
    final finger = await tester.startGesture(const Offset(200, 300));
    await tester.pump();
    expect(dots, findsOneWidget);

    settings.showTouches = false;
    await tester.pump();
    await finger.up();
    await tester.pumpAndSettle();

    settings.showTouches = true;
    await tester.pump();
    expect(dots, findsNothing);
  });
}
