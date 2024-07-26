import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sfs_editor/constants/color.dart';
import 'package:sfs_editor/services/dark_mode_service.dart';
import 'package:sfs_editor/widgets/onboarding%20widgets/background_screen1_widget.dart';

class ScreenConsistance1 extends StatelessWidget {
  const ScreenConsistance1({super.key, required this.nextPage});
  final VoidCallback nextPage;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode? darkMoodColor : Colors.white,
      body: Stack(
        children: [
          const BackgroundScreen1(),
          Positioned(
            top: 120,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode? Colors.white : darkMoodColor,
                  ),
                ),
                Text(
                  'Snaplet',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode? Colors.white : darkMoodColor,
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Turn Words Into Wonders!',
                    style: TextStyle(
                        fontSize: 18,
                        color: themeProvider.isDarkMode? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: nextPage,
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(350, 60),
                      backgroundColor: themeProvider.isDarkMode? Colors.white : Colors.black,
                    ),
                    child:  Row(
                      children: [
                        const Spacer(
                          flex: 3,
                        ),
                        Text(
                          'Continue',
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: themeProvider.isDarkMode? Colors.black : Colors.white,),
                        ),
                        const Spacer(
                          flex: 2,
                        ),
                        Icon(
                          Icons.arrow_forward_outlined,
                          size: 30,
                          color: themeProvider.isDarkMode? Colors.black : Colors.white,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'By proceeding, you accept our Terms of Use and Privacy Policy',
                    style: TextStyle(
                      fontSize: 13,
                      color: themeProvider.isDarkMode? Colors.white : Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
