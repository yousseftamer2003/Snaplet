import 'dart:async';
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
    _controller = VideoPlayerController.asset('assets/videos/newsplash.mp4')
      ..initialize().then((_) {
        _controller.setPlaybackSpeed(2.0);
        setState(() {});
        _controller.play();
      });

    Timer(const Duration(seconds: 6), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const OnBoardingCheck(),
          settings: const RouteSettings(
            name: 'MainScreen',
          )));
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: _controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : Image.asset('assets/starryImages/insideLogo.png'),
        ),
      ),
    );
  }
}
