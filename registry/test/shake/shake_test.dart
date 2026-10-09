import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poise/poise.dart';
import 'package:poise_registry/shake/shake.dart';

void main() {
  Future<void> pumpShake(
    WidgetTester tester,
    int trigger, {
    bool disableAnimations = false,
    String? announcement,
  }) => tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: PoiseScope(
          motion: PoiseMotion.playful,
          child: Center(
            child: Shake(
              trigger: trigger,
              announcement: announcement,
              child: const SizedBox(width: 100, height: 40),
            ),
          ),
        ),
      ),
    ),
  );

  double sideways(WidgetTester tester) => tester
      .widget<Transform>(
        find.descendant(
          of: find.byType(Shake),
          matching: find.byType(Transform),
        ),
      )
      .transform
      .getTranslation()
      .x;

  double opacity(WidgetTester tester) => tester
      .widget<FadeTransition>(
        find.descendant(
          of: find.byType(Shake),
          matching: find.byType(FadeTransition),
        ),
      )
      .opacity
      .value;

  testWidgets('wobbles when the trigger changes, then comes to rest', (
    tester,
  ) async {
    await pumpShake(tester, 0);
    await pumpShake(tester, 1);
    var furthest = 0.0;
    for (var frame = 0; frame < 20; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
      if (sideways(tester).abs() > furthest) furthest = sideways(tester).abs();
    }
    expect(furthest, greaterThan(3));

    await tester.pumpAndSettle();
    expect(sideways(tester), closeTo(0, 0.01));
  });

  testWidgets('stays still while the trigger stays the same', (tester) async {
    await pumpShake(tester, 1);
    await pumpShake(tester, 1);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('flashes in place when motion is reduced', (tester) async {
    await pumpShake(tester, 0, disableAnimations: true);
    await pumpShake(tester, 1, disableAnimations: true);
    var dimmest = 1.0;
    for (var frame = 0; frame < 12; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
      expect(sideways(tester), 0);
      if (opacity(tester) < dimmest) dimmest = opacity(tester);
    }
    expect(dimmest, lessThan(0.8));
    await tester.pumpAndSettle();
    expect(opacity(tester), 1);
  });

  testWidgets('reads out its announcement on every shake', (tester) async {
    final heard = <String>[];
    tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<Object?>(
      SystemChannels.accessibility,
      (message) async {
        if (message case {
          'type': 'announce',
          'data': {'message': final String text},
        }) {
          heard.add(text);
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger
          .setMockDecodedMessageHandler<Object?>(
            SystemChannels.accessibility,
            null,
          ),
    );

    const message = "That code didn't work";
    await pumpShake(tester, 0, announcement: message);
    await pumpShake(tester, 1, announcement: message);
    await pumpShake(tester, 2, announcement: message);
    await tester.pumpAndSettle();
    expect(heard, [message, message]);
  });
}
