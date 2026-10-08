enum WordGroup {
  timed('Time-based: starts, runs, stops'),
  driven('Driven: no fixed duration'),
  rhythm('Rhythm: how things move together');

  const WordGroup(this.title);

  final String title;
}

enum MotionWord {
  feedback(WordGroup.timed, 'The app felt a touch.'),
  enter(WordGroup.timed, 'Something arriving.'),
  exit(WordGroup.timed, 'Something leaving, quicker than it came.'),
  transition(WordGroup.timed, 'Moving from one screen to another.'),
  change(WordGroup.timed, 'Something updating where it already is.'),
  attention(WordGroup.timed, 'Look here, usually because something is wrong.'),
  celebrate(WordGroup.timed, 'Rewarding the user.'),
  follow(WordGroup.driven, 'Moves with a finger, then settles.'),
  loop(WordGroup.driven, 'Repeats until something stops it.'),
  stagger(WordGroup.rhythm, 'A group arriving one after another.');

  const MotionWord(this.group, this.description);

  final WordGroup group;
  final String description;

  String get path => '/$name';

  static MotionWord? fromPath(String path) {
    for (final word in values) {
      if (word.path == path) return word;
    }
    return null;
  }
}
