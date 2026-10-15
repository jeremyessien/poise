import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poise/poise.dart';
import 'package:poise_registry/reveal/reveal.dart';
import 'package:poise_registry/staggered_column/staggered_column.dart';

void main() {
  List<Widget> items(int count) => [
    for (var i = 0; i < count; i++) SizedBox(key: ValueKey(i), height: 20),
  ];

  Future<void> pumpColumn(
    WidgetTester tester, {
    int count = 4,
    Object? replayKey,
    bool disableAnimations = false,
  }) => tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: PoiseScope(
          motion: PoiseMotion.playful,
          child: StaggeredColumn(replayKey: replayKey, children: items(count)),
        ),
      ),
    ),
  );

  int visibleCount(WidgetTester tester) => tester
      .widgetList<Reveal>(find.byType(Reveal))
      .where((reveal) => reveal.visible)
      .length;

  final gap = PoiseMotion.playful.stagger;

  testWidgets('children arrive one after another', (tester) async {
    await pumpColumn(tester);
    expect(visibleCount(tester), 1);

    await tester.pump(gap);
    expect(visibleCount(tester), 2);

    await tester.pump(gap * 2);
    expect(visibleCount(tester), 4);
    await tester.pumpAndSettle();
  });

  testWidgets('everything arrives together when motion is reduced', (
    tester,
  ) async {
    await pumpColumn(tester, disableAnimations: true);
    expect(visibleCount(tester), 4);
    await tester.pumpAndSettle();
  });

  testWidgets('a new replay key plays the cascade again', (tester) async {
    await pumpColumn(tester, replayKey: 1);
    await tester.pumpAndSettle();
    expect(visibleCount(tester), 4);

    await pumpColumn(tester, replayKey: 2);
    expect(visibleCount(tester), 1);
    await tester.pumpAndSettle();
    expect(visibleCount(tester), 4);
  });

  testWidgets('children added later arrive in turn', (tester) async {
    await pumpColumn(tester, count: 2);
    await tester.pumpAndSettle();

    await pumpColumn(tester);
    expect(visibleCount(tester), 2);
    await tester.pump(gap);
    expect(visibleCount(tester), 3);
    await tester.pumpAndSettle();
    expect(visibleCount(tester), 4);
  });
}
