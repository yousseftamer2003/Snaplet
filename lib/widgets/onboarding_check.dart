import 'package:flutter/material.dart';
import 'package:sfs_editor/screens/onboarding_screen.dart';
import 'package:sfs_editor/screens/tabs_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnBoardingCheck extends StatelessWidget {
  const OnBoardingCheck({super.key});

  Future<bool> checkIfNewUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isNewUser') ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkIfNewUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading data'));
        } else {
          bool isNewUser = snapshot.data ?? true;
          if (isNewUser) {
            return OnBoardingScreen(
              onComplete: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isNewUser', false);
                // ignore: invalid_use_of_protected_member
                (context as Element).reassemble(); // force rebuild after onboarding complete
              },
            );
          } else {
            return const TabsScreen();
          }
        }
      },
    );
  }
}
