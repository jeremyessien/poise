import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'gather/event_card.dart';
import 'gather/event_details.dart';
import 'gather/promo_code.dart';
import 'recipes.dart';
import 'settings.dart';
import 'theme.dart';
import 'words.dart';

typedef TourCaption = ({String title, String line});

/// Walks through the whole gallery by itself, ready to record: presses, saves
/// and turns the dial in Gather, then opens the menu and visits a recipe,
/// every one of the ten words and the switches before coming home. Any real
/// touch stops it.
///
/// It finds what to press in the widget tree and touches it with its own
/// pointer events, so screens need no hooks for it.
final class GalleryTour extends ChangeNotifier {
  GalleryTour({required this.navigator, required this.settings});

  final GlobalKey<NavigatorState> navigator;
  final GallerySettings settings;

  /// The pointer device the tour's touches arrive from, so they can be told
  /// apart from a real finger.
  static const device = 9000000;

  static bool isTourTouch(PointerEvent event) => event.device == device;

  static const _beat = Duration(milliseconds: 900);
  static var _nextPointer = 1;

  TourCaption _caption = (title: '', line: '');
  var _showsCaption = false;
  var _running = false;
  var _stopRequested = false;
  var _disposed = false;
  Completer<void>? _sleeping;

  /// The last caption shown. It stays while [showsCaption] fades it out.
  TourCaption get caption => _caption;
  bool get showsCaption => _showsCaption;
  bool get isRunning => _running;

  Future<void> play() async {
    if (_running) return;
    _running = true;
    _stopRequested = false;
    final before = (
      touches: settings.showTouches,
      slow: settings.slowMotion,
      reduce: settings.reduceMotion,
    );
    settings.showTouches = true;
    notifyListeners();
    try {
      await _walk();
    } on _TourStopped {
      // A real touch, or a step with nothing left to press.
    } finally {
      _running = false;
      _showsCaption = false;
      if (!_disposed) {
        settings
          ..showTouches = before.touches
          ..slowMotion = before.slow
          ..reduceMotion = before.reduce;
        notifyListeners();
      }
    }
  }

  void stop() {
    if (!_running) return;
    _stopRequested = true;
    final sleeping = _sleeping;
    if (sleeping != null && !sleeping.isCompleted) sleeping.complete();
  }

  @override
  void dispose() {
    _disposed = true;
    stop();
    super.dispose();
  }

  Future<void> _walk() async {
    navigator.currentState?.popUntil((route) => route.isFirst);
    _say('poise', 'Ten words for motion, all inside one app');
    await _pause(const Duration(milliseconds: 1800));

    _sayWord(MotionWord.feedback);
    await _pause(_beat);
    await _tap(_find<EventCard>(), hold: const Duration(milliseconds: 600));
    await _pause(const Duration(milliseconds: 1200));

    _sayWord(MotionWord.follow);
    await _pause(_beat);
    await _drag(
      _findText(EventDetails.heading),
      by: const Offset(0, 60),
      over: const Duration(milliseconds: 500),
    );
    await _pause(const Duration(milliseconds: 1200));
    _say('follow', 'Pull it far enough and it goes');
    await _drag(
      _findText(EventDetails.heading),
      by: const Offset(0, 320),
      over: const Duration(milliseconds: 450),
    );
    await _pause(const Duration(milliseconds: 1200));

    await _tap(_find<EventCard>());
    await _pause(const Duration(milliseconds: 1000));
    _sayWord(MotionWord.change);
    await _pause(_beat);
    await _tap(_findText(JoinState.open.label));
    await _pause(const Duration(milliseconds: 800));
    _sayWord(MotionWord.celebrate);
    await _pause(const Duration(milliseconds: 1600));
    _say('change', 'Spots left count down as you join');
    await _pause(const Duration(milliseconds: 1600));
    _sayWord(MotionWord.attention);
    await _pause(_beat);
    await _tap(_findText(PromoCode.apply));
    await _pause(const Duration(milliseconds: 1400));
    await _drag(
      _findText(EventDetails.heading),
      by: const Offset(0, 320),
      over: const Duration(milliseconds: 450),
    );
    await _pause(const Duration(milliseconds: 1000));

    _say('celebrate', 'Saving an event bursts the heart');
    await _pause(_beat);
    await _tap(_findLabel('Save to plans', index: 1));
    await _pause(const Duration(milliseconds: 1000));
    _sayWord(MotionWord.enter);
    await _pause(const Duration(milliseconds: 1000));

    _sayWord(MotionWord.exit);
    await _pause(const Duration(milliseconds: 1500));

    _sayWord(MotionWord.stagger);
    await _pause(const Duration(milliseconds: 500));
    await _turnDial(Personality.crisp);
    await _pause(const Duration(milliseconds: 1600));

    _say('transition', 'The dial slides on it, the way a screen would');
    await _pause(const Duration(milliseconds: 700));
    await _turnDial(Personality.playful);
    await _pause(const Duration(milliseconds: 1600));

    _say('Same code, three personalities', 'Watch the whole screen change');
    await _pause(const Duration(milliseconds: 1400));
    for (final personality in Personality.values) {
      await _turnDial(personality);
      _say(personality.label, personality.tagline);
      await _pause(const Duration(milliseconds: 1900));
    }

    await _tap(_findLabel('About poise'));
    await _pause(_beat);
    _say('The menu', 'Everything in Gather is made from these recipes');
    await _pause(const Duration(milliseconds: 1600));

    await _tap(_findText(GalleryRecipe.reveal.title));
    await _pause(_beat);
    _say('A recipe', 'Each one has a stage, its curves and its code');
    await _pause(const Duration(milliseconds: 1400));
    await _tap(_findText('Hide'));
    await _pause(const Duration(milliseconds: 1200));
    await _tap(_findText('Show'));
    await _pause(const Duration(milliseconds: 1200));
    await _turnDial(Personality.playful);
    await _pause(const Duration(milliseconds: 1600));
    await _scrollToEnd();
    _say('How it moves', 'The same word in all three personalities');
    await _pause(const Duration(milliseconds: 1800));
    _say('Use it', 'Copy the code, then the folder from the registry');
    await _pause(const Duration(milliseconds: 1600));
    await _back();

    await _bringIntoView('Every word poise uses');
    await _tap(_findText('Every word poise uses'));
    await _pause(_beat);
    _say('The ten words', 'Apps, recipes and agents all use the same words');
    await _pause(const Duration(milliseconds: 1600));
    for (final word in MotionWord.values) {
      await _bringIntoView(word.name);
      _sayWord(word);
      await _pause(const Duration(milliseconds: 1300));
    }
    await _tap(_findText(MotionWord.stagger.name));
    await _pause(_beat);
    _say('A word', 'Its curves, and the recipes that use it');
    await _pause(const Duration(milliseconds: 1400));
    await _turnDial(Personality.playful);
    await _pause(const Duration(milliseconds: 1500));
    await _back();
    await _back();

    await _scrollToEnd();
    _say('While you watch', 'Switches for recording and for checking access');
    await _pause(const Duration(milliseconds: 1400));
    await _tap(_findText('Reduce motion'));
    _say('Reduce motion', 'What people who turn animations off see');
    await _pause(const Duration(milliseconds: 1800));
    await _tap(_findText('Reduce motion'));
    await _pause(const Duration(milliseconds: 600));
    await _tap(_findText('Slow motion'));
    _say('Slow motion', 'Everything runs five times slower');
    await _pause(const Duration(milliseconds: 500));
    await _tap(_findText('Slow motion'));
    await _pause(const Duration(milliseconds: 600));

    navigator.currentState?.popUntil((route) => route.isFirst);
    await _pause(_beat);
    await _turnDial(Personality.calm);
    _say('poise', 'Motion your agent already knows');
    await _pause(const Duration(milliseconds: 2200));
  }

  void _say(String title, String line) {
    _caption = (title: title, line: line);
    _showsCaption = true;
    notifyListeners();
  }

  void _sayWord(MotionWord word) => _say(word.name, word.description);

  /// Waits in the same stretched time as the animations, so slow motion
  /// slows the tour's beats too. Wakes early when the tour is stopped.
  Future<void> _pause(Duration duration) async {
    final sleeping = _sleeping = Completer<void>();
    final timer = Timer(duration * timeDilation, sleeping.complete);
    await sleeping.future;
    timer.cancel();
    _checkStopped();
  }

  void _checkStopped() {
    if (_stopRequested) throw const _TourStopped();
  }

  Future<void> _tap(
    RenderBox target, {
    Duration hold = const Duration(milliseconds: 120),
  }) async {
    final position = target.localToGlobal(target.size.center(Offset.zero));
    final pointer = _nextPointer++;
    GestureBinding.instance.handlePointerEvent(
      PointerDownEvent(pointer: pointer, device: device, position: position),
    );
    await _pause(hold);
    GestureBinding.instance.handlePointerEvent(
      PointerUpEvent(pointer: pointer, device: device, position: position),
    );
  }

  /// Drags [target] by [by], moving a frame at a time over [over] so the
  /// gesture has a real speed when it lets go.
  Future<void> _drag(
    RenderBox target, {
    required Offset by,
    required Duration over,
  }) async {
    const step = Duration(milliseconds: 16);
    final start = target.localToGlobal(target.size.center(Offset.zero));
    final steps = math.max(1, over.inMilliseconds ~/ step.inMilliseconds);
    final pointer = _nextPointer++;
    GestureBinding.instance.handlePointerEvent(
      PointerDownEvent(pointer: pointer, device: device, position: start),
    );
    var position = start;
    for (var i = 1; i <= steps; i++) {
      await _pause(step);
      final next = start + by * (i / steps);
      GestureBinding.instance.handlePointerEvent(
        PointerMoveEvent(
          pointer: pointer,
          device: device,
          position: next,
          delta: next - position,
        ),
      );
      position = next;
    }
    GestureBinding.instance.handlePointerEvent(
      PointerUpEvent(pointer: pointer, device: device, position: position),
    );
  }

  Future<void> _turnDial(Personality personality) =>
      _tap(_findLabel('${personality.label} motion'));

  Future<void> _back() async {
    await navigator.currentState?.maybePop();
    await _pause(const Duration(milliseconds: 700));
  }

  Future<void> _scrollToEnd() => _scrollTo(_scrollPosition().maxScrollExtent);

  Future<void> _scrollTo(double offset) async {
    await _scrollPosition().animateTo(
      offset,
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOutCubic,
    );
    _checkStopped();
  }

  /// Scrolls until the row whose title is [text] is built and in view. Rows
  /// below the fold don't exist yet, so this pages down until one does.
  Future<void> _bringIntoView(String text) async {
    for (var page = 0; page < 8; page++) {
      final rows = _elements((widget) => widget is Text && widget.data == text);
      if (rows.isNotEmpty) {
        await Scrollable.ensureVisible(
          rows.first,
          alignment: 0.4,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
        _checkStopped();
        return;
      }
      final position = _scrollPosition();
      await _scrollTo(
        math.min(
          position.pixels + position.viewportDimension * 0.7,
          position.maxScrollExtent,
        ),
      );
    }
    throw const _TourStopped();
  }

  /// The page's own list, which is the first scrollable on it.
  ScrollPosition _scrollPosition() {
    final scrollable = _element((widget) => widget is Scrollable, 0);
    return ((scrollable as StatefulElement).state as ScrollableState).position;
  }

  RenderBox _find<T extends Widget>() => _box((widget) => widget is T, 0);

  RenderBox _findText(String text) =>
      _box((widget) => widget is Text && widget.data == text, 0);

  RenderBox _findLabel(String label, {int index = 0}) => _box(
    (widget) => widget is Semantics && widget.properties.label == label,
    index,
  );

  RenderBox _box(bool Function(Widget) matches, int index) {
    final box = _element(matches, index).renderObject;
    if (box is! RenderBox || !box.hasSize) throw const _TourStopped();
    return box;
  }

  Element _element(bool Function(Widget) matches, int index) {
    final found = _elements(matches);
    if (found.length <= index) throw const _TourStopped();
    return found[index];
  }

  /// Every widget on the current page that [matches], in tree order. Only
  /// onstage children are visited, so pages underneath in the navigator are
  /// skipped.
  List<Element> _elements(bool Function(Widget) matches) {
    final found = <Element>[];
    void visit(Element element) {
      if (matches(element.widget)) found.add(element);
      element.debugVisitOnstageChildren(visit);
    }

    if (navigator.currentContext case final Element root) visit(root);
    return found;
  }
}

final class _TourStopped implements Exception {
  const _TourStopped();
}
