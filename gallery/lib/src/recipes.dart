import 'words.dart';

enum GalleryRecipe {
  pressable(
    'Pressable',
    'Any widget answers a press, and dims instead of shrinking when motion '
        'is reduced.',
    [MotionWord.feedback],
  ),
  reveal(
    'Reveal',
    'Comes in and goes away on springs that turn around smoothly if you '
        'change your mind halfway.',
    [MotionWord.enter, MotionWord.exit],
  ),
  staggeredColumn(
    'StaggeredColumn',
    'Children arrive one after another, spaced by the personality\'s gap.',
    [MotionWord.stagger, MotionWord.enter],
  );

  const GalleryRecipe(this.title, this.summary, this.words);

  final String title;
  final String summary;
  final List<MotionWord> words;

  String get path => '/recipes/$name';

  static GalleryRecipe? fromPath(String path) {
    for (final recipe in values) {
      if (recipe.path == path) return recipe;
    }
    return null;
  }
}
