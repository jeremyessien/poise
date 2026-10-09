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
  poiseSheet(
    'PoiseSheet',
    'A bottom sheet you can drag and throw, which settles from the speed your '
        'finger let go at.',
    [MotionWord.follow, MotionWord.enter, MotionWord.exit],
    '''
PoiseSheet(
  open: showDetails,
  onClose: () => setState(() => showDetails = false),
  child: EventDetails(event: event),
)''',
  ),
  textSwap(
    'TextSwap',
    'Text that changes where it stands, rolling the new words in and '
        'announcing them to screen readers.',
    [MotionWord.change],
    '''
TextSwap(
  switch (state) {
    JoinState.open => 'Join',
    JoinState.joining => 'Joining…',
    JoinState.joined => "You're in",
  },
)''',
  ),
  countUp(
    'CountUp',
    'A number that counts to its new value, so a balance or a score visibly '
        'climbs instead of jumping.',
    [MotionWord.change],
    '''
CountUp(
  value: spotsLeft,
  format: (n) => '\$n spots left',
)''',
  ),
  successCheck(
    'SuccessCheck',
    'A tick that draws itself inside a circle that pops in, for the moment '
        'something has worked.',
    [MotionWord.celebrate, MotionWord.exit],
    '''
SuccessCheck(
  shown: paymentWentThrough,
  semanticLabel: 'Payment sent',
)''',
  ),
  shake(
    'Shake',
    'The "no" wobble for a wrong password or a code that didn\'t work, which '
        'flashes instead when motion is reduced.',
    [MotionWord.attention],
    '''
Shake(
  trigger: failedAttempts,
  announcement: "That code didn't work",
  child: PromoCodeField(controller: code),
)''',
  ),
  heartBurst(
    'HeartBurst',
    'The like, where a heart pops and bursts when it\'s filled and simply '
        'presses when it\'s taken back.',
    [MotionWord.celebrate, MotionWord.feedback],
    '''
HeartBurst(
  liked: saved,
  child: Icon(saved ? CupertinoIcons.heart_fill : CupertinoIcons.heart),
)''',
  ),
  poiseRoute(
    'PoiseRoute',
    'A page route that slides between screens in your personality, and keeps '
        'the swipe back on iOS.',
    [MotionWord.transition, MotionWord.exit],
    '''
Navigator.of(context).push(
  PoiseRoute(builder: (context) => EventPage(event: event)),
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
