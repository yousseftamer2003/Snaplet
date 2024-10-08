import 'package:flutter/material.dart';
import 'package:sfs_editor/presentation/common/animation/utils/animation_manager.dart';
import 'package:sfs_editor/presentation/layout/stars_layout.dart';

class Stars extends StatefulWidget {
  const Stars({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _StarsState createState() => _StarsState();
}

class _StarsState extends State<Stars> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _opacity;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: AnimationsManager.stars.duration,
    );
    _animationController.repeat(reverse: true);

    _opacity = AnimationsManager.stars.tween.animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AnimationsManager.stars.curve,
      ),
    );

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    StarsLayout starsLayout = StarsLayout(context);

    return CustomPaint(
      painter: starsLayout.getPainter(
        opacity: _opacity,
      ),
    );
  }
}