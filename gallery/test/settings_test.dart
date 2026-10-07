import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/src/settings.dart';
import 'package:gallery/src/theme.dart';
import 'package:poise/poise.dart';

void main() {
  late GallerySettings settings;
  late PoiseMotion seenMotion;

  setUp(() => settings = GallerySettings());
  tearDown(() {
    settings.dispose();
    timeDilation = 1;
  });

  Future<void> pumpGallery(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      theme: galleryTheme(),
      builder: (context, child) => GallerySettingsScope(
        settings: settings,
        child: child ?? const SizedBox.shrink(),
      ),
      home: Scaffold(
        body: Column(
          children: [
            const GalleryControls(),
            Builder(
              builder: (context) {
                seenMotion = context.motion;
                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    ),
  );

  testWidgets('slow motion stretches every animation', (tester) async {
    await pumpGallery(tester);
    await tester.tap(find.text('Slow motion'));
    await tester.pump();
    expect(timeDilation, GallerySettings.slowMotionFactor);

    await tester.tap(find.text('Slow motion'));
    await tester.pump();
    expect(timeDilation, 1);
  });

  testWidgets('reduce motion makes context.motion reduced', (tester) async {
    await pumpGallery(tester);
    expect(seenMotion, same(PoiseMotion.calm));

    await tester.tap(find.text('Reduce motion'));
    await tester.pump();
    expect(seenMotion, same(PoiseMotion.reduced));

    await tester.tap(find.text('Reduce motion'));
    await tester.pump();
    expect(seenMotion, same(PoiseMotion.calm));
  });

  testWidgets('show curve flips its flag', (tester) async {
    await pumpGallery(tester);
    await tester.tap(find.text('Show curve'));
    expect(settings.showCurve, isTrue);
  });

  testWidgets('a switched-on chip keeps its label readable', (tester) async {
    await pumpGallery(tester);
    await tester.tap(find.text('Reduce motion'));
    await tester.pump();

    final label = tester.renderObject<RenderParagraph>(
      find.text('Reduce motion'),
    );
    expect(label.text.style?.color, GalleryColors.paper);
  });
}
