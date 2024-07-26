import 'package:flutter/material.dart';

class BackgroundScreen2 extends StatelessWidget {
  const BackgroundScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: double.infinity,
        height: 540,
        child: FadedImageContainer('assets/starryImages/Frame 109.png'),
      ),
    );
  }
}

class FadedImageContainer extends StatelessWidget {
  final String imagePath;
  const FadedImageContainer(this.imagePath, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 250,
      child: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.9),
          ],
          stops: const [0.2, 0.4, 0.1, 1.0],
        ).createShader(bounds),
        blendMode: BlendMode.dstOut,
        child: ClipRRect(
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
