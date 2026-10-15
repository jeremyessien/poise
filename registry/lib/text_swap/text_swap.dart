import 'package:flutter/widgets.dart';
import 'package:poise/poise.dart';

/// Text that changes where it stands, using the `change` word.
///
/// When [text] changes, the new text rolls up into its line as the old one
/// rolls out, and the space between them resizes to fit. With a personality
/// whose `change` is a fade, or when the phone asks for less motion, the two
/// simply cross-fade.
///
/// Screen readers announce the new text, so a label like "Joining…" turning
/// into "You're in" is heard as well as seen.
final class TextSwap extends StatelessWidget {
  const TextSwap(this.text, {super.key, this.style, this.textAlign});

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  static const _rollDistance = 0.6;

  @override
  Widget build(BuildContext context) {
    final feel = context.motion.change;
    final rolls = feel is Move;
    final incoming = ValueKey(text);

    return Semantics(
      liveRegion: true,
      child: AnimatedSize(
        duration: feel.duration,
        curve: feel.curve,
        child: ClipRect(
          child: AnimatedSwitcher(
            duration: feel.duration,
            transitionBuilder: (child, animation) {
              final arriving = child.key == incoming;
              final fade = FadeTransition(
                opacity: animation.drive(CurveTween(curve: Curves.easeOut)),
                child: arriving ? child : ExcludeSemantics(child: child),
              );
              if (!rolls) return fade;
              final away = Offset(0, arriving ? _rollDistance : -_rollDistance);
              return SlideTransition(
                position: animation.drive(
                  Tween(begin: away, end: Offset.zero).chain(
                    CurveTween(curve: arriving ? feel.curve : Curves.easeIn),
                  ),
                ),
                child: fade,
              );
            },
            layoutBuilder: (current, previous) => Stack(
              alignment: AlignmentDirectional.centerStart,
              children: [...previous, ?current],
            ),
            child: Text(
              text,
              key: incoming,
              style: style,
              textAlign: textAlign,
            ),
          ),
        ),
      ),
    );
  }
}
