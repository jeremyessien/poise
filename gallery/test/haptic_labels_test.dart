import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/src/haptic_labels.dart';
import 'package:gallery/src/settings.dart';
import 'package:poise/poise.dart';

final class _Phone implements BinaryMessenger {
  final sent = <String>[];

  @override
  Future<ByteData?>? send(String channel, ByteData? message) {
    sent.add(channel);
    return null;
  }

  @override
  void setMessageHandler(String channel, MessageHandler? handler) {}

  @override
  Future<void> handlePlatformMessage(
    String channel,
    ByteData? data,
    ui.PlatformMessageResponseCallback? callback,
  ) async {}
}

ByteData vibrate(String type) => SystemChannels.platform.codec.encodeMethodCall(
  MethodCall('HapticFeedback.vibrate', type),
);

void main() {
  group('HapticListeningMessenger', () {
    late _Phone phone;
    late PlayedHaptics haptics;
    late HapticListeningMessenger messenger;

    setUp(() {
      phone = _Phone();
      haptics = PlayedHaptics();
      messenger = HapticListeningMessenger(phone, haptics);
    });

    test('hears each haptic word and still sends it to the phone', () {
      messenger.send(
        SystemChannels.platform.name,
        vibrate('HapticFeedbackType.errorNotification'),
      );
      expect(haptics.last, HapticWord.warn);
      expect(phone.sent, [SystemChannels.platform.name]);
    });

    test('counts the same word twice', () {
      for (var i = 0; i < 2; i++) {
        messenger.send(
          SystemChannels.platform.name,
          vibrate('HapticFeedbackType.lightImpact'),
        );
      }
      expect(haptics.count, 2);
    });

    test('ignores haptics that are not poise words', () {
      messenger.send(
        SystemChannels.platform.name,
        vibrate('HapticFeedbackType.heavyImpact'),
      );
      expect(haptics.last, isNull);
      expect(phone.sent, hasLength(1));
    });

    test('passes other messages straight through', () {
      messenger.send('flutter/textinput', null);
      expect(haptics.count, 0);
      expect(phone.sent, ['flutter/textinput']);
    });
  });

  group('ShowHaptics', () {
    late GallerySettings settings;
    late PlayedHaptics haptics;

    setUp(() {
      settings = GallerySettings()..showHaptics = true;
      haptics = PlayedHaptics();
    });
    tearDown(() => settings.dispose());

    Widget labelled(Widget child) => GallerySettingsScope(
      settings: settings,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: ShowHaptics(haptics: haptics, child: child),
      ),
    );

    testWidgets('names the haptic that just played, then lets it go', (
      tester,
    ) async {
      await tester.pumpWidget(labelled(const SizedBox.expand()));
      haptics.heard(HapticWord.warn);
      await tester.pumpAndSettle();
      expect(find.textContaining('warn', findRichText: true), findsOneWidget);
      expect(_labelOpacity(tester), 1);

      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(_labelOpacity(tester), 0);
    });

    testWidgets('brings its own text style above every page', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => GallerySettingsScope(
            settings: settings,
            child: ShowHaptics(
              haptics: haptics,
              child: child ?? const SizedBox.shrink(),
            ),
          ),
          home: const SizedBox.expand(),
        ),
      );
      haptics.heard(HapticWord.tap);
      await tester.pumpAndSettle();
      final label = tester.widget<RichText>(
        find.descendant(
          of: find.byType(ShowHaptics),
          matching: find.byType(RichText),
        ),
      );
      expect(label.text.style?.decoration, isNot(TextDecoration.underline));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
    });

    testWidgets('stays hidden while "Show haptics" is off', (tester) async {
      settings.showHaptics = false;
      await tester.pumpWidget(labelled(const SizedBox.expand()));
      haptics.heard(HapticWord.warn);
      await tester.pumpAndSettle();
      expect(find.textContaining('warn', findRichText: true), findsNothing);
    });

    testWidgets('copes with a haptic played in the middle of a build', (
      tester,
    ) async {
      await tester.pumpWidget(
        labelled(
          Builder(
            builder: (context) {
              if (haptics.count == 0) haptics.heard(HapticWord.confirm);
              return const SizedBox.expand();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        find.textContaining('confirm', findRichText: true),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
    });
  });
}

double _labelOpacity(WidgetTester tester) =>
    tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity).last).opacity;
