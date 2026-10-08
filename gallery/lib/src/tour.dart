import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import 'theme.dart';

final class Tour {
  Tour({required this.isStillShowing});

  final bool Function() isStillShowing;

  static var _nextPointer = 900000;

  Future<void> pause(Duration duration) => Future<void>.delayed(duration);

  Future<bool> tap(
    GlobalKey target, {
    Duration hold = const Duration(milliseconds: 120),
  }) async {
    final box = target.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.attached) return false;
    return tapAt(box.localToGlobal(box.size.center(Offset.zero)), hold: hold);
  }

  Future<bool> tapAt(
    Offset position, {
    Duration hold = const Duration(milliseconds: 120),
  }) async {
    if (!isStillShowing()) return false;
    final pointer = _nextPointer++;
    final binding = GestureBinding.instance;
    binding.handlePointerEvent(
      PointerDownEvent(pointer: pointer, position: position),
    );
    await pause(hold);
    binding.handlePointerEvent(
      PointerUpEvent(pointer: pointer, position: position),
    );
    return isStillShowing();
  }
}

final class TourCaption extends StatelessWidget {
  const TourCaption({super.key, required this.title, required this.line});

  final String title;
  final String line;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
    decoration: BoxDecoration(
      color: GalleryColors.paper,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: GalleryColors.grid),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: GalleryType.listWord.copyWith(fontSize: 30),
        ),
        Text(line, textAlign: TextAlign.center, style: GalleryType.group),
      ],
    ),
  );
}
