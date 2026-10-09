import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poise/poise.dart';
import 'package:poise_registry/poise_sheet/poise_sheet.dart';

void main() {
  const content = ColoredBox(
    key: ValueKey('content'),
    color: Color(0xFFEEEEEE),
    child: SizedBox(height: 300, width: double.infinity),
  );
  final contentFinder = find.byKey(const ValueKey('content'));

  late bool open;
  late int closeRequests;
  late bool honourClose;
  late StateSetter rebuild;

  setUp(() {
    open = false;
    closeRequests = 0;
    honourClose = true;
  });

  Future<void> pumpSheet(
    WidgetTester tester, {
    bool disableAnimations = false,
    PoiseMotion motion = PoiseMotion.calm,
  }) => tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(
        size: const Size(400, 800),
        disableAnimations: disableAnimations,
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: PoiseScope(
          motion: motion,
          child: Navigator(
            onGenerateRoute: (_) => PageRouteBuilder<void>(
              pageBuilder: (_, _, _) => StatefulBuilder(
                builder: (context, setState) {
                  rebuild = setState;
                  return Stack(
                    children: [
                      PoiseSheet(
                        open: open,
                        onClose: () {
                          closeRequests++;
                          if (honourClose) setState(() => open = false);
                        },
                        child: content,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Future<double> openAndSettle(WidgetTester tester) async {
    rebuild(() => open = true);
    await tester.pumpAndSettle();
    return tester.getTopLeft(contentFinder).dy;
  }

  testWidgets('shows nothing while closed', (tester) async {
    await pumpSheet(tester);
    expect(contentFinder, findsNothing);
  });

  testWidgets('rises into place when opened', (tester) async {
    await pumpSheet(tester);
    final resting = await openAndSettle(tester);

    rebuild(() => open = false);
    await tester.pumpAndSettle();
    rebuild(() => open = true);
    await tester.pump(const Duration(milliseconds: 40));
    expect(tester.getTopLeft(contentFinder).dy, greaterThan(resting));

    await tester.pumpAndSettle();
    expect(tester.getTopLeft(contentFinder).dy, closeTo(resting, 0.5));
  });

  testWidgets('tapping the scrim asks to close', (tester) async {
    await pumpSheet(tester);
    await openAndSettle(tester);
    await tester.tapAt(const Offset(200, 40));
    await tester.pumpAndSettle();
    expect(closeRequests, 1);
    expect(contentFinder, findsNothing);
  });

  testWidgets('a nudge springs back without closing', (tester) async {
    await pumpSheet(tester);
    final resting = await openAndSettle(tester);

    await tester.timedDrag(
      contentFinder,
      const Offset(0, 40),
      const Duration(milliseconds: 400),
    );
    await tester.pumpAndSettle();
    expect(closeRequests, 0);
    expect(tester.getTopLeft(contentFinder).dy, closeTo(resting, 0.5));
  });

  testWidgets('pulling it far enough asks to close', (tester) async {
    await pumpSheet(tester);
    await openAndSettle(tester);

    await tester.timedDrag(
      contentFinder,
      const Offset(0, 200),
      const Duration(milliseconds: 800),
    );
    await tester.pumpAndSettle();
    expect(closeRequests, 1);
    expect(contentFinder, findsNothing);
  });

  testWidgets('a quick flick down asks to close', (tester) async {
    await pumpSheet(tester);
    await openAndSettle(tester);

    await tester.fling(contentFinder, const Offset(0, 60), 1500);
    await tester.pumpAndSettle();
    expect(closeRequests, 1);
  });

  testWidgets('springs back up if the parent keeps it open', (tester) async {
    honourClose = false;
    await pumpSheet(tester);
    final resting = await openAndSettle(tester);

    await tester.timedDrag(
      contentFinder,
      const Offset(0, 200),
      const Duration(milliseconds: 800),
    );
    await tester.pumpAndSettle();
    expect(closeRequests, 1);
    expect(tester.getTopLeft(contentFinder).dy, closeTo(resting, 0.5));
  });

  testWidgets('the back gesture asks to close', (tester) async {
    await pumpSheet(tester);
    await openAndSettle(tester);
    await tester.state<NavigatorState>(find.byType(Navigator)).maybePop();
    await tester.pumpAndSettle();
    expect(closeRequests, 1);
  });

  testWidgets('fades in place when motion is reduced', (tester) async {
    await pumpSheet(tester, disableAnimations: true);
    final resting = await openAndSettle(tester);
    rebuild(() => open = false);
    await tester.pumpAndSettle();

    rebuild(() => open = true);
    await tester.pump(const Duration(milliseconds: 40));
    expect(tester.getTopLeft(contentFinder).dy, closeTo(resting, 0.5));
    await tester.pumpAndSettle();
  });

  Future<void> pumpTallSheet(WidgetTester tester, {required double height}) =>
      tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(400, 600)),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: PoiseScope(
              motion: PoiseMotion.calm,
              child: Center(
                child: SizedBox(
                  height: 600,
                  child: Stack(
                    children: [
                      const Text('Behind'),
                      PoiseSheet(
                        open: true,
                        onClose: () {},
                        child: ColoredBox(
                          key: const ValueKey('tall'),
                          color: const Color(0xFFEEEEEE),
                          child: SizedBox(height: height, width: 400),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  testWidgets('content taller than the screen scrolls instead of spilling', (
    tester,
  ) async {
    await pumpTallSheet(tester, height: 1200);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(
      tester.getTopLeft(find.byType(PoiseSheet)).dy,
      greaterThanOrEqualTo(0),
    );
    expect(
      find.descendant(
        of: find.byType(PoiseSheet),
        matching: find.byType(Scrollable),
      ),
      findsOneWidget,
    );
  });

  testWidgets('pulling it up never shows a gap under it', (tester) async {
    await pumpSheet(tester);
    await openAndSettle(tester);
    final screenBottom = tester.getBottomLeft(find.byType(Stack).first).dy;

    final finger = await tester.startGesture(tester.getCenter(contentFinder));
    for (var step = 0; step < 20; step++) {
      await finger.moveBy(const Offset(0, -40));
      await tester.pump(const Duration(milliseconds: 16));
      final sheetBottom = tester
          .getBottomLeft(
            find
                .ancestor(
                  of: contentFinder,
                  matching: find.byType(DecoratedBox),
                )
                .first,
          )
          .dy;
      expect(sheetBottom, greaterThanOrEqualTo(screenBottom - 0.5));
    }
    await finger.up();
    await tester.pumpAndSettle();
  });

  testWidgets('hides what is behind it from screen readers while open', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpTallSheet(tester, height: 200);
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Behind'), findsNothing);
    expect(find.bySemanticsLabel('Sheet'), findsOneWidget);
    semantics.dispose();
  });
}
