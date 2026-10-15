import 'package:poise/poise.dart';

export 'package:poise/poise.dart' show MotionWord;

enum WordGroup {
  timed('Time-based: starts, runs, stops'),
  driven('Driven: no fixed duration'),
  rhythm('Rhythm: how things move together');

  const WordGroup(this.title);

  final String title;
}

/// What the gallery says about each word, and where it lives.
extension GalleryWord on MotionWord {
  WordGroup get group => switch (this) {
    MotionWord.feedback ||
    MotionWord.enter ||
    MotionWord.exit ||
    MotionWord.transition ||
    MotionWord.change ||
    MotionWord.attention ||
    MotionWord.celebrate => WordGroup.timed,
    MotionWord.follow || MotionWord.loop => WordGroup.driven,
    MotionWord.stagger => WordGroup.rhythm,
  };

  String get description => switch (this) {
    MotionWord.feedback => 'The app felt a touch.',
    MotionWord.enter => 'Something arriving.',
    MotionWord.exit => 'Something leaving, quicker than it came.',
    MotionWord.transition => 'Moving from one screen to another.',
    MotionWord.change => 'Something updating where it already is.',
    MotionWord.attention => 'Look here, usually because something is wrong.',
    MotionWord.celebrate => 'Rewarding the user.',
    MotionWord.follow => 'Moves with a finger, then settles.',
    MotionWord.loop => 'Repeats until something stops it.',
    MotionWord.stagger => 'A group arriving one after another.',
  };

  String get path => '/$name';

  static MotionWord? fromPath(String path) {
    for (final word in MotionWord.values) {
      if (word.path == path) return word;
    }
    return null;
  }
}
