import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poise/poise.dart';
import 'package:poise_registry/heart_burst/heart_burst.dart';
import 'package:poise_registry/pressable/pressable.dart';
import 'package:poise_registry/shake/shake.dart';
import 'package:poise_registry/success_check/success_check.dart';

const tap = 'HapticFeedbackType.lightImpact';
const confirm = 'HapticFeedbackType.successNotification';
const warn = 'HapticFeedbackType.errorNotification';

void main() {
  final played = <Object?>[];

  setUp(() {
    played.clear();
    TestWidgetsFlutterBinding.ensureInitialized().defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            played.add(call.arguments);
          }
          return null;
        });
  });

  Widget app(Widget recipe, {bool? haptics, bool disableAnimations = false}) =>
      MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: PoiseScope(
            motion: PoiseMotion.playful,
            haptics: haptics,
            child: Center(child: recipe),
          ),
        ),
      );

  final recipes = <String, ({String haptic, Widget Function(bool on) build})>{
    'HeartBurst': (
      haptic: tap,
      build: (on) =>
          HeartBurst(liked: on, child: const SizedBox.square(dimension: 24)),
    ),
    'Shake': (
      haptic: warn,
      build: (on) =>
          Shake(trigger: on, child: const SizedBox(width: 100, height: 40)),
    ),
    'SuccessCheck': (haptic: confirm, build: (on) => SuccessCheck(shown: on)),
  };

  Widget withHapticOff(Widget recipe) => switch (recipe) {
    HeartBurst(:final liked, :final child) => HeartBurst(
      liked: liked,
      haptic: false,
      child: child,
    ),
    Shake(:final trigger, :final child) => Shake(
      trigger: trigger,
      haptic: false,
      child: child,
    ),
    SuccessCheck(:final shown) => SuccessCheck(shown: shown, haptic: false),
    _ => throw ArgumentError(recipe),
  };

  for (final MapEntry(key: name, value: (:haptic, :build)) in recipes.entries) {
    group(name, () {
      testWidgets('plays its haptic when it turns on', (tester) async {
        await tester.pumpWidget(app(build(false)));
        await tester.pumpWidget(app(build(true)));
        expect(played, [haptic]);
        await tester.pumpAndSettle();
      });

      testWidgets('stays silent on the first build', (tester) async {
        await tester.pumpWidget(app(build(true)));
        expect(played, isEmpty);
        await tester.pumpAndSettle();
      });

      testWidgets('stays silent with haptic: false', (tester) async {
        await tester.pumpWidget(app(withHapticOff(build(false))));
        await tester.pumpWidget(app(withHapticOff(build(true))));
        expect(played, isEmpty);
        await tester.pumpAndSettle();
      });

      testWidgets('stays silent when the app turns haptics off', (
        tester,
      ) async {
        await tester.pumpWidget(app(build(false), haptics: false));
        await tester.pumpWidget(app(build(true), haptics: false));
        expect(played, isEmpty);
        await tester.pumpAndSettle();
      });

      testWidgets('still plays when motion is reduced', (tester) async {
        await tester.pumpWidget(app(build(false), disableAnimations: true));
        await tester.pumpWidget(app(build(true), disableAnimations: true));
        expect(played, [haptic]);
        await tester.pumpAndSettle();
      });
    });
  }

  testWidgets('HeartBurst stays silent when a like is taken back', (
    tester,
  ) async {
    Widget heart(bool liked) =>
        HeartBurst(liked: liked, child: const SizedBox.square(dimension: 24));
    await tester.pumpWidget(app(heart(true)));
    await tester.pumpWidget(app(heart(false)));
    expect(played, isEmpty);
    await tester.pumpAndSettle();
  });

  group('Pressable', () {
    Widget pressable({bool haptic = false}) => Pressable(
      onTap: () {},
      haptic: haptic,
      child: const SizedBox(width: 200, height: 80),
    );

    Future<TestGesture> holdDown(WidgetTester tester) async {
      final press = await tester.startGesture(
        tester.getCenter(find.byType(Pressable)),
      );
      await tester.pump(kPressTimeout);
      return press;
    }

    testWidgets('stays silent unless asked', (tester) async {
      await tester.pumpWidget(app(pressable()));
      final press = await holdDown(tester);
      await press.up();
      await tester.pumpAndSettle();
      expect(played, isEmpty);
    });

    testWidgets('taps as the finger comes down when asked', (tester) async {
      await tester.pumpWidget(app(pressable(haptic: true)));
      final press = await holdDown(tester);
      expect(played, [tap]);
      await press.up();
      await tester.pumpAndSettle();
      expect(played, [tap]);
    });

    testWidgets('stays silent when the app turns haptics off', (tester) async {
      await tester.pumpWidget(app(pressable(haptic: true), haptics: false));
      final press = await holdDown(tester);
      await press.up();
      await tester.pumpAndSettle();
      expect(played, isEmpty);
    });

    testWidgets('still taps when motion is reduced', (tester) async {
      await tester.pumpWidget(
        app(pressable(haptic: true), disableAnimations: true),
      );
      final press = await holdDown(tester);
      await press.up();
      await tester.pumpAndSettle();
      expect(played, [tap]);
    });
  });
}
