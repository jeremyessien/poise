import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poise/poise.dart';

void main() {
  final slowEnter = PoiseMotion.calm.copyWith(
    enter: const Move(perceivedDuration: Duration(milliseconds: 600)),
  );
  final quickEnter = PoiseMotion.calm.copyWith(
    enter: const Move(perceivedDuration: Duration(milliseconds: 150)),
  );

  late PoiseMotion seen;
  final reader = Builder(
    builder: (context) {
      seen = context.motion;
      return const SizedBox();
    },
  );

  Widget withMotionSetting({
    required bool disableAnimations,
    required Widget child,
  }) => MediaQuery(
    data: MediaQueryData(disableAnimations: disableAnimations),
    child: child,
  );

  testWidgets('falls back to calm when no scope is set up', (tester) async {
    await tester.pumpWidget(reader);
    expect(seen, same(PoiseMotion.calm));
  });

  testWidgets('uses the nearest scope', (tester) async {
    await tester.pumpWidget(
      PoiseScope(
        motion: slowEnter,
        child: PoiseScope(motion: quickEnter, child: reader),
      ),
    );
    expect(seen, same(quickEnter));
  });

  testWidgets('follows the scope when it changes', (tester) async {
    await tester.pumpWidget(PoiseScope(motion: slowEnter, child: reader));
    await tester.pumpWidget(PoiseScope(motion: quickEnter, child: reader));
    expect(seen, same(quickEnter));
  });

  testWidgets('switches to reduced when the phone asks for less motion', (
    tester,
  ) async {
    await tester.pumpWidget(
      withMotionSetting(
        disableAnimations: true,
        child: PoiseScope(motion: slowEnter, child: reader),
      ),
    );
    expect(seen, same(PoiseMotion.reduced));
  });

  testWidgets('switches back when the setting is turned off', (tester) async {
    await tester.pumpWidget(
      withMotionSetting(
        disableAnimations: true,
        child: PoiseScope(motion: slowEnter, child: reader),
      ),
    );
    await tester.pumpWidget(
      withMotionSetting(
        disableAnimations: false,
        child: PoiseScope(motion: slowEnter, child: reader),
      ),
    );
    expect(seen, same(slowEnter));
  });
}
