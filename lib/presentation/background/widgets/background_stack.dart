import 'package:flutter/material.dart';
import 'package:sfs_editor/presentation/background/widgets/stars.dart';
import 'package:sfs_editor/presentation/styles/app_colors.dart';

class BackgroundStack extends StatelessWidget {
  const BackgroundStack({super.key});

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    // List<BackgroundLayerLayout> backgroundLayers = BackgroundLayers()(context);

    return Positioned.fill(
      child: Container(
        height: screenSize.height,
        width: screenSize.width,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [AppColors.primaryAccent, AppColors.primary],
            stops: [0, 1],
            radius: 1.1,
            center: Alignment.centerLeft,
          ),
        ),
        child: const Stack(
          children: [
            Positioned.fill(child: Stars()),
            // ...List.generate(
            //   backgroundLayers.length,
            //   (i) => AnimatedBackgroundLayer(layer: backgroundLayers[i]),
            // ),
          ],
        ),
      ),
    );
  }
}