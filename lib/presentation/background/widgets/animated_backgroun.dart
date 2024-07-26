import 'package:flutter/material.dart';
import 'package:sfs_editor/models/position.dart';
import 'package:sfs_editor/presentation/common/animation/utils/animation_manager.dart';
import 'package:sfs_editor/presentation/layout/backgroun_layer_layout.dart';

class AnimatedBackgroundLayer extends StatefulWidget {
  final BackgroundLayerLayout layer;

  const AnimatedBackgroundLayer({
    super.key,
    required this.layer,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AnimatedBackgroundLayerState createState() =>
      _AnimatedBackgroundLayerState();
}

class _AnimatedBackgroundLayerState extends State<AnimatedBackgroundLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<Position> _position;

  @override
  void initState() {
    _animationController = AnimationController(
      duration: AnimationsManager.bgLayer(widget.layer).duration,
      vsync: this,
    );

    _position = AnimationsManager.bgLayer(widget.layer).tween.animate(
          CurvedAnimation(
            parent: _animationController,
            curve: AnimationsManager.bgLayer(widget.layer).curve,
          ),
        );

    Future.delayed(const Duration(milliseconds: 400), () {
      _animationController.forward();
    });
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _position,
      child: Image.asset(
        widget.layer.assetUrl,
        width: widget.layer.size.width,
      ),
      builder: (c, image) => Positioned(
        left: _position.isCompleted
            ? widget.layer.position.left
            : _position.value.left,
        top: _position.isCompleted
            ? widget.layer.position.top
            : _position.value.top,
        right: _position.isCompleted
            ? widget.layer.position.right
            : _position.value.right,
        bottom: _position.isCompleted
            ? widget.layer.position.bottom
            : _position.value.bottom,
        child: image!,
      ),
    );
  }
}