import 'words.dart';

/// The recipes the gallery shows. Their facts mirror each recipe's
/// `recipe.yaml` in the registry, and a test keeps the two in step.
enum GalleryRecipe {
  pressable(
    'Pressable',
    'Makes any widget respond to a press, and dims instead of shrinking when '
        'the phone asks for less motion.',
    [MotionWord.feedback],
    '''
Pressable(
  onTap: openEvent,
  child: const EventCard(),
)''',
  ),
  reveal(
    'Reveal',
    'Brings a widget in and takes it away on springs that turn around '
        'smoothly if you change your mind halfway.',
    [MotionWord.enter, MotionWord.exit],
    '''
Reveal(
  visible: justSaved,
  child: const SavedToast(),
)''',
  ),
  staggeredColumn(
    'StaggeredColumn',
    'A column whose children arrive one after another, spaced by the '
        'personality\'s stagger gap.',
    [MotionWord.stagger, MotionWord.enter],
    '''
StaggeredColumn(
  children: [
    for (final event in events) EventRow(event: event),
  ],
)''',
  );

  const GalleryRecipe(this.title, this.summary, this.words, this.code);

  final String title;
  final String summary;
  final List<MotionWord> words;
  final String code;

  String get path => '/recipes/$name';

  String get folder => name.replaceAllMapped(
    RegExp('[A-Z]'),
    (letter) => '_${letter[0]?.toLowerCase()}',
  );

  static GalleryRecipe? fromPath(String path) {
    for (final recipe in values) {
      if (recipe.path == path) return recipe;
    }
    return null;
  }
}
