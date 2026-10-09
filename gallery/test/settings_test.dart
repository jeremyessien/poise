import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/src/settings.dart';
import 'package:poise/poise.dart';

void main() {
  late GallerySettings settings;
  late PoiseMotion seenMotion;

  setUp(() => settings = GallerySettings());
  tearDown(() {
    settings.dispose();
    timeDilation = 1;
  });

  Future<void> pumpScope(WidgetTester tester) => tester.pumpWidget(
    MediaQuery(
      data: const MediaQueryData(),
      child: GallerySettingsScope(
        settings: settings,
        child: Builder(
          builder: (context) {
            seenMotion = context.motion;
            return const SizedBox();
          },
        ),
      ),
    ),
  );

  test('slow motion stretches every animation', () {
    settings.slowMotion = true;
    expect(timeDilation, GallerySettings.slowMotionFactor);
    settings.slowMotion = false;
    expect(timeDilation, 1);
  });

  testWidgets('reduce motion makes context.motion reduced', (tester) async {
    await pumpScope(tester);
    expect(seenMotion, same(PoiseMotion.calm));

    settings.reduceMotion = true;
    await tester.pump();
    expect(seenMotion, same(PoiseMotion.reduced));

    settings.reduceMotion = false;
    await tester.pump();
    expect(seenMotion, same(PoiseMotion.calm));
  });

  test('show touches flips its flag and tells listeners', () {
    var told = 0;
    settings.addListener(() => told++);
    settings.showTouches = true;
    expect(settings.showTouches, isTrue);
    expect(told, 1);
  });
}
