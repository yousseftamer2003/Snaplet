import 'package:flutter/material.dart';

class GeneratingWidget extends StatefulWidget {
  const GeneratingWidget({super.key});

  @override
  State<GeneratingWidget> createState() => _GeneratingWidgetState();
}

class _GeneratingWidgetState extends State<GeneratingWidget> with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;

  @override
  void initState() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
      )..repeat();
    animation = CurvedAnimation(parent: animationController, curve: Curves.linear);
    super.initState();
  }
  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return  RotationTransition(
      turns: animation,
      child: Image.asset('assets/starryImages/snaplet-logo high small3 edited.png'),
    );
  }
}