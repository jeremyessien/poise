import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poise/poise.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final played = <Object?>[];

  setUp(() {
    played.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          played.add(call.arguments);
          return null;
        });
  });

  test('each word plays its own haptic', () async {
    for (final word in HapticWord.values) {
      await word.play();
    }
    expect(played, [
      'HapticFeedbackType.lightImpact',
      'HapticFeedbackType.selectionClick',
      'HapticFeedbackType.successNotification',
      'HapticFeedbackType.errorNotification',
    ]);
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
