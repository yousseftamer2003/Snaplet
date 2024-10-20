import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:sfs_editor/widgets/onboarding_check.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize the video player
    _controller = VideoPlayerController.asset('assets/videos/newsplash.mp4')
      ..initialize().then((_) {
        setState(() {});
        _controller.setPlaybackSpeed(Platform.isIOS? 2.5 : 2);
        _controller.play();

        // Listen for when the video ends
        _controller.addListener(() {
          
          if (_controller.value.position == _controller.value.duration) {
            // When the video ends, navigate to the OnBoardingCheck screen
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => const OnBoardingCheck(),
              settings: const RouteSettings(name: 'MainScreen'),
            ));
          }
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller to free resources
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white, // Background color during video load
        child: Center(
          child: _controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : Image.asset(
                  'assets/starryImages/insideLogo.png', // Fallback image while video loads
                  width: 100,
                  height: 100,
                ),
        ),
      ),
    );
  }
}
