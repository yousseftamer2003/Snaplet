import 'package:flutter/material.dart';

class BackgroundScreen1 extends StatelessWidget {
  const BackgroundScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              FadedImageContainer('assets/starryImages/photo1.jpeg'),
              FadedImageContainer('assets/starryImages/photo2.jpeg'),
            ],
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              FadedImageContainer('assets/starryImages/photo3.jpeg'),
              FadedImageContainer('assets/starryImages/photo4.jpeg'),
            ],
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              FadedImageContainer('assets/starryImages/photo6.jpeg'),
              FadedImageContainer('assets/starryImages/photo5.jpeg'),
            ],
          ),
        ),
      ],
    );
  }
}

class FadedImageContainer extends StatelessWidget {
  final String imagePath;
  const FadedImageContainer(this.imagePath, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      width: 150,
      height: 250,
      child: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.5),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.6),
          ],
          stops: const [0.0, 0.2, 0.2, 0.4],
        ).createShader(bounds),
        blendMode: BlendMode.dstOut,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
