import 'package:sfs_editor/models/position.dart';
import 'package:flutter/animation.dart';

class PositionTween extends Tween<Position> {
  /// Creates a [Size] tween.
  ///
  /// The [begin] and [end] properties may be null; the null value
  /// is treated as an empty size.
  PositionTween({super.begin, super.end});

  /// Returns the value this variable has at the given animation clock value.
  @override
  Position lerp(double t) => Position.lerp(begin, end, t);
}