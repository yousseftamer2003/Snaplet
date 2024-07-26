import 'package:flutter/material.dart';
import 'package:sfs_editor/screens/onboarding%20screens/screen1.dart';
import 'package:sfs_editor/screens/onboarding%20screens/screen2.dart';
import 'package:sfs_editor/screens/onboarding%20screens/screen3.dart';


class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key, required this.onComplete});
  final VoidCallback onComplete;

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  PageController controller = PageController();
  double _currentPage = 0;
  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index.toDouble();
    });
  }
  void _nextPage() {
    if (_currentPage < 2) {
      controller.animateToPage(
        _currentPage.toInt() + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }else{
      widget.onComplete();
    }
  }
  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      setState(() {
        _currentPage = controller.page!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: controller,
            onPageChanged: _onPageChanged,
            children: [
              ScreenConsistance1(nextPage: _nextPage,),
              ScreenConsistance2(nextPage: _nextPage,),
              ScreenConsistance3(nextPage: _nextPage,),
            ],
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: _currentPage == index ? 12 : 8,
                  height: _currentPage == index ? 12 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Colors.black
                        : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
