import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poise/poise.dart';

void main() {
  final played = <Object?>[];

  setUp(() {
    played.clear();
    TestWidgetsFlutterBinding.ensureInitialized().defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          played.add(call.arguments);
          return null;
        });
  });

  late BuildContext here;
  final grab = Builder(
    builder: (context) {
      here = context;
      return const SizedBox();
    },
  );

  testWidgets('each word plays its own haptic', (tester) async {
    await tester.pumpWidget(grab);
    for (final word in HapticWord.values) {
      await word.play(here);
    }
    expect(played, [
      'HapticFeedbackType.lightImpact',
      'HapticFeedbackType.selectionClick',
      'HapticFeedbackType.successNotification',
      'HapticFeedbackType.errorNotification',
    ]);
  });

  testWidgets('a scope with haptics off keeps every word silent', (
    tester,
  ) async {
    await tester.pumpWidget(
      PoiseScope(motion: PoiseMotion.calm, haptics: false, child: grab),
    );
    for (final word in HapticWord.values) {
      await word.play(here);
    }
    expect(played, isEmpty);
  });

  testWidgets('a nested scope keeps haptics off unless it says otherwise', (
    tester,
  ) async {
    await tester.pumpWidget(
      PoiseScope(
        motion: PoiseMotion.calm,
        haptics: false,
        child: PoiseScope(motion: PoiseMotion.playful, child: grab),
      ),
    );
    await HapticWord.tap.play(here);
    expect(played, isEmpty);

    await tester.pumpWidget(
      PoiseScope(
        motion: PoiseMotion.calm,
        haptics: false,
        child: PoiseScope(
          motion: PoiseMotion.playful,
          haptics: true,
          child: grab,
        ),
      ),
    );
    await HapticWord.tap.play(here);
    expect(played, ['HapticFeedbackType.lightImpact']);
  });

  testWidgets('turning haptics back on reaches a nested scope', (tester) async {
    Widget app({required bool haptics}) => PoiseScope(
      motion: PoiseMotion.calm,
      haptics: haptics,
      child: PoiseScope(motion: PoiseMotion.playful, child: grab),
    );
    await tester.pumpWidget(app(haptics: false));
    await tester.pumpWidget(app(haptics: true));
    await HapticWord.tap.play(here);
    expect(played, ['HapticFeedbackType.lightImpact']);
  });

  testWidgets('reduce motion leaves haptics on', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: PoiseScope(motion: PoiseMotion.calm, child: grab),
      ),
    );
    await HapticWord.warn.play(here);
    expect(played, ['HapticFeedbackType.errorNotification']);
  });

  test('only touch, change, problems and rewards are felt by default', () {
    expect(
      {
        for (final word in MotionWord.values)
          if (word.haptic != null) word: word.haptic,
      },
      {
        MotionWord.feedback: HapticWord.tap,
        MotionWord.change: HapticWord.select,
        MotionWord.attention: HapticWord.warn,
        MotionWord.celebrate: HapticWord.confirm,
      },
    );
  });
}
