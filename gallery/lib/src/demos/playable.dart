import 'package:flutter/widgets.dart';

import '../lane.dart';

abstract class PlayableDemo extends StatefulWidget {
  const PlayableDemo({super.key, required this.play});

  final Listenable play;
}

mixin ReplaysOnPlay<T extends PlayableDemo> on State<T> {
  void replay();

  @override
  void initState() {
    super.initState();
    widget.play.addListener(replay);
  }

  @override
  void didUpdateWidget(T oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.play != widget.play) {
      oldWidget.play.removeListener(replay);
      widget.play.addListener(replay);
    }
  }

  @override
  void dispose() {
    widget.play.removeListener(replay);
    super.dispose();
  }
}

final class AtRest extends StatelessWidget {
  const AtRest({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      Positioned(
        top: LaneGeometry.restTop,
        left: 0,
        right: 0,
        child: Center(child: child),
      ),
    ],
  );
}
